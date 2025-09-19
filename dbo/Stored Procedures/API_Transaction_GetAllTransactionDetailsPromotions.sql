-- =============================================
-- Author:		WEI LIU
-- Create date: 2021-02-04
-- Description:	Get all transaction's and promotion details 
-- =============================================

CREATE PROCEDURE [dbo].[API_Transaction_GetAllTransactionDetailsPromotions] (@UserId int, @ActivityCategoryName nvarchar(200),@ActivityCategoryTypeName nvarchar(200),
@PromotionCategoryName nvarchar(200),@PromotionCategoryTypeName nvarchar(200), @TrxTypeName varchar(200), @DeviceId varchar(20), @FromDate datetime,
@ToDate datetime, @SelectPromotion Bit, @Negate Bit, @PageStart int, @PageEnd int, @Result nvarchar(max) output)
AS
BEGIN

	SET NOCOUNT ON;
    
	Declare @TrxTypeId int,@TrxTypeIds nvarchar(max), @PromotionCategoryId int, @PromotionCategoryIds nvarchar(max),
	@PromotionCategoryTypeId int, @PromotionCategoryTypeIds nvarchar(max),
	@ActivityCategoryId int, @ActivityCategoryIds nvarchar(max),@ActivityCategoryTypeId int, @ActivityCategoryTypeIds nvarchar(max),
	@SQL nvarchar(max) , @TrxDetailSQL nvarchar(max) , @PromotionSQL nvarchar(max) , @PromotionMidSQL nvarchar(max) , @PromotionEndSQL nvarchar(max) , @MidSQL nvarchar(max), @EndSQL nvarchar(max), 
	@All int = 0, @DeviceStatusId int, @UserDevices nvarchar(1000), @TrxStatusId int , @clientId int, @Code int
	DECLARE @DateString nvarchar(max) = ''


	SELECT @clientId = ClientId from Client where [name] = 'baseline'
	SELECT @TrxStatusId = TrxStatusId from trxstatus where [Name] = 'Completed' and ClientId = @clientId
	SET @Code = 200
	IF @FromDate != ''
	BEGIN
		select @FromDate = CONVERT(datetime,@FromDate, 120)
		SET @DateString = @DateString + ' th.trxdate >= '''+  CONVERT(VARCHAR(50), @FromDate, 121)+'''' + 
		' And '
	END
	IF @ToDate != ''
	BEGIN
		select @ToDate = CONVERT(datetime,@ToDate, 120)
		SET @DateString = @DateString + ' th.trxdate <= '''+  CONVERT(VARCHAR(50), @ToDate, 121)+'''' + 
		' And '
	END
	

	Set @EndSQL = ''
	  
	IF @UserId = 0 and @DeviceId != ''
	BEGIN
		SET @UserDevices = @DeviceId
		Set @All = 1;
	END
	ELSE IF @UserId != 0 and @DeviceId = ''
	BEGIN
		select top 1 @DeviceStatusId = DeviceStatusId from DeviceStatus where Name = 'Active';

    	select @UserDevices = coalesce(@UserDevices + ''', ''', '') + ''+ cast(d.DeviceId as nvarchar(max)) + ''
		from Device d 
		join DeviceProfile dp on dp.DeviceId = d.Id
		join DeviceProfileTemplate dpt on dpt.Id = dp.DeviceProfileId
		join DeviceProfileTemplateType dptt on dptt.Id = dpt.DeviceProfileTemplateTypeId
		where dptt.Name = 'Loyalty'
		and d.UserId = @UserId
		and d.DeviceStatusId = @DeviceStatusId
		print @UserDevices
		Set @All = 2;
	END
	ELSE IF  @UserId != 0 and @DeviceId != ''
	BEGIN
		DECLARE @CheckUserID nvarchar(200)
		SELECT Top 1 @CheckUserID = UserId from Device where DeviceId = @DeviceId
		IF @CheckUserID != @UserId
		BEGIN
			SET @Code = 500
		END
		ELSE
		BEGIN
			SET @UserDevices = @DeviceId
			Set @All = 1;
		END		
	END
	
	IF @SelectPromotion = 1
	BEGIN
		 Set @MidSQL	= ' from TrxHeader th 
							left join TrxDetail td on th.TrxId=td.TrxID
							left join TrxDetailPromotion tdp on tdp.TrxDetailId=td.TrxDetailID
							left join Promotion p on p.id=tdp.PromotionId '
						    
					
		 Set @PromotionSQL = ' ,(
								 select p.[Name] as PromotionName
								,p.[Description] as PromotionDescription
								,p.[SiteId] as PromotionSiteId
								,[StartDate] 
								,[EndDate]
								,[StartTime]
								,[EndTime]
								,[Enabled]
								,[DaysEnabled]
								,[PromotionOfferValue]
								,[TotalOffers]
								,[Message]
								,p.[Quantity] as PromotionQuanity
								,[ActivityReference] '
		 Set @PromotionMidSQL = ' from Promotion p 
		 left join TrxDetailPromotion tdp on tdp.TrxDetailId=td.TrxDetailID '
		 Set @PromotionEndSQL = ' where p.id= tdp.PromotionId '
		
		IF @PromotionCategoryName != ''
		BEGIN
			Set @PromotionSQL = @PromotionSQL + 
								  ' ---------[PromotionCategory]---------
									,(
									select pc.[Name] as PromotionCategoryName  
									from PromotionCategory pc			
									where pc.Id=p.PromotionCategoryId  for json auto
									) PromotionCategory'

			Set @MidSQL	= @MidSQL + ' left join PromotionCategory pc on pc.Id=p.PromotionCategoryId '
			Set @PromotionMidSQL = @PromotionMidSQL + ' left join PromotionCategory pc on pc.Id=p.PromotionCategoryId '
			IF @PromotionCategoryName != 'ALL'
			BEGIN
				select @PromotionCategoryId =  Id from PromotionCategory where [Name] = @PromotionCategoryName
				IF @Negate = 1
				BEGIN
					Set @PromotionEndSQL = @PromotionEndSQL + ' AND p.PromotionCategoryId != '+  CONVERT(varchar(20),@PromotionCategoryId)
				END
				ELSE
				BEGIN
					Set @PromotionEndSQL = @PromotionEndSQL + ' AND p.PromotionCategoryId = '+  CONVERT(varchar(20),@PromotionCategoryId)
				END			
			END
			ELSE IF UPPER(@PromotionCategoryName) = 'ALL'
			BEGIN
				select @PromotionCategoryIds = coalesce(@PromotionCategoryIds + ', ', '') + cast(Id as nvarchar(100))from PromotionCategory
				Set @PromotionEndSQL = @PromotionEndSQL + ' AND p.PromotionCategoryId in ('+  CONVERT(varchar(max),@PromotionCategoryIds) +') '
			END

			IF @PromotionCategoryTypeName != ''
			BEGIN
				Set @PromotionSQL = @PromotionSQL + 
								' ---------[PromotionCategoryType]---------
								,(
									select distinct pct.[Name] as PromotionCategoryTypeName 
									from PromotionCategoryType act			
									where pct.Id=pc.PromotionCategoryTypeId   for json auto
								) PromotionCategoryType '

				Set @MidSQL	= @MidSQL + ' left join PromotionCategoryType pct on pct.Id=pc.PromotionCategoryTypeId '
				Set @PromotionMidSQL = @PromotionMidSQL + ' left join PromotionCategoryType pct on pct.Id=pc.PromotionCategoryTypeId '
				IF @PromotionCategoryTypeName != 'ALL'
				BEGIN
					select @PromotionCategoryTypeId =  Id from PromotionCategoryType where [Name] = @PromotionCategoryTypeName		
					IF @Negate = 1
					BEGIN
						Set @PromotionEndSQL = @PromotionEndSQL + ' AND pc.PromotionCategoryTypeId != '+  CONVERT(varchar(20), @PromotionCategoryTypeId)
					END
					ELSE
					BEGIN
						Set @PromotionEndSQL = @PromotionEndSQL + ' AND pc.PromotionCategoryTypeId  = '+  CONVERT(varchar(20), @PromotionCategoryTypeId)
					END
				END
				ELSE IF UPPER(@PromotionCategoryTypeName) = 'ALL'
				BEGIN
					select @PromotionCategoryTypeIds = coalesce(@PromotionCategoryTypeIds + ', ', '') + cast(Id as nvarchar(100))from PromotionCategoryType
					Set @PromotionEndSQL = @PromotionEndSQL + ' AND pc.PromotionCategoryTypeId  in ('+  CONVERT(varchar(max),@PromotionCategoryTypeIds) +') '
				END
			END
		END
		
		IF @ActivityCategoryName != ''
		BEGIN
			Set @PromotionSQL = @PromotionSQL + ' 
												  ----------[ActivityCategory]---------
												  ,(
													select ac.[Name] as ActivityCategoryName  
													from ActivityCategory ac			
													where ac.Id=p.ActivityCategoryId  for json auto
												  ) ActivityCategory '

			Set @MidSQL	= @MidSQL + ' left join ActivityCategory ac on ac.Id=p.ActivityCategoryId '
			Set @PromotionMidSQL = @PromotionMidSQL + ' left join ActivityCategory ac on ac.Id=p.ActivityCategoryId '
			IF @ActivityCategoryName != 'ALL'
			BEGIN			
				select @ActivityCategoryId =  Id from ActivityCategory where [Name] = @ActivityCategoryName
				IF @Negate = 1
				BEGIN
					Set @PromotionEndSQL = @PromotionEndSQL + ' AND p.ActivityCategoryId != '+  CONVERT(varchar(20),@ActivityCategoryId)
				END
				ELSE
				BEGIN
					Set @PromotionEndSQL = @PromotionEndSQL + ' AND p.ActivityCategoryId = '+  CONVERT(varchar(20),@ActivityCategoryId)
				END
			END

			ELSE IF UPPER(@ActivityCategoryName) = 'ALL'
			BEGIN				
				select @ActivityCategoryIds = coalesce(@ActivityCategoryIds + ', ', '') + cast(Id as nvarchar(100))from ActivityCategory
				Set @PromotionEndSQL = @PromotionEndSQL + ' AND p.ActivityCategoryId in ('+  CONVERT(varchar(max),@ActivityCategoryIds) +') '
			END
		END 
	
		IF @ActivityCategoryTypeName != '' 
		BEGIN
			Set @PromotionSQL = @PromotionSQL + ' 
												  ---------[ActivityCategoryType]---------
												  ,(
													select act.[Name] as ActivityCategoryTypeName  
													from ActivityCategoryType act			
													where act.Id=p.ActivityCategoryTypeId  for json auto
												   ) ActivityCategoryType '
			Set @MidSQL	= @MidSQL + ' left join ActivityCategoryType act on act.Id=p.ActivityCategoryTypeId '
			Set @PromotionMidSQL = @PromotionMidSQL + ' left join ActivityCategoryType act on act.Id=p.ActivityCategoryTypeId '
			IF @ActivityCategoryTypeName != 'ALL'
			BEGIN
				select @ActivityCategoryTypeId =  Id from ActivityCategoryType where [Name] = @ActivityCategoryTypeName
				IF @Negate = 1
				BEGIN
					Set @PromotionEndSQL = @PromotionEndSQL + ' AND p.ActivityCategoryTypeId != '+  CONVERT(varchar(20),@ActivityCategoryTypeId)
				END
				ELSE
				BEGIN
					Set @PromotionEndSQL = @PromotionEndSQL + ' AND p.ActivityCategoryTypeId = '+  CONVERT(varchar(20),@ActivityCategoryTypeId)
				END
			END
			ELSE IF UPPER(@ActivityCategoryTypeName) = 'ALL'
			BEGIN
				select @ActivityCategoryTypeIds = coalesce(@ActivityCategoryTypeIds + ', ', '') + cast(Id as nvarchar(100))from ActivityCategoryType
				Set @PromotionEndSQL = @PromotionEndSQL + ' AND p.ActivityCategoryTypeId in ('+  CONVERT(varchar(max),@ActivityCategoryTypeIds) +') '
			END
		END
		
		Set @PromotionEndSQL = @PromotionEndSQL + ' for json auto ) Promotion  '

		Set @PromotionSQL = @PromotionSQL + @PromotionMidSQL + @PromotionEndSQL

		print '------------------@PromotionSQL----------'
		print 	@PromotionSQL
		print '-----------------------------------------'

		Set @TrxDetailSQL = ',(
								select td.TrxDetailID, LineNumber, ItemCode,
								td.Description, Convert(int, td.Quantity)as Quantity, Convert(decimal,Value) as Value,
								convert(int, Points) as Points, Convert(decimal, PromotionalValue) as PromotionalValue
								-----------[TrxDetailPromotion]---------
								,(
									select tdp.[PromotionId] as TrxDetailPromotionLinkId
										  ,tdp.[TrxDetailId] as TrxDetailLinkId
										  ,Convert(decimal, [ValueUsed]) as ValueUsed  
									from TrxDetailPromotion tdp			
									where tdp.TrxDetailId = td.TrxDetailID for json auto
								) TrxDetailPromotion
								------------[Promotion]---------
								' + @PromotionSQL +'
								-----------[TrxVoucherDetail]------------
								,(
									select tvd.[TrxVoucherId] as LineItemVoucherId
										  ,tvd.[VoucherAmount] as LineItemVoucherAmount
										  ,tvd.[DeviceId] as LineItemDeviceId 
									from TrxVoucherDetail tvd			
									where tvd.TrxDetailId = td.TrxDetailId for json auto
								) TrxVoucherDetail 
								from TrxDetail td
								where td.TrxID = th.TrxId for json auto
							  ) TransactionDetails '
	
	END
	ELSE
	BEGIN
		Set @TrxDetailSQL = ',(
								select td.TrxDetailID, LineNumber, ItemCode,
								td.Description, Convert(int, td.Quantity)as Quantity, Convert(decimal,Value) as Value,
								convert(int, Points) as Points, Convert(decimal, PromotionalValue) as PromotionalValue
								-----------[TrxVoucherDetail]------------
								,(
									select tvd.[TrxVoucherId] as LineItemVoucherId
										  ,tvd.[VoucherAmount] as LineItemVoucherAmount
										  ,tvd.[DeviceId] as LineItemDeviceId 
									from TrxVoucherDetail tvd			
									where tvd.TrxDetailId = td.TrxDetailId for json auto
								) TrxVoucherDetail 
								from TrxDetail td			
								where td.TrxID = th.TrxId for json auto
							  ) TransactionDetails '
		Set @MidSQL	= ' from TrxHeader th 
						inner join TrxDetail td on th.TrxId=td.TrxID 
						join #temp tmp on tmp.trxid = th.TrxId'
	END
	print '--------------------@TrxDetailSQL---------------'
	print @TrxDetailSQL
	print '-----------------------------------------'

	Set @SQL ='SET @JSON = (			   
			   SELECT DISTINCT
			   RowNum,
			   ------Trxheader--------- 
			   th.[TrxId]
			  ,th.[DeviceId]
			  ,[TrxTypeId]
			  ,[TrxDate]
			  ,th.[SiteId]
			  ,[TerminalId]
			  ,[Reference]
			  ,[OpId]
			  ,[TrxStatusTypeId]
			  ,[CreateDate]
			  ,[TerminalDescription]
			  ,[BatchId]
			  ,[Batch_Urn]
			  ,[TrxCommitDate]
			  ,[InitialTransaction]
			  ,[TerminalExtra]
			  ,convert(decimal, [AccountCashBalance]) as AccountCashBalance
			  ,convert(decimal, [AccountPointsBalance]) as AccountPointsBalance
			  ,[ImportUniqueId]
			  ,[EposTrxId]
			  ,[TerminalExtra2]
			  ,[TerminalExtra3]
			  ,[MemberId]
			  ,[TotalPoints]
			  ,[OLD_TrxId]
			  ,[LastUpdatedDate]
			  ,[IsAnonymous]
			  ,[ReservationId]
			  ,[IsTransferred]
			  ,[ReceiptId]
			  ,[Region]
			  ,[Location] 
			  -------trxdetail---------
			  ' + @TrxDetailSQL +' 
			  -----------[TrxVoucher]---------
			  ,(
				select tv.[VoucherId] as BasketVoucherId
					  ,tv.[VoucherAmount] as BasketVoucherAmount
					  ,tv.[DeviceId] as BasketVoucherDeviceId	
				from TrxVoucher tv			
				where tv.TrxID = th.TrxId for json auto
			  ) TrxVoucher '

	print convert(varchar(100), @All ) + '  xxxxxxxxxx'
	IF @All = 1
	BEGIN
		Set @EndSQL = @EndSQL + ' AND th.DeviceId = ''' +  CONVERT(varchar(20),@DeviceId) +''''
	END
	ELSE IF @All = 2
	BEGIN
		Set @EndSQL = @EndSQL + ' AND th.DeviceId in (''' +  CONVERT(varchar(max),@UserDevices) +''')'
	END

	IF @TrxTypeName != ''
	BEGIN
		select @TrxTypeId = TrxTypeId from TrxType where [Name] = @TrxTypeName
		IF @Negate = 1
		BEGIN
			Set @EndSQL = @EndSQL + ' AND th.TrxTypeId != '+  CONVERT(nvarchar(20),@TrxTypeId)
		END
		ELSE
		BEGIN
			Set @EndSQL = @EndSQL + ' AND th.TrxTypeId = '+  CONVERT(nvarchar(20),@TrxTypeId)
		END
	END

	print '------------------mid and end-----------------'
	print @DateString
	print @MidSQL +' where' +  @DateString + ' th.TrxStatusTypeId = ' +  CONVERT(VARCHAR(10),@TrxStatusId) + ' '+ @EndSQL +
	'  and  RowNum >= ' + Convert(varchar(20), @PageStart) + ' AND RowNum < ' + Convert(varchar(20), @PageEnd) +' ORDER BY RowNum ' 
	+ 'for json path )'

	print '------------------FULL-----------------------'
	

	
	-------------------------------------------------------------------------
	IF @PromotionCategoryName != ''
	BEGIN
		Set @EndSQL = @EndSQL + ' AND pc.[Name] = '''+  CONVERT(nvarchar(200), @PromotionCategoryName)	 + ''' '
	END
	IF @PromotionCategoryTypeName != ''
	BEGIN
		Set @EndSQL = @EndSQL + ' AND pct.[Name] = '''+  CONVERT(nvarchar(200), @PromotionCategoryTypeName)	 + ''' '
	END
	IF @ActivityCategoryName != ''
	BEGIN
		Set @EndSQL = @EndSQL + ' AND ac.[Name] = '''+  CONVERT(nvarchar(200), @ActivityCategoryName)	 + ''' '
	END
	IF @ActivityCategoryTypeName != ''
	BEGIN
		Set @EndSQL = @EndSQL + ' AND act.[Name] = '''+  CONVERT(nvarchar(200), @ActivityCategoryTypeName)	 + ''' '
	END
	------------------------------------------------------------------------
	CREATE TABLE #temp (RowNum INT, trxid INT)


	Declare @countSql nvarchar(max)
	Set @countSql = 'insert into GetAllTransactionDetailsPromotionsRowNum (RowNum, TrxId) select distinct ROW_NUMBER() OVER ( ORDER BY th.TrxId ) AS RowNum, th.trxid ' + @MidSQL
      + ' where ' + @DateString + ' th.TrxStatusTypeId = ' +  CONVERT(VARCHAR(10),@TrxStatusId) + ' '+ @EndSQL + ' group by th.trxid; '

	print @countSql
    exec(@countSql)

	 Set @MidSQL = @MidSQL +'join GetAllTransactionDetailsPromotionsRowNum tmp on tmp.trxid = th.TrxId ' 
	 ----------------------------------------------------------------------------------------

	Set @SQL = @SQL + @MidSQL + ' where' + @DateString + ' th.TrxStatusTypeId = ' +  CONVERT(VARCHAR(10),@TrxStatusId) + ' '+ @EndSQL +
	'  and  RowNum >= ' + Convert(varchar(20), @PageStart) + ' AND RowNum < ' + Convert(varchar(20), @PageEnd) +' ORDER BY RowNum ' 
	+ 'for json path )';

	IF @Code = 200
	BEGIN
		DECLARE @JSONDATA NVARCHAR(MAX)
		EXECUTE sp_executesql @SQL, N'@JSON NVARCHAR(MAX) OUTPUT', @JSON = @JSONDATA OUTPUT
		SET @Result = @JSONDATA
		print @SQL
	END
	ELSE
	BEGIN
		SET @Result = null
	END
	
	drop table #temp
	delete from GetAllTransactionDetailsPromotionsRowNum
	 --declare @Result nvarchar(max)
     --exec [dbo].[API_Transaction_GetAllTransactionDetailsPromotions] 1402623, 'Watch', '' ,'', '', '', '', '' , '', 1, 0, 1, 2, @Result out
	 --select @Result
	 --exec [dbo].[API_Transaction_GetAllTransactionDetailsPromotions] 0, 'Watch', '' ,'', '', '', '', '' , '', 1, 0, 1, 2
	 --declare @returnValue nvarchar(max)
	 --exec [dbo].[API_Transaction_GetTransactions] 1403013, 5412,'V53971413', '', '', @returnValue out
	 --select LEN(@returnValue)

END
