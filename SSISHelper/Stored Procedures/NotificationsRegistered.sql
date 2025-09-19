--truncate table NotificationsToSend 
--select * from NotificationsToSend where userid = 1404999
--delete from NotificationsToSend where userid = 1404999
--exec [SSISHelper].[NotificationsRegistered]  1,1,1,1,0,0
--exec [SSISHelper].[NotificationsRegistered_WIP]  0,0,0,0,1
--exec [SSISHelper].[NotificationsRegistered_WIP]  0,1,1,1,1

CREATE Procedure [SSISHelper].[NotificationsRegistered] (
@ProfileUpdated bit, @NewPunches bit, @PunchCardFull bit, @JustRedeemed bit, @PunchesLeft bit,@RegisterationPromo bit) as 
/*

For REGISTERED Devices, run two different processes.
1. If the @Profile is selected then the Audit is checked for the values of
'Street','City','AddressLine2','AddressStatusId','Firstname','Phone','MobilePhone','HouseName','PostBox',
		'Lastname','AddressLine1','ContactByEmail','Zip'
	To see if there is a change
	Based on the NotificationTemplate table, 
		if there is a template for the SMS  then we select the mobile number, 
		if email then the email address
		For PUSH, I do not know what to do!
	The table the info is stored in is called the NotificationsToSend and 
	there is a field called SentDate, if this is null then it has not been sent out yet.
2.
3.
4.
5. Reminder for amount of punches left on a card

*/


Begin
--BEGIN TRAN
	declare @clientid int, @ClientName nvarchar(50)= 'spencer'
	Declare @MaxAuditId int, @MaxTrxID int
	select @clientid = clientid  from client where [name] = @ClientName
	
	DECLARE @HardCodedTrxId INT = 19751026 --UPDATE WHEN MOVE TO PROD
	DECLARE @HardCodedUserId INT = 2107722 --UPDATE WHEN MOVE TO PROD
	--DECLARE @HardCodedDate DateTime = dateadd(ms, -1, (dateadd(day, -3, convert(varchar, DATEADD(MONTH, -1, GETDATE()), 101)))) -- UPDATE WHEN MOVE TO PROD 

	DECLARE  @UserData TABLE (UserId INT, PunchType NVARCHAR(50))

	if @ProfileUpdated = 1
	Begin
		drop table if exists #AccountInformation_Users
		drop table if exists #AccountInformation_Users_WithTemplates 

		select @MaxAuditId = isnull(max(auditid),0) from [NotificationsToSend]  with(nolock) where  NotificareTemplateName ='AccountInformation' 

		select a.userid, Max(a.AuditID) LastAudit into #AccountInformation_Users
		from audit a 
		join site s  with(nolock) on s.siteid = a.siteid 
		where auditid>@Maxauditid and s.clientid = @clientid 
		and fieldname in ('Street','City','AddressLine2','AddressStatusId','Firstname','Phone','MobilePhone','HouseName','PostBox',
		'Lastname','AddressLine1','ContactByEmail','Zip','email')
		group by a.userid

		--select fieldname, count(auditid) from audit where ChangeDate > '2023-02-01' group by fieldname
		select au.*, uled.propertyvalue as ContactPreferences,uled2.PropertyValue as FCMDeviceTokens ,n.* into #AccountInformation_Users_WithTemplates 
		from #AccountInformation_Users au  with(nolock) join [user] u  with(nolock) on au.userid = u.userid
		join userloyaltyextensiondata uled  with(nolock) on uled.userloyaltydataid = u.userloyaltydataid and uled.propertyname = 'NotificationAndReminderJSON'
		left join userloyaltyextensiondata uled2  with(nolock) on uled2.userloyaltydataid = u.userloyaltydataid and uled2.propertyname = 'FCMDeviceTokens'
		join (
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt  with(nolock) join NotificationTemplateType ntt  with(nolock)
		on nt.NotificationTemplateTypeid=ntt.id where nt.Name='AccountInformation' 
		) n on 1=1
		
		insert into NotificationsToSend (
		Version, Clientid,userid, 
		Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		--isnull(cd.mobilephone,phone ),
		case when left(isnull(cd.mobilephone,phone ),1) = '+' then isnull(cd.mobilephone,phone ) else '+1' + ltrim(convert(nvarchar(50),isnull(cd.mobilephone,phone))) end, 
		t.NotificationType,t.NotificareTemplateId, t.[name],t.LastAudit,null,null,t.ContactPreferences, t.placeholders
		from #AccountInformation_Users_WithTemplates t  with(nolock)
		join UserContactDetails ucd  with(nolock) on t.userid=ucd.userid
		join contactdetails cd  with(nolock) on cd.contactdetailsid=ucd.contactdetailsid
		where (isnull(cd.mobilephone,'') !='' or isnull(cd.Phone,'') !='') and notificationtype='sms'
		
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		FCMDeviceTokens, 
		t.NotificationType,t.NotificareTemplateId, t.[name],t.LastAudit,null,null,t.ContactPreferences, t.placeholders
		from #AccountInformation_Users_WithTemplates t
		where isnull(FCMDeviceTokens,'') !='' and notificationtype='push'
		
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,cd.Email,t.NotificationType,t.NotificareTemplateId, t.[name],t.LastAudit,null,null,t.ContactPreferences, t.placeholders
		from #AccountInformation_Users_WithTemplates t  with(nolock)
		join UserContactDetails ucd  with(nolock) on t.userid=ucd.userid
		join contactdetails cd  with(nolock) on cd.contactdetailsid=ucd.contactdetailsid
		where isnull(cd.Email,'') !='' and notificationtype='email'
		
		update n set n.placeholders = 'FirstName=' + isnull(pd.Firstname,'') + '&LastName=' + isnull(pd.Lastname,'') from NotificationsToSend n join [user] u on u.userid=n.userid 
		join PersonalDetails pd on pd.personaldetailsid = u.personaldetailsid 		
		where SentDate is null and NotificationType='Email'
		--SPEN-T33
		update NotificationsToSend set placeholders = (SELECT Content FROM OpenJson(placeholders)WITH (Content NVARCHAR(MAX) '$.Content')) 	
		where SentDate is null and NotificationType='SMS' AND ISJSON(placeholders) = 1 

		update NotificationsToSend set placeholders = (SELECT Body FROM OpenJson(placeholders)WITH (Body NVARCHAR(MAX) '$.Body')) 	
		where SentDate is null and NotificationType='Push' AND ISJSON(placeholders) = 1 
		
		update NotificationsToSend set contactpreferences = replace(STUFF(SUBSTRING(contactpreferences,1,LEN(contactpreferences)-1),1,1,''),'\','') 
		where contactpreferences LIKE('%\%') and LEFT(contactpreferences, 1) = '"' and sentdate is null --AND NotificareTemplateId = 'AccountInformation'

		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='SMS' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[2].Scenarios[0].Notifications'),'$.SMS' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'AccountInformation'
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Email' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[2].Scenarios[0].Notifications'),'$.Email' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'AccountInformation'
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Push' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[2].Scenarios[0].Notifications'),'$.InApp' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'AccountInformation'
	End

/*		
{
"Notifications":
[
{"Id":1,"Title":"New Punches","Scenarios":[{"Event":"in-store",
	"Notifications":{"Email":false,"InApp":false,"SMS":false}}],"Active":true},
{"Id":2,"Title":"Free Items and Redemptions","Scenarios":[{"Event":"Free Merch Available",
	"Notifications":{"Email":false,"InApp":false,"SMS":false}},
{"Event":"Free Items Redeemed",
	"Notifications":{"Email":false,"InApp":false,"SMS":false}},
{"Event":"Punch Out Reminders",
	"Notifications":{"Email":false,"InApp":false,"SMS":false}}],"Active":true},
{"Id":3,"Title":"Account Settings",	"Scenarios":[{"Event":"Account Changes",
	"Notifications":{"Email":false,"InApp":false,"SMS":false}}],"Active":true}],
	"Reminders":[{"Id":1,"Title":"Free item",
		"Notifications":{"Email":false,"InApp":false,"SMS":false},"Active":true},
				 {"Id":2,"Title":"App Download - If App has not been downloaded",
		"Notifications":{"Email":false,"InApp":false,"SMS":false},"Active":true}
				 ]}

	*/
	if @PunchCardFull = 1 --SuccessfulPunchCardCompletion
	begin
	--Successful PunchCard Completion Yes! You scored some free merch! Check your Spencer's Nation app!
		drop table if exists #SuccessfulPunch_Users
		drop table if exists #SuccessfulPunch_Users_WithTemplates 

		select @MaxTrxID = isnull(max(TrxID),0) from [NotificationsToSend] where  NotificareTemplateName ='SuccessfulPunchCardCompletion' 
		
		select D.UserId, max(th.trxid) LastTrxID,DATEDIFF(day,getdate(),ISNULL(MAX(D.ExpirationDate),getdate())) AS ExpiryDays,psc.PromotionId 
		into #SuccessfulPunch_Users
		from trxheader th  with(nolock) join site s on s.siteid = th.SiteId
		join trxdetail td  with(nolock) on th.trxid=td.trxid
		join Device D  with(nolock) on D.EmbossLine2 = 'STAMP-' + CONVERT(VARCHAR(10),th.TrxId)
		join DeviceStatus DS  with(nolock) on D.DeviceStatusId = DS.DeviceStatusId
		join trxtype tt  with(nolock) on tt.trxtypeid=th.trxtypeid
		join TrxStatus ts  with(nolock)  on th.TrxStatusTypeId=ts.TrxStatusId
		join TrxDetailStampCard tds with(nolock) on td.TrxDetailID = tds.TrxDetailId
		join PromotionStampCounter psc with(nolock) on D.UserId = psc.UserId AND psc.TrxId = th.TrxId AND D.EmbossLine3 LIKE('%'+CONVERT(VARCHAR(15),psc.PromotionId)+'%')
		WHERE ISNULL(D.UserId,0) > 0 
		AND DS.Name = 'Active'
		AND D.ExpirationDate >= GETDATE()
		and s.clientid = @Clientid 
		and th.trxid > @MaxTrxID
		AND ts.Name = 'Completed'
		AND tt.name = 'PosTransaction'
		and th.TrxId > @HardCodedTrxId
		group by D.userid,psc.PromotionId 

		--INSERT INTO @UserData (UserId,PunchType) SELECT DISTINCT UserId ,'PunchCardFull' AS Type FROM #SuccessfulPunch_Users

		select au.*, uled.propertyvalue as ContactPreferences,uled2.PropertyValue as FCMDeviceTokens ,n.*, u.personaldetailsid 
		into #SuccessfulPunch_Users_WithTemplates 
		from #SuccessfulPunch_Users au  with(nolock) join [user] u  with(nolock) on au.userid = u.userid
		join userloyaltyextensiondata uled  with(nolock) on uled.userloyaltydataid = u.userloyaltydataid and uled.propertyname = 'NotificationAndReminderJSON'
		left join userloyaltyextensiondata uled2  with(nolock) on uled2.userloyaltydataid = u.userloyaltydataid and uled2.propertyname = 'FCMDeviceTokens'
		join (
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt  with(nolock) join NotificationTemplateType ntt  with(nolock)
		on nt.NotificationTemplateTypeid=ntt.id where nt.Name='SuccessfulPunchCardCompletion' 
		) n on 1=1
		
		update #SuccessfulPunch_Users_WithTemplates set Placeholders = replace(Placeholders,'(X)',convert(nvarchar(10),ExpiryDays)) 
		
		update #SuccessfulPunch_Users_WithTemplates set Placeholders = 'ExpiryDays=' + CASE WHEN ISNULL(ExpiryDays,0) <= 0  THEN convert(nvarchar(10),ExpiryDays) + ' day' ELSE convert(nvarchar(10),ExpiryDays) + ' days' END + '&' where NotificationType = 'Email'

		/**** SPencer doesn't want the SMS part for this message type  
		insert into NotificationsToSend (
		Version, Clientid,userid, 
		Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		--isnull(cd.mobilephone,phone ),
		case when left(isnull(cd.mobilephone,phone ),1) = '+' then isnull(cd.mobilephone,phone ) else '+1' + ltrim(convert(nvarchar(50),isnull(cd.mobilephone,phone ))) end, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #SuccessfulPunch_Users_WithTemplates t
		join UserContactDetails ucd  with(nolock) on t.userid=ucd.userid
		join contactdetails cd  with(nolock) on cd.contactdetailsid=ucd.contactdetailsid
		where (isnull(cd.mobilephone,'') !='' or isnull(cd.Phone,'') !='') and notificationtype='sms'
		***/
		/**** AT-4162SPencer doesn't want this message type  
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		FCMDeviceTokens, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #SuccessfulPunch_Users_WithTemplates t  with(nolock)
		where isnull(FCMDeviceTokens,'') !='' and notificationtype='push'
		***/
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,cd.Email,t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences,
		ISNULL(t.placeholders,'') + 'FirstName=' + isnull(pd.FirstName collate database_default,'') --+ ',PunchRemaining='+convert(nvarchar(5),x) --t.placeholders
		from #SuccessfulPunch_Users_WithTemplates t  with(nolock)
		join UserContactDetails ucd  with(nolock) on t.userid=ucd.userid
		join contactdetails cd  with(nolock) on cd.contactdetailsid=ucd.contactdetailsid
		join PersonalDetails pd  with(nolock) on t.PersonalDetailsId=pd.PersonalDetailsId
		where isnull(cd.Email,'') !='' and notificationtype='email'
		--SPEN-T33
		update NotificationsToSend set placeholders = (SELECT Content FROM OpenJson(placeholders)WITH (Content NVARCHAR(MAX) '$.Content')) 	
		where SentDate is null and NotificationType='SMS' AND ISJSON(placeholders) = 1 

		update NotificationsToSend set placeholders = (SELECT Body FROM OpenJson(placeholders)WITH (Body NVARCHAR(MAX) '$.Body')) 	
		where SentDate is null and NotificationType='Push' AND ISJSON(placeholders) = 1 
		--update n set n.placeholders = n.placeholders + 'FirstName=' + isnull(pd.Firstname,'') + '&LastName=' + isnull(pd.Lastname,'') 
		--from NotificationsToSend n join [user] u on u.userid=n.userid 
		--join PersonalDetails pd on pd.personaldetailsid = u.personaldetailsid 		
		--where SentDate is null --and NotificationType='Email'

		update NotificationsToSend set contactpreferences = replace(STUFF(SUBSTRING(contactpreferences,1,LEN(contactpreferences)-1),1,1,''),'\','') 
		where contactpreferences LIKE('%\%') and LEFT(contactpreferences, 1) = '"' and sentdate is null --AND NotificareTemplateId = 'SuccessfulPunchCardCompletion'

		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='SMS' and   JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[0].Notifications'),'$.SMS' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'SuccessfulPunchCardCompletion'
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Email' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[0].Notifications'),'$.Email' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'SuccessfulPunchCardCompletion'
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Push' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[0].Notifications'),'$.InApp' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'SuccessfulPunchCardCompletion'
	end
	if @JustRedeemed = 1 --SuccessfulRewardCompletion
	BEGIN
		drop table if exists #SuccessfulRedemption_Users
		drop table if exists #SuccessfulRedemption_Users_WithTemplates 

		select @MaxTrxId = isnull(max(trxid),0) from [NotificationsToSend] where NotificareTemplateName='SuccessfulRewardCompletion'

		select D.UserId, max(th.trxid) LastTrxID 
		into #SuccessfulRedemption_Users
		from trxheader th  with(nolock) join site s on s.siteid = th.SiteId
		join trxdetail td  with(nolock) on th.trxid=td.trxid
		join TrxVoucherDetail tv  with(nolock) on td.TrxDetailID = tv.TrxDetailId
		join Device D  with(nolock) on D.DeviceId = tv.TrxVoucherId AND EmbossLine2 LIKE('STAMP-%')
		join DeviceStatus DS  with(nolock) on D.DeviceStatusId = DS.DeviceStatusId
		join trxtype tt  with(nolock) on tt.trxtypeid=th.trxtypeid
		join TrxStatus ts  with(nolock) on th.TrxStatusTypeId=ts.TrxStatusId
		--join TrxDetailStampCard tds on td.TrxDetailID = tds.TrxDetailId
		WHERE ISNULL(D.UserId,0) > 0
		AND DS.Name <> 'Active'
		and s.clientid = @clientid 
		and th.trxid > @MaxTrxId
		AND tt.name = 'PosTransaction'
		AND ts.Name = 'Completed'
		and th.TrxId > @HardCodedTrxId
		group by D.userid	

		--INSERT INTO @UserData (UserId,PunchType) SELECT DISTINCT UserId ,'JustRedeemed' AS Type FROM #SuccessfulRedemption_Users 

		select au.*, uled.propertyvalue as ContactPreferences,uled2.PropertyValue as FCMDeviceTokens ,n.*, u.personaldetailsid 
		into #SuccessfulRedemption_Users_WithTemplates 
		from #SuccessfulRedemption_Users au  with(nolock) join [user] u  with(nolock) on au.userid = u.userid
		join userloyaltyextensiondata uled  with(nolock) on uled.userloyaltydataid = u.userloyaltydataid and uled.propertyname = 'NotificationAndReminderJSON'
		left join userloyaltyextensiondata uled2  with(nolock) on uled2.userloyaltydataid = u.userloyaltydataid and uled2.propertyname = 'FCMDeviceTokens'
		join (
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt  with(nolock) join NotificationTemplateType ntt  with(nolock)
		on nt.NotificationTemplateTypeid=ntt.id where nt.Name='SuccessfulRewardCompletion' 
		) n on 1=1

		--update #SuccessfulRedemption_Users_WithTemplates set Placeholders = 'PunchRemaining='+convert(nvarchar(10),PunchRemaining)+'&' where NotificationType = 'Email'
		/**** SPencer doesn't want the SMS part for this message type  
		insert into NotificationsToSend (
		Version, Clientid,userid, 
		Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		--isnull(cd.mobilephone,phone ),
		case when left(isnull(cd.mobilephone,phone ),1) = '+' then isnull(cd.mobilephone,phone ) else '+1' + ltrim(convert(nvarchar(50),isnull(cd.mobilephone,phone ))) end, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #SuccessfulRedemption_Users_WithTemplates t  with(nolock)
		join UserContactDetails ucd  with(nolock) on t.userid=ucd.userid
		join contactdetails cd with(nolock) on cd.contactdetailsid=ucd.contactdetailsid
		where (isnull(cd.mobilephone,'') !='' or isnull(cd.Phone,'') !='') and notificationtype='sms'
		*******/
		/**** AT-4162SPencer doesn't want this message type  
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		FCMDeviceTokens, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #SuccessfulRedemption_Users_WithTemplates t with(nolock)
		where isnull(FCMDeviceTokens,'') !='' and notificationtype='push'
		****/
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,cd.Email,t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, 
		'FirstName=' + isnull(pd.FirstName collate database_default,'')--t.placeholders
		from #SuccessfulRedemption_Users_WithTemplates t with(nolock)
		join UserContactDetails ucd with(nolock) on t.userid=ucd.userid
		join contactdetails cd with(nolock) on cd.contactdetailsid=ucd.contactdetailsid
		join PersonalDetails pd with(nolock) on t.PersonalDetailsId=pd.PersonalDetailsId
		where isnull(cd.Email,'') !='' and notificationtype='email'
		--SPEN-T33
		update NotificationsToSend set placeholders = (SELECT Content FROM OpenJson(placeholders)WITH (Content NVARCHAR(MAX) '$.Content')) 	
		where SentDate is null and NotificationType='SMS' AND ISJSON(placeholders) = 1 

		update NotificationsToSend set placeholders = (SELECT Body FROM OpenJson(placeholders)WITH (Body NVARCHAR(MAX) '$.Body')) 	
		where SentDate is null and NotificationType='Push' AND ISJSON(placeholders) = 1 

		update NotificationsToSend set contactpreferences = replace(STUFF(SUBSTRING(contactpreferences,1,LEN(contactpreferences)-1),1,1,''),'\','') 
		where contactpreferences LIKE('%\%') and LEFT(contactpreferences, 1) = '"' and sentdate is null --AND NotificareTemplateId = 'SuccessfulRewardCompletion'

		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='SMS' and   JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[1].Notifications'),'$.SMS' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'SuccessfulRewardCompletion'
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Email' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[1].Notifications'),'$.Email' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'SuccessfulRewardCompletion'
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Push' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[1].Notifications'),'$.InApp' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'SuccessfulRewardCompletion'

	END
	if @NewPunches = 1 --QualifyingPurchase
	Begin
		select @MaxTrxId = isnull(max(trxid),0) from [NotificationsToSend] where NotificareTemplateName='QualifyingPurchase'
		--if @PunchCardFull = 0 --SuccessfulPunchCardCompletion
		--begin
		--	select @MaxTrxID = isnull(max(TrxID),0) from [NotificationsToSend] where  NotificareTemplateName ='SuccessfulPunchCardCompletion' 
		
			INSERT INTO @UserData (UserId,PunchType)
			select D.UserId  ,'PunchCardFull' AS PunchType
			from trxheader th with(nolock) join site s on s.siteid = th.SiteId
			join trxdetail td with(nolock) on th.trxid=td.trxid
			join Device D with(nolock) on D.EmbossLine2 = 'STAMP-' + CONVERT(VARCHAR(10),th.TrxId)
			join DeviceStatus DS with(nolock) on D.DeviceStatusId = DS.DeviceStatusId
			join trxtype tt with(nolock) on tt.trxtypeid=th.trxtypeid
			join TrxStatus ts with(nolock)  on th.TrxStatusTypeId=ts.TrxStatusId
			join TrxDetailStampCard tds with(nolock) on td.TrxDetailID = tds.TrxDetailId
			WHERE ISNULL(D.UserId,0) > 0 
			AND DS.Name = 'Active'
			AND D.ExpirationDate >= GETDATE()
			and s.clientid = @Clientid 
			and th.trxid > @MaxTrxID
			AND ts.Name = 'Completed'
			AND tt.name = 'PosTransaction'
			and th.TrxId > @HardCodedTrxId
			group by D.userid	
		--END
		--if @JustRedeemed = 0 --SuccessfulRewardCompletion
		--BEGIN				
		--	select @MaxTrxId = isnull(max(trxid),0) from [NotificationsToSend] where NotificareTemplateName='SuccessfulRewardCompletion'
				
			INSERT INTO @UserData (UserId,PunchType)
			select D.UserId,'JustRedeemed' AS PunchType
			from trxheader th with(nolock) join site s on s.siteid = th.SiteId
			join trxdetail td with(nolock) on th.trxid=td.trxid
			join TrxVoucherDetail tv with(nolock) on td.TrxDetailID = tv.TrxDetailId
			join Device D with(nolock) on D.DeviceId = tv.TrxVoucherId AND EmbossLine2 LIKE('STAMP-%')
			join DeviceStatus DS with(nolock) on D.DeviceStatusId = DS.DeviceStatusId
			join trxtype tt with(nolock) on tt.trxtypeid=th.trxtypeid
			join TrxStatus ts with(nolock)  on th.TrxStatusTypeId=ts.TrxStatusId
			--join TrxDetailStampCard tds on td.TrxDetailID = tds.TrxDetailId
			WHERE ISNULL(D.UserId,0) > 0
			AND DS.Name <> 'Active'
			and s.clientid = @clientid 
			and th.trxid > @MaxTrxId
			AND tt.name = 'PosTransaction'
			AND ts.Name = 'Completed'
			and th.TrxId > @HardCodedTrxId
			group by D.userid	
		--END

		drop table if exists #PunchesEarned_Users
		drop table if exists #PunchesEarned_Users_WithTemplates 

		select @MaxTrxId = isnull(max(trxid),0) from [NotificationsToSend] where NotificareTemplateName='QualifyingPurchase'
		
		select X.PromotionId,D.UserId,Max(th.TrxId) LastTrxID,th.DeviceId,X.PunchEarned,0 AS PunchRemaining ,0 AS QualifyingProductQuantity,0 Balance
		into #PunchesEarned_Users
        from trxheader th with(nolock) join site s on s.siteid = th.SiteId
        join trxdetail td with(nolock) on th.trxid=td.trxid
        join trxtype tt with(nolock) on tt.trxtypeid=th.trxtypeid
		join Device D with(nolock) on th.DeviceId = D.DeviceId
		join TrxStatus ts with(nolock)  on th.TrxStatusTypeId=ts.TrxStatusId
		--join PromotionStampCounter psc on D.UserId = psc.UserId 
        join (select sum (ValueUsed) PunchEarned,TrxId,tds.PromotionId 
                FROM TrxDetailStampCard tds inner join TrxDetail td on tds.TrxDetailId = td.TrxDetailID
   				where  ISNULL(PunchTrXType,0) < 3
                Group By TrxId, tds.PromotionId HAVING sum(ValueUsed) > 0) X  ON X.TrxID = td.TrxID
        WHERE ISNULL(D.UserId,0) > 0 
		and th.trxid > @MaxTrxId
        AND tt.name = 'PosTransaction'
		AND ts.Name = 'Completed'
		and s.clientid = @clientid
		and th.TrxId > @HardCodedTrxId
        Group  BY X.PromotionId, D.UserId,th.DeviceId,PunchEarned

		DROP TABLE IF EXISTS  #TopPunchesEarned_Users

		SELECT PromotionId,UserId,Max(LastTrxID)LastTrxID,DeviceId
		INTO #TopPunchesEarned_Users
		FROM #PunchesEarned_Users Group By PromotionId,UserId,DeviceId

		DELETE FROM #PunchesEarned_Users WHERE LastTrxID NOT IN (SELECT LastTrxID FROM #TopPunchesEarned_Users)

		DROP TABLE IF EXISTS  #TopPunchesEarned_Users

		update PE set PE.PunchRemaining = ISNULL(psc.AfterValue,0),
		PE.QualifyingProductQuantity = P.QualifyingProductQuantity, Balance = ISNULL(P.QualifyingProductQuantity,0)  - ISNULL(psc.AfterValue,0)
		from #PunchesEarned_Users PE 
		join PromotionStampCounter psc on PE.UserId = psc.UserId AND psc.PromotionId = PE.PromotionId
		join promotion P on PE.PromotionId = P.Id
        WHERE ISNULL(PE.UserId,0) > 0 AND  ISNULL(psc.UserId,0) > 0

		UPDATE #PunchesEarned_Users SET Balance = QualifyingProductQuantity WHERE Balance <= 0

		select au.*, uled.propertyvalue as ContactPreferences,uled2.PropertyValue as FCMDeviceTokens ,n.*, u.personaldetailsid 
		into #PunchesEarned_Users_WithTemplates 
		from #PunchesEarned_Users au with(nolock) join [user] u with(nolock) on au.userid = u.userid
		join userloyaltyextensiondata uled with(nolock) on uled.userloyaltydataid = u.userloyaltydataid and uled.propertyname = 'NotificationAndReminderJSON'
		left join userloyaltyextensiondata uled2 with(nolock) on uled2.userloyaltydataid = u.userloyaltydataid and uled2.propertyname = 'FCMDeviceTokens'
		join (
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt join NotificationTemplateType ntt
		on nt.NotificationTemplateTypeid=ntt.id where nt.Name='QualifyingPurchase' 
		) n on 1=1
		
		--SELECT * FROM #PunchesEarned_Users_WithTemplates
		update #PunchesEarned_Users_WithTemplates set Placeholders = '' where NotificationType = 'Email'

		update #PunchesEarned_Users_WithTemplates set Placeholders = replace(Placeholders,'(X)',convert(nvarchar(10),PunchRemaining)) Where isnull(PunchRemaining,0) > 1 AND UserId IN (SELECT DISTINCT Userid FROM @UserData WHERE PunchType = 'PunchCardFull')
		--update #PunchesEarned_Users_WithTemplates set Placeholders = replace(Placeholders,'(X)',convert(nvarchar(10),PunchEarned)) where isnull(PunchEarned,0) > 0 AND UserId IN (SELECT DISTINCT Userid FROM @UserData WHERE PunchType = 'PunchCardFull')
		update #PunchesEarned_Users_WithTemplates set Placeholders = 'PunchEarned=' + convert(nvarchar(10),PunchRemaining)+'&PunchRemaining='+convert(nvarchar(10),Balance)+'&' where ISNULL(PunchRemaining,0) > 1 AND NotificationType = 'Email' AND UserId IN (SELECT DISTINCT Userid FROM @UserData WHERE PunchType = 'PunchCardFull')

	
		update #PunchesEarned_Users_WithTemplates set Placeholders = replace(Placeholders,'(X)',convert(nvarchar(10),PunchRemaining)) Where isnull(PunchRemaining,0) > 1 AND UserId IN (SELECT DISTINCT Userid FROM @UserData WHERE PunchType = 'JustRedeemed')
		--update #PunchesEarned_Users_WithTemplates set Placeholders = replace(Placeholders,'(X)',convert(nvarchar(10),PunchEarned)) where isnull(PunchEarned,0) > 0 AND UserId IN (SELECT DISTINCT Userid FROM @UserData WHERE PunchType = 'JustRedeemed')
		update #PunchesEarned_Users_WithTemplates set Placeholders = 'PunchEarned=' + convert(nvarchar(10),PunchRemaining)+'&PunchRemaining='+convert(nvarchar(10),Balance)+'&' where ISNULL(PunchRemaining,0) > 1 AND NotificationType = 'Email' AND UserId IN (SELECT DISTINCT Userid FROM @UserData WHERE PunchType = 'JustRedeemed')

		--SELECT * FROM #PunchesEarned_Users_WithTemplates
		
		update #PunchesEarned_Users_WithTemplates set Placeholders = replace(Placeholders,'(X)',convert(nvarchar(10),PunchEarned)) where isnull(PunchEarned,0) > 0 AND UserId NOT IN (SELECT DISTINCT Userid FROM @UserData)

		DELETE #PunchesEarned_Users_WithTemplates WHERE Placeholders Like('%(X)%')

		update #PunchesEarned_Users_WithTemplates set Placeholders = 'PunchEarned=' + convert(nvarchar(10),PunchEarned)+'&PunchRemaining='+convert(nvarchar(10),Balance)+'&' 
		where NotificationType = 'Email' AND ISNULL(PunchEarned,0) > 0 AND isnull(Placeholders,'') = '' AND UserId NOT IN (SELECT DISTINCT Userid FROM @UserData)

		DELETE #PunchesEarned_Users_WithTemplates WHERE ISNULL(Placeholders,'') = ''
		
		--SELECT * FROM #PunchesEarned_Users_WithTemplates
		/**** SPencer doesn't want the SMS part for this message type  
		insert into NotificationsToSend (
		Version, Clientid,userid, 
		Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		--isnull(cd.mobilephone,phone ),
		case when left(isnull(cd.mobilephone,phone ),1) = '+' then isnull(cd.mobilephone,phone ) else '+1' + ltrim(convert(nvarchar(50),isnull(cd.mobilephone,phone ))) end, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #PunchesEarned_Users_WithTemplates t with(nolock)
		join UserContactDetails ucd with(nolock) on t.userid=ucd.userid
		join contactdetails cd with(nolock) on cd.contactdetailsid=ucd.contactdetailsid
		where (isnull(cd.mobilephone,'') !='' or isnull(cd.Phone,'') !='') and notificationtype='sms'
		***/
		/****AT-4162 SPencer doesn't want this message type 
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		FCMDeviceTokens, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #PunchesEarned_Users_WithTemplates t with(nolock)
		where isnull(FCMDeviceTokens,'') !='' and notificationtype='push'
		*****/
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,cd.Email,t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, 
		ISNULL(t.placeholders,'') + 'FirstName=' + isnull(pd.FirstName collate database_default,'')--t.placeholders
		from #PunchesEarned_Users_WithTemplates t with(nolock)
		join UserContactDetails ucd with(nolock) on t.userid=ucd.userid
		join contactdetails cd with(nolock) on cd.contactdetailsid=ucd.contactdetailsid
		join PersonalDetails pd with(nolock) on t.PersonalDetailsId=pd.PersonalDetailsId
		where isnull(cd.Email,'') !='' and notificationtype='email'
		--SPEN-T33
		update NotificationsToSend set placeholders = (SELECT Content FROM OpenJson(placeholders)WITH (Content NVARCHAR(MAX) '$.Content')) 	
		where SentDate is null and NotificationType='SMS' AND ISJSON(placeholders) = 1 

		update NotificationsToSend set placeholders = (SELECT Body FROM OpenJson(placeholders)WITH (Body NVARCHAR(MAX) '$.Body')) 	
		where SentDate is null and NotificationType='Push' AND ISJSON(placeholders) = 1 
		
		update NotificationsToSend set contactpreferences = replace(STUFF(SUBSTRING(contactpreferences,1,LEN(contactpreferences)-1),1,1,''),'\','') 
		where contactpreferences LIKE('%\%') and LEFT(contactpreferences, 1) = '"' and sentdate is null  --AND NotificareTemplateId = 'QualifyingPurchase'

		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='SMS' and   JSON_Value ( JSON_query(contactpreferences, '$.Notifications[0].Scenarios[0].Notifications'),'$.SMS' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'QualifyingPurchase'
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Email' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[0].Scenarios[0].Notifications'),'$.Email' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'QualifyingPurchase'
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Push' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[0].Scenarios[0].Notifications'),'$.InApp' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'QualifyingPurchase'

	End
	if @PunchesLeft = 1 --ReminderToCompletePunches
	Begin
		PRINT 'ReminderToCompletePunches'
		drop table if exists #PunchesLeft_Users
		drop table if exists #PunchesLeft_Users_WithTemplates 
		drop table if exists #ExcludeUserIds
		--select * from [NotificationsToSend] 
		--Declare @MaxTrxid int
		--select @MaxTrxId = isnull(max(trxid),0) from [NotificationsToSend] where NotificareTemplateName='ReminderToCompletePunches'
		
		DECLARE @ReminderToCompletePunches Datetime = dateadd(ms, -1, (dateadd(day, +1, convert(varchar, DATEADD(MONTH, -1, GETDATE()), 101)))) --2023-07-16 00:00:00.000

		SELECT DISTINCT UserId INTO #ExcludeUserIds FROM [NotificationsToSend] where NotificareTemplateName='ReminderToCompletePunches' AND SentDate >= @ReminderToCompletePunches
		AND UserId > @HardCodedUserId

		SELECT * INTO #PunchesLeft_Users FROM
		(select P.ID,Psc.UserId,Max(th.TrxId) LastTrxID,MAX(trxdate) LastTrx ,MAX(ISNULL(P.QualifyingProductQuantity,0) - ISNULL(psc.AfterValue,0)) AS PunchRemaining,MAX(P.QualifyingProductQuantity) QualifyingProductQuantity
        from trxheader th with(nolock) join site s on s.siteid = th.SiteId
        join trxtype tt with(nolock) on tt.trxtypeid=th.trxtypeid
		join Device D with(nolock) on th.DeviceId = D.DeviceId
        join TrxStatus ts with(nolock)  on th.TrxStatusTypeId=ts.TrxStatusId
		join PromotionStampCounter psc with(nolock) on D.UserId=psc.UserId
        join promotion P with(nolock) on psc.PromotionId = P.Id
		LEFT JOIN #ExcludeUserIds EU with(nolock) on Psc.UserId = EU.UserId
        WHERE ISNULL(psc.UserId,0) > 0 
		AND ISNULL(P.QualifyingProductQuantity,0) > 0 AND ISNULL(psc.AfterValue ,0) > 0
        AND (ISNULL(P.QualifyingProductQuantity,0) - ISNULL(psc.AfterValue,0)) > 0	
		--and th.trxid > @MaxTrxId
		and tt.name = 'PosTransaction'
		AND ts.Name = 'Completed'
		and th.TrxId > @HardCodedTrxId
		and s.clientid = @clientid
		and EU.UserId IS NULL
		and D.UserId > @HardCodedUserId
		group by th.clientid,P.ID,Psc.UserId)X
		WHERE LastTrx < @ReminderToCompletePunches 
		
		UPDATE #PunchesLeft_Users SET PunchRemaining = ISNULL(QualifyingProductQuantity,0) WHERE ISNULL(PunchRemaining,0) = 0

		select au.*, uled.propertyvalue as ContactPreferences,uled2.PropertyValue as FCMDeviceTokens ,n.*, u.personaldetailsid 
		into #PunchesLeft_Users_WithTemplates 
		from #PunchesLeft_Users au with(nolock) join [user] u with(nolock) on au.userid = u.userid
		join userloyaltyextensiondata uled with(nolock) on uled.userloyaltydataid = u.userloyaltydataid and uled.propertyname = 'NotificationAndReminderJSON'
		left join userloyaltyextensiondata uled2 with(nolock) on uled2.userloyaltydataid = u.userloyaltydataid and uled2.propertyname = 'FCMDeviceTokens'
		join (
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt with(nolock) join NotificationTemplateType ntt with(nolock)
		on nt.NotificationTemplateTypeid=ntt.id where nt.Name='ReminderToCompletePunches' 
		) n on 1=1

		update #PunchesLeft_Users_WithTemplates set Placeholders = replace(Placeholders,'(X)',convert(nvarchar(10),PunchRemaining)) --where NotificationType = 'Email'
		update #PunchesLeft_Users_WithTemplates set Placeholders = 'PunchRemaining='+convert(nvarchar(10),PunchRemaining)+'&' where NotificationType = 'Email'
		/**** AT-4162SPencer doesn't want this message type  
		insert into NotificationsToSend (
		Version, Clientid,userid, 
		Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select DISTINCT 1, @clientid, t.userid,
		--isnull(cd.mobilephone,phone ),
		case when left(isnull(cd.mobilephone,phone ),1) = '+' then isnull(cd.mobilephone,phone ) else '+1' + ltrim(convert(nvarchar(50),isnull(cd.mobilephone,phone ))) end, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #PunchesLeft_Users_WithTemplates t with(nolock)
		join UserContactDetails ucd with(nolock)on t.userid=ucd.userid
		join contactdetails cd with(nolock) on cd.contactdetailsid=ucd.contactdetailsid
		where (isnull(cd.mobilephone,'') !='' or isnull(cd.Phone,'') !='') and notificationtype='sms'
		***/
		/**** AT-4162SPencer doesn't want this message type  
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select DISTINCT 1, @clientid, t.userid,
		FCMDeviceTokens, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #PunchesLeft_Users_WithTemplates t with(nolock)
		where isnull(FCMDeviceTokens,'') !='' and notificationtype='push'
		****/
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select DISTINCT 1, @clientid, t.userid,cd.Email,t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, 
		ISNULL(t.placeholders,'') + 'FirstName=' + isnull(pd.FirstName collate database_default,'')--t.placeholders
		from #PunchesLeft_Users_WithTemplates t with(nolock)
		join UserContactDetails ucd with(nolock) on t.userid=ucd.userid
		join contactdetails cd with(nolock) on cd.contactdetailsid=ucd.contactdetailsid
		join PersonalDetails pd with(nolock)on t.PersonalDetailsId=pd.PersonalDetailsId
		where isnull(cd.Email,'') !='' and notificationtype='email'
		--SPEN-T33
		update NotificationsToSend set placeholders = (SELECT Content FROM OpenJson(placeholders)WITH (Content NVARCHAR(MAX) '$.Content')) 	
		where SentDate is null and NotificationType='SMS' AND ISJSON(placeholders) = 1 

		update NotificationsToSend set placeholders = (SELECT Body FROM OpenJson(placeholders)WITH (Body NVARCHAR(MAX) '$.Body')) 	
		where SentDate is null and NotificationType='Push' AND ISJSON(placeholders) = 1 

		update NotificationsToSend set contactpreferences = replace(STUFF(SUBSTRING(contactpreferences,1,LEN(contactpreferences)-1),1,1,''),'\','') 
		where contactpreferences LIKE('%\%') and LEFT(contactpreferences, 1) = '"' and sentdate is null --AND NotificareTemplateId = 'ReminderToCompletePunches'
		
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='SMS' and   JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[2].Notifications'),'$.SMS' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'ReminderToCompletePunches'
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Email' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[2].Notifications'),'$.Email' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'ReminderToCompletePunches'
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Push' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[2].Notifications'),'$.InApp' ) ='false'
		and sentdate is null AND NotificareTemplateName = 'ReminderToCompletePunches'


	End
	if @RegisterationPromo = 1 --send delayed  registeration voucher notification 
	begin
	Declare @DelayInDays int=0,@TemplateId nvarchar(50)
	drop table if exists #Register_Voucher_Users	
	--get delay in days and emailtemplateid 
	select  @DelayInDays =JSON_VALUE(p.Config,'$."DelayInDays"'),@TemplateId = nt.NotificareTemplateId from NotificationTemplate nt 
	inner join Promotion p on p.EmailTemplateId = nt.Id
	where nt.Name='RegisterationVoucherPromotion' and p.PromotionCategoryId in (Select Id from PromotionCategory where Name='Registration' and ClientId=@clientid)	
	-- IF Email template set on Voucher Registeration Promo ,do selection for sending notification
		IF LEN(@TemplateId) > 0
		BEGIN 

		select @MaxTrxId = isnull(max(trxid),0) from [NotificationsToSend] where NotificareTemplateId=@TemplateId

			select distinct th.DeviceId,th.TrxId LastTrxID 
			into #Register_Voucher_Users
       		from trxheader th with(nolock)
			join Device D with(nolock) on th.DeviceId = D.DeviceId
			join TrxDetail td on th.TrxId=td.TrxID and td.Anal1='Voucher' and ItemCode='Registration'
       		join trxtype tt with(nolock) on tt.trxtypeid=th.trxtypeid		
       		join TrxStatus ts with(nolock)  on th.TrxStatusTypeId=ts.TrxStatusId
       		WHERE 
				th.trxid > @MaxTrxId
			AND ts.Name = 'Completed'
			and ts.clientid = @clientid
			and tt.Name ='Activity'
			and th.TrxId > @HardCodedTrxId
			--getting all voucher registertion transaction with trxdate < today and trxid > @MaxTrxId
			and  Dateadd(DAY,-@DelayInDays,Convert(date, getdate())) >=  Convert(date,th.trxdate)  
			--group by th.DeviceId
		
		
			drop table if exists #Register_Users_WithTemplates
			select au.*, uled.propertyvalue as ContactPreferences,uled2.PropertyValue as FCMDeviceTokens ,n.*, u.personaldetailsid,u.UserId 
			into #Register_Users_WithTemplates 
			from #Register_Voucher_Users au with(nolock) join DEvice d on d.DeviceId =au.DeviceId inner join [user] u with(nolock) on d.UserId = u.userid
			join userloyaltyextensiondata uled with(nolock) on uled.userloyaltydataid = u.userloyaltydataid and uled.propertyname = 'NotificationAndReminderJSON'
			left join userloyaltyextensiondata uled2 with(nolock) on uled2.userloyaltydataid = u.userloyaltydataid and uled2.propertyname = 'FCMDeviceTokens'
			join (
			select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt with(nolock) join NotificationTemplateType ntt with(nolock)
			on nt.NotificationTemplateTypeid=ntt.id where nt.NotificareTemplateId=@TemplateId -- template id of RegisterationVoucherPromotion
			) n on 1=1

			--select * from #Register_Users_WithTemplates
		
			insert into NotificationsToSend (
			Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
			select 1, @clientid, t.userid,cd.Email,t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, 
			 'FirstName=' + isnull(pd.FirstName collate database_default,'')--t.placeholders
			from #Register_Users_WithTemplates t with(nolock)
			join UserContactDetails ucd with(nolock) on t.userid=ucd.userid
			join contactdetails cd with(nolock) on cd.contactdetailsid=ucd.contactdetailsid
			join PersonalDetails pd with(nolock)on t.PersonalDetailsId=pd.PersonalDetailsId
			where isnull(cd.Email,'') !='' and notificationtype='email'
			--SPEN-T33
			update NotificationsToSend set placeholders = (SELECT Content FROM OpenJson(placeholders)WITH (Content NVARCHAR(MAX) '$.Content')) 	
			where SentDate is null and NotificationType='SMS' AND ISJSON(placeholders) = 1 

			update NotificationsToSend set placeholders = (SELECT Body FROM OpenJson(placeholders)WITH (Body NVARCHAR(MAX) '$.Body')) 	
			where SentDate is null and NotificationType='Push' AND ISJSON(placeholders) = 1 

			update NotificationsToSend set contactpreferences = replace(STUFF(SUBSTRING(contactpreferences,1,LEN(contactpreferences)-1),1,1,''),'\','') 
			where contactpreferences LIKE('%\%') and LEFT(contactpreferences, 1) = '"' and sentdate is null  and  NotificareTemplateId = @TemplateId
		
			--update sentdate ,so job won't send notification again
			--Update NotificationsToSend set sentdate = getdate() 
			--where NotificationType='Email' and  NotificareTemplateId = @TemplateId
			-- --JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[2].Notifications'),'$.Email' ) ='false'
			--and sentdate is null

		END
	end

	update NotificationsToSend set recipient = replace(replace(replace(replace(recipient,' ',''),'-',''),'(',''),')','') where SentDate is null and NotificationType='sms'
	
	select DISTINCT * from NotificationsToSend with(nolock) 	where SentDate is null 
	--select  DISTINCT top 2 * from NotificationsToSend with(nolock) 	where NotificationType = 'Push' and userid = 1405308 order by 1 desc --SentDate is null 
	
	update NotificationsToSend set sentdate = getdate() where SentDate is null
	
	drop table if exists #AccountInformation_Users
	drop table if exists #AccountInformation_Users_WithTemplates 
	drop table if exists #PunchesEarned_Users
	--drop table if exists #PunchesEarned_Users_SMS
	drop table if exists #PunchesEarned_Users_WithTemplates 
	--drop table if exists #PunchesEarned_Users_WithTemplates_SMS
	drop table if exists #PunchesLeft_Users
	drop table if exists #PunchesLeft_Users_WithTemplates 
	drop table if exists #SuccessfulPunch_Users
	drop table if exists #SuccessfulPunch_Users_WithTemplates 
	drop table if exists #SuccessfulRedemption_Users
	drop table if exists #SuccessfulRedemption_Users_WithTemplates 

	--SELECT* FROM @UserData
	--ROLLBACK TRAN
End
/*
select *from userloyaltyextensiondata where UserLoyaltyDataid in (
select userloyaltydataid from [user] where userid = 1404999)
*/

