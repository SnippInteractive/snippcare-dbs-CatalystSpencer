CREATE Procedure [SSISHelper].[Unregistered] (@WelcomeMessage int=0) as 
/*

For UNREGISTERED Devices, run two different processes.
1. First transaction done where Stamps are granted, >> then we run to find these SSISHelper.Unregistered 1
2. After a period in time, the person still has not registered > where as reminders are with SSISHelper.Unregistered 0
*/


Begin

	declare @clientid int, @ClientName nvarchar(50)= 'spencer'
	select @clientid = clientid  from client where name = @ClientName
	
	drop table if exists #Selection 
	drop table if exists #WhichDevices
	drop table if exists #WhichDevicesStamps
	drop table if exists #ToSendPunchesExpiry
	drop table if exists #ToSendAllOthers
	
	select min (th.trxid) FirstTrxID, dv.deviceid, dv.ExtraInfo as Recipient
	into #WhichDevices
	from device dv  
	join trxheader th   on dv.deviceid=th.deviceid 
	join devicestatus ds  on ds.devicestatusid = dv.devicestatusid 
	join trxtype tt  on tt.trxtypeid=th.trxtypeid
	join trxstatus ts  on ts.trxstatusid=th.trxstatustypeid
	join trxdetail td  on th.trxid=td.trxid
	join site s  on s.siteid = dv.homesiteid
	where dv.userid is null and isnull(dv.ExtraInfo,'') !='' and s.clientid=@clientid and ds.name = 'Active'
	and ts.name ='Completed' and tt.name ='PosTransaction' 
	and datediff(day,th.trxdate ,getdate()) < 45	
	and th.TrxId > 19751026 --UPDATE WHEN MOVE TO PROD
	group by dv.deviceid, dv.ExtraInfo, tt.name , ts.name
	
--	Update th set th.istransferred = null from trxheader th join #WhichDevices ts on ts.FirstTrxID=th.trxid
	
	--niall add a plus 1
	if @WelcomeMessage = 1
	Begin
		select wd.*, th.trxdate, n.*, istransferred into #ToSendPunchesExpiry from #WhichDevices wd join trxheader th on th.trxid=wd.FirstTrxID 
		join (
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt  join NotificationTemplateType ntt  
		on nt.NotificationTemplateTypeid=ntt.id where nt.Name='PunchesExpiry' 
		) n on 1=1
		where th.istransferred is null
		Update th set th.istransferred = 1 from trxheader th join #ToSendPunchesExpiry ts on ts.FirstTrxID=th.trxid

		update #ToSendPunchesExpiry set PlaceHolders = (SELECT Content FROM OpenJson(PlaceHolders)WITH (Content NVARCHAR(MAX) '$.Content')) 	
		where NotificationType='SMS' AND ISJSON(placeholders) = 1 

		update #ToSendPunchesExpiry set PlaceHolders = (SELECT Body FROM OpenJson(PlaceHolders)WITH (Body NVARCHAR(MAX) '$.Body')) 	
		where NotificationType='Push' AND ISJSON(placeholders) = 1 

		INSERT INTO NotificationsToSend(Version,ClientID,Recipient,	NotificationType,NotificareTemplateId,NotificareTemplateName,PlaceHolders,TrxID,SentDate)
		select 0 AS Version,@clientid AS ClientID, Recipient AS Recipient,NotificationType, NotificareTemplateId,NotificareTemplateId AS NotificareTemplateName,PlaceHolders,FirstTrxID,getdate() 
		from #ToSendPunchesExpiry 
		/*
		update NotificationsToSend set placeholders = (SELECT Content FROM OpenJson(placeholders)WITH (Content NVARCHAR(MAX) '$.Content')) 	
		where SentDate is null and NotificationType='SMS' AND ISJSON(placeholders) = 1 

		update NotificationsToSend set placeholders = (SELECT Body FROM OpenJson(placeholders)WITH (Body NVARCHAR(MAX) '$.Body')) 	
		where SentDate is null and NotificationType='Push' AND ISJSON(placeholders) = 1 

		*/
		select Recipient, PlaceHolders,Name,NotificareTemplateId, NotificationType from #ToSendPunchesExpiry --FOR JSON AUTO 
		--select top 5 Recipient, PlaceHolders,'PunchesExpiry',NotificareTemplateId, NotificationType from NotificationsToSend --test query
	End
	/*else SPencer doesn't want the SMS part for this message type 
	Begin
		select min (th.trxid) FirstTrxID, dv.deviceid, dv.ExtraInfo as Recipient
		into #WhichDevicesStamps
		from device dv 
		join trxheader th  on dv.deviceid=th.deviceid 
		join devicestatus ds on ds.devicestatusid = dv.devicestatusid 
		join trxtype tt on tt.trxtypeid=th.trxtypeid
		join trxstatus ts on ts.trxstatusid=th.trxstatustypeid
		join trxdetail td on th.trxid=td.trxid
		join TrxDetailStampCard tds  on td.trxdetailid = tds.trxdetailid
		join site s on s.siteid = dv.homesiteid
		where dv.userid is null and isnull(dv.ExtraInfo,'') !='' and s.clientid=1 and ds.name = 'Active'
		and ts.name ='Completed' and tt.name ='PosTransaction' 
		and datediff(day,th.trxdate ,getdate()) < 45
		--and dv.DeviceId in ('V76346199', 'V76534488')
		group by dv.deviceid, dv.ExtraInfo, tt.name , ts.name

		select DISTINCT wd.*, th.trxdate, case 45 -  datediff(day,th.trxdate,getdate())
			/*when 44 then '1DaysReminder'*/ -- SPencer doesn't want the SMS part for this message type 
			when 4 then '4DaysReminder'
			when 10 then '10DaysReminder'
			when 23 then '23DaysReminder'
			/*when 30 then '30DaysReminder'*/ -- SPencer doesn't want the SMS part for this message type  
			when 40 then '40DaysReminder'
			else 'NotToday'
			end as TemplateName, 
		batch_URN, IsTransferred 
		into #ToSendAllOthers 
		from #WhichDevicesStamps wd 
		join trxheader th  on th.trxid=wd.FirstTrxID 
		join TrxDetail td  on td.trxid = th.trxid
		join TrxDetailStampCard tds  on td.trxdetailid = tds.trxdetailid	
		
		select wd.FirstTrxID, Recipient, n.NotificareTemplateId,NotificationType, n.Placeholders, n.name into #Selection from 
		#ToSendAllOthers wd left join (
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt  join NotificationTemplateType ntt  
		on nt.NotificationTemplateTypeid=ntt.id 
		) n on wd.TemplateName = n.name and wd.TemplateName !=isnull(batch_urn,'') collate database_default

		delete from #selection where Name is null

		Update th set th.Batch_Urn = ts.NotificareTemplateId from trxheader th join #Selection ts on ts.FirstTrxID=th.trxid
		select  Recipient, PlaceHolders,Name,NotificareTemplateId, NotificationType from #Selection 
		/*
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt join NotificationTemplateType ntt
		on nt.NotificationTemplateTypeid=ntt.id where nt.Name!='PunchesExpiry' 
		*/
		--Update th set th.istransferred = 1 from trxheader th join #toSend ts on ts.FirstTrxID=th.trxid
		
	End
	*/
	--ExtraInfo as Recipient
	--NotificationTemplate.PlaceHolders
	--NotificationTemplate.Name

	--Batch_Urn To put in the template that was used last.

	drop table if exists #WhichDevicesStamps
	drop table if exists #WhichDevices
	drop table if exists #ToSendAllOthers
	drop table if exists #ToSendPunchesExpiry
	drop table if exists #Selection 
	
End

