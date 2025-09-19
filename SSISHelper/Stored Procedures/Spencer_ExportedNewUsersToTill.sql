CREATE Procedure SSISHelper.Spencer_ExportedNewUsersToTill as

/*

https://snipp-interactive.atlassian.net/browse/SPENCE-45
We need to create a batch file export for Spencer's till where we send them all the NEW registered users.
This job shall run every 15 mins and create a unique file (date/time) with all the newly registered users
*/
Declare @UserType_LoyaltyMember int, @clientid_spencer  int, @DateTimeNow nvarchar(25)
Select @clientid_spencer = clientid from client where name = 'Spencer'
select @UserType_LoyaltyMember =usertypeid from usertype where name = 'LoyaltyMember' and clientid = @clientid_spencer
select @DateTimeNow = convert(nvarchar(25),GetDate(),126)

--drop table #users
select distinct u.userid,u.UserLoyaltyDataId,propertyname,PersonalDetailsId into #users from [user] u join site s on u.siteid=s.siteid 
left join UserLoyaltyExtensionData uled on u.UserLoyaltyDataId=uled.UserLoyaltyDataId and uled.propertyname ='ExportedToTill'
where s.clientid=@clientid_spencer and u.UserTypeId = @UserType_LoyaltyMember
and u.createdate > dateadd(hour,-200,getdate())

delete from #users where propertyname ='ExportedToTill'

INSERT INTO [dbo].[UserLoyaltyExtensionData]
([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue],[GroupId],[DisplayOrder],[Deleted])
Select 1, UserLoyaltyDataId,'ExportedToTill',@DateTimeNow,1,1,0 from #users

/*
content of the file

userID 
Mobile number
eMail
user surname
user firstname 
*/
select u.Userid, isnull(cd.MobilePhone,'') as [Mobile Number], isnull(cd.email,'') eMail,isnull(pd.Lastname,'') as Surname,isnull(pd.Firstname ,'') as Firstname
from #users u join usercontactdetails ucd on u.userid=ucd.userid
join contactdetails cd on cd.ContactDetailsId=ucd.ContactDetailsId
join PersonalDetails pd on u.PersonalDetailsId=pd.PersonalDetailsId

Drop table #users
