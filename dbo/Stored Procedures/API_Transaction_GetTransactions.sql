-- =============================================
-- Author:		Wei Liu
-- Create date: 15/05/2018
-- Description:	Get Transactions
-- =============================================

CREATE PROCEDURE [dbo].[API_Transaction_GetTransactions] (@UserId int, @TrxId int, @DeviceId varchar(20) , @FromDate datetime, @ToDate datetime, @ReturnValue varchar(max) output)
as 
BEGIN
	SET NOCOUNT ON;
    declare @output varchar(max)
	
	select @FromDate = isnull(@FromDate, dateadd(yyyy, -20, getdate()));
	select @ToDate = isnull(@ToDate, dateadd(dd, 1, getdate()));	

	IF OBJECT_ID('tempdb..#GetTrxTransaction') IS NOT NULL
		BEGIN  DROP TABLE #GetTrxTransaction END;
    IF OBJECT_ID('tempdb..#GetTrxpayment') IS NOT NULL
		BEGIN  DROP TABLE #GetTrxpayment END;

	create table  #GetTrxTransaction (trxid int not null, reference nvarchar(80) null, trxdate datetimeoffset(7) not null, 
	TotalPoints int null, StoreName nvarchar(50) not null, DeviceId nvarchar(25) null, TypeName nvarchar(35) not null,
	Status varchar(30) not null, AccountCashBalance int null, AccountPointsBalance int null,  IsAnonymous bit null ,Value money ,Discount money , UserId int null)

	IF @TrxId is not null or @DeviceId is not null
	Begin
	    insert into #GetTrxTransaction 
		select th.trxid, th.reference, th.trxdate, th.TotalPoints , (s.Name) as StoreName, th.DeviceId, (trt.[Name])as TypeName, (ts.Name) as [Status],
		convert(int, th.AccountCashBalance) as AccountCashBalance ,convert(int, th.AccountPointsBalance) as AccountPointsBalance, th.IsAnonymous, null Value, null Discount, UserId
		from TrxHeader th
		join TrxType trt on trt.TrxTypeId = th.TrxTypeId
		join TrxStatus ts on ts.TrxStatusId = th.TrxStatusTypeId
		join Site s on s.SiteId = th.SiteId 
		join Device d on d.DeviceId = th.DeviceId	
		--where TrxId = @TrxId or th.DeviceId = @DeviceId
		--and ISNULL(th.IsAnonymous, 0) = 0
	END

	Else if @UserId <> 0 and @FromDate is not null and @ToDate is not null
	Begin	  
	    print @FromDate
		print @ToDate
		insert into #GetTrxTransaction 
		select th.trxid, th.reference, th.trxdate, th.TotalPoints , (s.Name) as StoreName, th.DeviceId, (trt.[Name])as TypeName, (ts.Name) as [Status],
		convert(int, th.AccountCashBalance) as AccountCashBalance ,convert(int, th.AccountPointsBalance) as AccountPointsBalance, th.IsAnonymous, null Value, null Discount, UserId
		from TrxHeader th
		join TrxType trt on trt.TrxTypeId = th.TrxTypeId
		join TrxStatus ts on ts.TrxStatusId = th.TrxStatusTypeId
		join Site s on s.SiteId = th.SiteId 
		join Device d on d.DeviceId = th.DeviceId
		where UserId in (1403013, 1402619) and trxDate between @FromDate and @ToDate
		and ISNULL(th.IsAnonymous, 0) = 0
	END

	    update a
		set a.Value = b.Value, a.Discount = b.Discount
		from #GetTrxTransaction a
		inner join(
			select SUM(a.value) Value, SUM(EposDiscount + LoyaltyDiscount) Discount,  a.TrxId
			from TrxDetail a
			group by a.TrxId
		 ) b on a.trxid = b.trxid	

		select trxid, tt.[Name] as PaymentType, tp.TenderAmount as PaymentAmount, tp.Currency, tp.ExtraInfo 
		into #GetTrxpayment
		from TrxPayment tp
		join TenderType tt on tt.TenderTypeId = tp.TenderTypeId
		where tp.TrxID in (
			select TrxID from #GetTrxTransaction
		)
		set @ReturnValue = (
			select  	
			th.TrxId,
			th.Reference PosTrxId, 
			th.TrxDate TransactionDate,
			th.TotalPoints Points,
			th.StoreName,
			th.DeviceId DeviceNumber,
			th.TypeName [Type],
			th.[Status] Status,
			th.AccountCashBalance,
			th.AccountPointsBalance,
			th.IsAnonymous,
			th.Value,
			th.Discount,
		    (
				select TrxID , TrxDetailID as 'TrxDetailID', LineNumber as 'LineNumber', ItemCode as 'ItemCode',
				Description as 'Description', Convert(int, Quantity)as 'Quantity', Value,
				convert(int, Points) as Points, (EposDiscount + LoyaltyDiscount) as Discount			
				from TrxDetail td			
				where td.TrxID = th.TrxId for json auto
			) TransactionDetails,
			(
			    select * from #GetTrxpayment tp
				where tp.TrxID = th.TrxId for json auto
			) TransactionPayments
			from #GetTrxTransaction th
			for json path
		);
	
END

