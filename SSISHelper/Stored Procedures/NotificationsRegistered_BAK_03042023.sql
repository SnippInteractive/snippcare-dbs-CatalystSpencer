--truncate table NotificationsToSend 
--select * from NotificationsToSend where userid = 1404999
--delete from NotificationsToSend where userid = 1404999
--exec [SSISHelper].[NotificationsRegistered_WIP]  1,1,1,1,0
--exec [SSISHelper].[NotificationsRegistered_WIP]  0,0,0,0,1

CREATE Procedure [SSISHelper].[NotificationsRegistered_BAK_03042023] (
@ProfileUpdated bit, @NewPunches bit, @PunchCardFull bit, @JustRedeemed bit, @PunchesLeft bit) as 
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

	declare @clientid int, @ClientName nvarchar(50)= 'spencer'
	Declare @MaxAuditId int, @MaxTrxID int
	select @clientid = clientid  from client where [name] = @ClientName
	

	if @ProfileUpdated = 1
	Begin
		drop table if exists #AccountInformation_Users
		drop table if exists #AccountInformation_Users_WithTemplates 
		select @MaxAuditId = isnull(max(auditid),0) from [NotificationsToSend] where  NotificareTemplateName ='AccountInformation' 
		select a.userid, Max(a.AuditID) LastAudit into #AccountInformation_Users
		from audit a 
		join site s on s.siteid = a.siteid 
		where auditid>@Maxauditid and s.clientid = @clientid
		and fieldname in ('Street','City','AddressLine2','AddressStatusId','Firstname','Phone','MobilePhone','HouseName','PostBox',
		'Lastname','AddressLine1','ContactByEmail','Zip','email')
		group by a.userid
		--select fieldname, count(auditid) from audit where ChangeDate > '2023-02-01' group by fieldname
		select au.*, uled.propertyvalue as ContactPreferences,uled2.PropertyValue as FCMDeviceTokens ,n.* into #AccountInformation_Users_WithTemplates from #AccountInformation_Users au join [user] u on au.userid = u.userid
		join userloyaltyextensiondata uled on uled.userloyaltydataid = u.userloyaltydataid and uled.propertyname = 'NotificationAndReminderJSON'
		left join userloyaltyextensiondata uled2 on uled2.userloyaltydataid = u.userloyaltydataid and uled2.propertyname = 'FCMDeviceTokens'
		join (
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt join NotificationTemplateType ntt
		on nt.NotificationTemplateTypeid=ntt.id where nt.Name='AccountInformation' 
		) n on 1=1
		
		insert into NotificationsToSend (
		Version, Clientid,userid, 
		Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		--isnull(cd.mobilephone,phone ),
		case when left(isnull(cd.mobilephone,phone ),1) = '+' then isnull(cd.mobilephone,phone ) else '+1' + ltrim(convert(nvarchar(50),isnull(cd.mobilephone,phone))) end, 
		t.NotificationType,t.NotificareTemplateId, t.[name],t.LastAudit,null,null,t.ContactPreferences, t.placeholders
		from #AccountInformation_Users_WithTemplates t
		join UserContactDetails ucd on t.userid=ucd.userid
		join contactdetails cd on cd.contactdetailsid=ucd.contactdetailsid
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
		from #AccountInformation_Users_WithTemplates t
		join UserContactDetails ucd on t.userid=ucd.userid
		join contactdetails cd on cd.contactdetailsid=ucd.contactdetailsid
		where isnull(cd.Email,'') !='' and notificationtype='email'
		
		update n set n.placeholders = 'FirstName=' + isnull(pd.Firstname,'') + '&LastName=' + isnull(pd.Lastname,'') from NotificationsToSend n join [user] u on u.userid=n.userid 
		join PersonalDetails pd on pd.personaldetailsid = u.personaldetailsid 		
		where SentDate is null and NotificationType='Email'
		
		update NotificationsToSend set contactpreferences = replace(STUFF(SUBSTRING(contactpreferences,1,LEN(contactpreferences)-1),1,1,''),'\','') 
		where contactpreferences LIKE('%\%') and LEFT(contactpreferences, 1) = '"' and sentdate is null

		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='SMS' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[2].Scenarios[0].Notifications'),'$.SMS' ) ='false'
		and sentdate is null
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Email' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[2].Scenarios[0].Notifications'),'$.Email' ) ='false'
		and sentdate is null
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Push' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[2].Scenarios[0].Notifications'),'$.InApp' ) ='false'
		and sentdate is null
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
	if @PunchCardFull = 1 ----SuccessfulPunchCardCompletion
	begin
	--Successful PunchCard Completion Yes! You scored some free merch! Check your Spencer's Nation app!
		drop table if exists #SuccessfulPunch_Users
		drop table if exists #SuccessfulPunch_Users_WithTemplates 
		select @MaxTrxID = isnull(max(TrxID),0) from [NotificationsToSend] where  NotificareTemplateName ='SuccessfulPunchCardCompletion' 
		
		select Psc.UserId, max(th.trxid) LastTrxID into #SuccessfulPunch_Users
		from trxheader th join site s on s.siteid = th.SiteId
		join trxdetail td on th.trxid=td.trxid
		join Device D on D.EmbossLine2 = 'STAMP-' + CONVERT(VARCHAR(10),th.TrxId)
		join DeviceStatus DS on D.DeviceStatusId = DS.DeviceStatusId
		join trxtype tt on tt.trxtypeid=th.trxtypeid
		join PromotionStampCounter  psc  on th.TrxId=psc.TrxId
		join TrxDetailStampCard tds on td.TrxDetailID = tds.TrxDetailId
		WHERE tds.ValueUsed < 0 And td.Value > 0 AND ISNULL(psc.UserId,0) > 0 AND DS.Name = 'Active'
		and s.clientid = @Clientid and th.trxid > @MaxTrxID
		AND tt.name = 'PosTransaction'
		group by psc.userid	

		select au.*, uled.propertyvalue as ContactPreferences,uled2.PropertyValue as FCMDeviceTokens ,n.* into #SuccessfulPunch_Users_WithTemplates 
		from #SuccessfulPunch_Users au join [user] u on au.userid = u.userid
		join userloyaltyextensiondata uled on uled.userloyaltydataid = u.userloyaltydataid and uled.propertyname = 'NotificationAndReminderJSON'
		left join userloyaltyextensiondata uled2 on uled2.userloyaltydataid = u.userloyaltydataid and uled2.propertyname = 'FCMDeviceTokens'
		join (
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt join NotificationTemplateType ntt
		on nt.NotificationTemplateTypeid=ntt.id where nt.Name='SuccessfulPunchCardCompletion' 
		) n on 1=1
		
		insert into NotificationsToSend (
		Version, Clientid,userid, 
		Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		--isnull(cd.mobilephone,phone ),
		case when left(isnull(cd.mobilephone,phone ),1) = '+' then isnull(cd.mobilephone,phone ) else '+1' + ltrim(convert(nvarchar(50),isnull(cd.mobilephone,phone ))) end, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #SuccessfulPunch_Users_WithTemplates t
		join UserContactDetails ucd on t.userid=ucd.userid
		join contactdetails cd on cd.contactdetailsid=ucd.contactdetailsid
		where (isnull(cd.mobilephone,'') !='' or isnull(cd.Phone,'') !='') and notificationtype='sms'
		
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		FCMDeviceTokens, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #SuccessfulPunch_Users_WithTemplates t
		where isnull(FCMDeviceTokens,'') !='' and notificationtype='push'
		
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,cd.Email,t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #SuccessfulPunch_Users_WithTemplates t
		join UserContactDetails ucd on t.userid=ucd.userid
		join contactdetails cd on cd.contactdetailsid=ucd.contactdetailsid
		where isnull(cd.Email,'') !='' and notificationtype='email'

		update NotificationsToSend set contactpreferences = replace(STUFF(SUBSTRING(contactpreferences,1,LEN(contactpreferences)-1),1,1,''),'\','') 
		where contactpreferences LIKE('%\%') and LEFT(contactpreferences, 1) = '"' and sentdate is null

		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='SMS' and   JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[0].Notifications'),'$.SMS' ) ='false'
		and sentdate is null
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Email' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[0].Notifications'),'$.Email' ) ='false'
		and sentdate is null
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Push' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[0].Notifications'),'$.InApp' ) ='false'
		and sentdate is null
	end
	if @NewPunches = 1
	Begin
		drop table if exists #PunchesEarned_Users
		drop table if exists #PunchesEarned_Users_WithTemplates 

		select @MaxTrxId = isnull(max(trxid),0) from [NotificationsToSend] where NotificareTemplateName='QualifyingPurchase'
		
		select Psc.UserId,Max(th.TrxId) LastTrxID,th.DeviceId,Xpunches into #PunchesEarned_Users
        from trxheader th join site s on s.siteid = th.SiteId
        join trxdetail td on th.trxid=td.trxid
        join trxtype tt on tt.trxtypeid=th.trxtypeid
        join PromotionStampCounter  psc  on th.TrxId=psc.TrxId
        join (select sum (ValueUsed) Xpunches,TrxId,tds.PromotionId 
                FROM TrxDetailStampCard tds inner join TrxDetail td on tds.TrxDetailId = td.TrxDetailID
   				where  ValueUsed > 0
                Group By TrxId,tds.PromotionId HAVING sum(ValueUsed) > 0) X  ON X.TrxID = td.TrxID
        WHERE ISNULL(psc.UserId,0) > 0 
		and th.trxid > @MaxTrxId
        AND tt.name = 'PosTransaction'
		and s.clientid = @clientid
        Group  BY UserId,th.DeviceId,Xpunches
        
		select au.*, uled.propertyvalue as ContactPreferences,uled2.PropertyValue as FCMDeviceTokens ,n.* into #PunchesEarned_Users_WithTemplates 
		from #PunchesEarned_Users au join [user] u on au.userid = u.userid
		join userloyaltyextensiondata uled on uled.userloyaltydataid = u.userloyaltydataid and uled.propertyname = 'NotificationAndReminderJSON'
		left join userloyaltyextensiondata uled2 on uled2.userloyaltydataid = u.userloyaltydataid and uled2.propertyname = 'FCMDeviceTokens'
		join (
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt join NotificationTemplateType ntt
		on nt.NotificationTemplateTypeid=ntt.id where nt.Name='QualifyingPurchase' 
		) n on 1=1
		
		
		update #PunchesEarned_Users_WithTemplates set Placeholders = replace(Placeholders,'(X)',Xpunches)
		update #PunchesEarned_Users_WithTemplates set Placeholders = 'PunchEarned=' + convert(nvarchar(10),Xpunches)+'&' where NotificationType = 'Email'

		insert into NotificationsToSend (
		Version, Clientid,userid, 
		Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		--isnull(cd.mobilephone,phone ),
		case when left(isnull(cd.mobilephone,phone ),1) = '+' then isnull(cd.mobilephone,phone ) else '+1' + ltrim(convert(nvarchar(50),isnull(cd.mobilephone,phone ))) end, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #PunchesEarned_Users_WithTemplates t
		join UserContactDetails ucd on t.userid=ucd.userid
		join contactdetails cd on cd.contactdetailsid=ucd.contactdetailsid
		where (isnull(cd.mobilephone,'') !='' or isnull(cd.Phone,'') !='') and notificationtype='sms'
		
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		FCMDeviceTokens, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #PunchesEarned_Users_WithTemplates t
		where isnull(FCMDeviceTokens,'') !='' and notificationtype='push'
		
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,cd.Email,t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #PunchesEarned_Users_WithTemplates t
		join UserContactDetails ucd on t.userid=ucd.userid
		join contactdetails cd on cd.contactdetailsid=ucd.contactdetailsid
		where isnull(cd.Email,'') !='' and notificationtype='email'
		update n set n.placeholders = ISNULL(n.placeholders,'')+ 'FirstName=' + isnull(pd.Firstname,'') + '&LastName=' + isnull(pd.Lastname,'') from NotificationsToSend n join [user] u on u.userid=n.userid 
		join PersonalDetails pd on pd.personaldetailsid = u.personaldetailsid 		
		where SentDate is null and NotificationType='Email'
		--///Duplicate
		--update n set n.placeholders = n.placeholders + 'FirstName=' + isnull(pd.Firstname,'') + '&LastName=' + isnull(pd.Lastname,'') from NotificationsToSend n join [user] u on u.userid=n.userid 
		--join PersonalDetails pd on pd.personaldetailsid = u.personaldetailsid 		
		--where SentDate is null and NotificationType='Email'
		
		update NotificationsToSend set contactpreferences = replace(STUFF(SUBSTRING(contactpreferences,1,LEN(contactpreferences)-1),1,1,''),'\','') 
		where contactpreferences LIKE('%\%') and LEFT(contactpreferences, 1) = '"' and sentdate is null

		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='SMS' and   JSON_Value ( JSON_query(contactpreferences, '$.Notifications[0].Scenarios[0].Notifications'),'$.SMS' ) ='false'
		and sentdate is null
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Email' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[0].Scenarios[0].Notifications'),'$.Email' ) ='false'
		and sentdate is null
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Push' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[0].Scenarios[0].Notifications'),'$.InApp' ) ='false'
		and sentdate is null

	End
	if @PunchesLeft = 1
	Begin
	drop table if exists #PunchesLeft_Users
	drop table if exists #PunchesLeft_Users_WithTemplates 
	
	--select * from [NotificationsToSend] 
	--Declare @MaxTrxid int
	select @MaxTrxId = isnull(max(trxid),0) from [NotificationsToSend] where NotificareTemplateName='ReminderToCompletePunches'
	select P.ID,Psc.UserId,Max(th.TrxId) LastTrxID ,ISNULL(P.QualifyingProductQuantity,0) - ISNULL(psc.AfterValue,0) AS X
	into #PunchesLeft_Users
        from trxheader th join site s on s.siteid = th.SiteId
        join trxtype tt on tt.trxtypeid=th.trxtypeid
        join PromotionStampCounter psc on th.trxid=psc.trxid
        join promotion P on psc.PromotionId = P.Id
        WHERE ISNULL(psc.UserId,0) > 0 AND ISNULL(P.QualifyingProductQuantity,0) > 0 AND ISNULL(psc.AfterValue ,0) > 0
        AND (ISNULL(P.QualifyingProductQuantity,0) - ISNULL(psc.AfterValue,0)) > 0	
		and th.trxid > @MaxTrxId
		and tt.name = 'PosTransaction'
		and s.clientid = @clientid
		group by th.clientid, P.ID,Psc.UserId, ISNULL(P.QualifyingProductQuantity,0) - ISNULL(psc.AfterValue,0) 
		

		select au.*, uled.propertyvalue as ContactPreferences,uled2.PropertyValue as FCMDeviceTokens ,n.* into #PunchesLeft_Users_WithTemplates 
		from #PunchesLeft_Users au join [user] u on au.userid = u.userid
		join userloyaltyextensiondata uled on uled.userloyaltydataid = u.userloyaltydataid and uled.propertyname = 'NotificationAndReminderJSON'
		left join userloyaltyextensiondata uled2 on uled2.userloyaltydataid = u.userloyaltydataid and uled2.propertyname = 'FCMDeviceTokens'
		join (
		select nt.NotificareTemplateId,nt.Name, ntt.Name NotificationType, Placeholders from NotificationTemplate nt join NotificationTemplateType ntt
		on nt.NotificationTemplateTypeid=ntt.id where nt.Name='ReminderToCompletePunches' 
		) n on 1=1
		update #PunchesLeft_Users_WithTemplates set Placeholders = replace(Placeholders,'(X)',X)

		insert into NotificationsToSend (
		Version, Clientid,userid, 
		Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		--isnull(cd.mobilephone,phone ),
		case when left(isnull(cd.mobilephone,phone ),1) = '+' then isnull(cd.mobilephone,phone ) else '+1' + ltrim(convert(nvarchar(50),isnull(cd.mobilephone,phone ))) end, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #PunchesLeft_Users_WithTemplates t
		join UserContactDetails ucd on t.userid=ucd.userid
		join contactdetails cd on cd.contactdetailsid=ucd.contactdetailsid
		where (isnull(cd.mobilephone,'') !='' or isnull(cd.Phone,'') !='') and notificationtype='sms'
		
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,
		FCMDeviceTokens, 
		t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #PunchesLeft_Users_WithTemplates t
		where isnull(FCMDeviceTokens,'') !='' and notificationtype='push'
		
		insert into NotificationsToSend (
		Version, Clientid,userid, Recipient,NotificationType,NotificareTemplateId, NotificareTemplateName,auditid,trxid,SentDate,ContactPreferences, placeholders)
		select 1, @clientid, t.userid,cd.Email,t.NotificationType,t.NotificareTemplateId, t.[name],null,t.LastTrxID,null,t.ContactPreferences, t.placeholders
		from #PunchesLeft_Users_WithTemplates t
		join UserContactDetails ucd on t.userid=ucd.userid
		join contactdetails cd on cd.contactdetailsid=ucd.contactdetailsid
		where isnull(cd.Email,'') !='' and notificationtype='email'
		
		update NotificationsToSend set contactpreferences = replace(STUFF(SUBSTRING(contactpreferences,1,LEN(contactpreferences)-1),1,1,''),'\','') 
		where contactpreferences LIKE('%\%') and LEFT(contactpreferences, 1) = '"' and sentdate is null
		
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='SMS' and   JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[2].Notifications'),'$.SMS' ) ='false'
		and sentdate is null
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Email' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[2].Notifications'),'$.Email' ) ='false'
		and sentdate is null
		Update NotificationsToSend set sentdate = getdate() 
		where NotificationType='Push' and  JSON_Value ( JSON_query(contactpreferences, '$.Notifications[1].Scenarios[2].Notifications'),'$.InApp' ) ='false'
		and sentdate is null


	End
	update NotificationsToSend set recipient = replace(replace(replace(replace(recipient,' ',''),'-',''),'(',''),')','') where SentDate is null and NotificationType='sms'
	
	select * from NotificationsToSend 	where SentDate is null 
	
	update NotificationsToSend set sentdate = getdate() where SentDate is null
	
	drop table if exists #AccountInformation_Users
	drop table if exists #AccountInformation_Users_WithTemplates 
	drop table if exists #NewPunches_Users
	drop table if exists #NewPunches_Users_WithTemplates 
	drop table if exists #PunchesLeft_Users
	drop table if exists #PunchesLeft_Users_WithTemplates 
	drop table if exists #SuccessfulPunch_Users
	drop table if exists #SuccessfulPunch_Users_WithTemplates 

End
/*
select *from userloyaltyextensiondata where UserLoyaltyDataid in (
select userloyaltydataid from [user] where userid = 1404999)
*/

