CREATE Procedure [SSISHelper].[OrdersDeliveredFromFulfillment] as

Begin 
Declare @clientid int=1, @TrxTypeID_Delivery int, @TrxStatus_Complete int
select @TrxTypeID_Delivery = trxtypeid from trxtype where clientid = @clientid and [Name]='Delivery'
select @TrxStatus_Complete = trxstatusid from TrxStatus where clientid = @clientid and [Name]='Completed'

/*
Client Order # >> Trxheader.Reference
Ship Date >> Trxheader.TrxDate
Ship to First Name >> TrxDetail.Anal1
Ship to Last Name >> TrxDetail.Anal2
Ship to Address 1 >> TrxDetail.Anal3
Ship to Address 2 >> TrxDetail.Anal4
Ship to Address 3 >> TrxDetail.Anal5
Ship to City >> TrxDetail.Anal6
Ship to State >> TrxDetail.Anal7
Ship to Zip >> TrxDetail.Anal8
Ship to Country >> TrxDetail.Anal9
Stock Number >> TrxDetail.ItemCode
Stock Description >> TrxDetail.Description
Ship Qty >> TrxDetail.Quantity
Order Status >> TrxHeader.TrxStatusID
Tracking Number(s) >> TrxDetail.Anal10

*/
IF OBJECT_ID('tempdb..#Delivered ') IS NOT NULL 
BEGIN drop table #Delivered END

select [Client Order #] as Reference, [Ship Date] as TrxDate, @TrxTypeID_Delivery as TrxTypeid, @TrxStatus_Complete as TrxStatusID , th.trxid,th.deviceid,
[Ship to First Name] Anal1,[Ship to Last Name] Anal2,[Ship to Address 1] Anal3,[Ship to Address 2] Anal4,[Ship to Address 3] Anal5,[Ship to City] Anal6,[Ship to State] Anal7,[Ship to Zip] Anal8,[Ship to Country] Anal9,
[Stock Number] ItemCode,[Stock Description] [Description],[Ship Qty] Quantity,[Order Status] ,[Tracking Number(s)] Anal11, dv.id IDofDevice, th.siteid as SiteID into #Delivered
from  [SSISHelper].[OrderFulfillment]  oful join trxheader th on th.Reference collate database_default=
oful.[Client Order #]
join Device dv on dv.deviceid=th.deviceid
where th.reference!='00000000-0000-0000-0000-000000000000' and oful.[status]=1

declare @outputTRX table (Trxid int, DeviceID nvarchar(50),Old_Trxid INT,reference nvarchar(36));
	
	INSERT INTO  TrxHeader (old_Trxid, DeviceId,TrxTypeId,TrxDate,ClientId,SiteId,Reference,TrxStatusTypeId,
	CreateDate,DeviceIdentity,TrxCommitDate,TerminalId,TerminalDescription,AccountCashBalance,AccountPointsBalance)
	output inserted.TrxId, inserted.DeviceId, inserted.OLD_TrxId, inserted.Reference into @outputTRX (Trxid, Deviceid, old_trxid, reference)
	SELECT  trxid,g.Deviceid,@TrxTypeID_Delivery,TrxDate ,@ClientId,2,Reference,@TrxStatus_Complete,
	GETDATE(),IdofDevice,GETDATE(),'','Fulfilment Partner',0 ,0 
	from #Delivered g
	select * from @outputTRX
	select * from #delivered

	INSERT INTO TrxDetail(Version,trxid,LineNumber,Description,ItemCode,Quantity,Value,Points,
	Anal1, Anal2,Anal3,Anal4, Anal5,Anal6,Anal7, Anal8,Anal9, Anal11)
	SELECT 0,o.TrxId,1,left(d.Description,200),d.ItemCode,Quantity,0,0,
	Anal1, Anal2,left(Anal3,50), Anal4,Anal5,left(Anal6,50), Anal7,Anal8,Anal9, Anal11
	FROM #Delivered  d
	inner join @outputTRX o on o.reference=d.Reference

	update th set th.old_trxid= o.trxid from trxheader th join @outputTRX o on th.trxid=o.Old_Trxid
	 
	update SSISHelper.OrderFulfillment set [status]=2 where [status]=1 --Received and ready to Email
	--select * from TrxHeader th join trxdetail td on th.trxid =td.trxid order by th.trxid desc

End