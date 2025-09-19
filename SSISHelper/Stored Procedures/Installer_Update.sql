create Procedure SSISHelper.Installer_Update as 

Begin

--Any ones no longer in the List, Mark as Inactive, we need this to be AUDITED!!!
update o set o.sitestatusid=2
FROM SSISHelper.Installers n  right join 
site   o on convert(nvarchar(10),n.uniqueid)=o.siteref
where uniqueid is null and sitetypeid=1 and sitestatusid =1 and [name] != 'Napletons River Oaks' --<< the last one is the TEST SITE!!! Leave it!


--On the SOURCE table SSISHelper.Installers, mark the ones we already have with the siteid
Update n set n.siteid = o.siteid, n.contactdetailsid=o.ContactDetailsId, n.addressid=o.addressid, n.[Status] = 'ToUpdate' from SSISHelper.Installers n   join 
site   o on convert(nvarchar(10),n.uniqueid)=o.siteref
--Check which ones are the NewBies, not there before!
Update n set n.[Status] = 'NewBie' from SSISHelper.Installers n where n.[status] is null

DECLARE @OutputTbl			TABLE (Uniqueid nvarchar(10),ContactDetailsID INT)
DECLARE @OutputTblAddress	TABLE (Uniqueid nvarchar(10),AddressID INT)

declare @Clientid int=1, @Parentid  int, @SiteStatusID int,@SiteTypeID int,@EmailStatusID int, @ContactDetailsTypeId int,
@Countryid int,@AddressTypeID int,@AddressStatusID int,@AddressValidStatusId int,@BatchUserid int,@LanguageID int

select @ContactDetailsTypeId = ContactDetailsTypeId  from contactdetailstype where clientid = @clientid and name = 'Main'
select @EmailStatusID=emailstatusid from emailstatus where clientid = @clientid and name = 'Valid'

insert into contactdetails (Version,Email,Phone,MobilePhone,Fax, ContactDetailsTypeId,EmailStatusId,LastUpdated)
OUTPUT INSERTED.ContactDetailsId, inserted.fax INTO @OutputTbl(ContactDetailsID,Uniqueid)
select 1,i.[contact_email_address],phone,null,uniqueid,@ContactDetailsTypeId,@EmailStatusID,GetDate() from SSISHelper.Installers i where Status = 'NewBie'



select @Parentid = siteid from site where parentid = siteid and clientid = @clientid 
select @SiteStatusID=ss.SiteStatusID  from sitestatus ss where clientid = @clientid and name = 'Active'
select @SiteTypeID=SiteTypeID from sitetype where clientid = @clientid and name = 'Store' 
select @Countryid=Countryid from country where clientid = @clientid and CountryCode = 'US'
select @AddressTypeID = AddressTypeID from addresstype where clientid = @clientid and name = 'Main'
select @AddressStatusID = AddressStatusID from addressstatus where clientid = @clientid and name = 'Current'
select @AddressValidStatusId =AddressValidStatusId from addressvalidstatus where clientid = @clientid and name = 'Valid'
select @BatchUserid= userid from [user] u join usertype ut on ut.usertypeid=u.usertypeid where u.username = 'batchprocessadmin' and clientid = 3
select @LanguageID = LanguageID from language where clientid = @clientid and name = 'English'


select StateCode, stateid, countryid into #s from state where clientid = @clientid

insert into address ([Version],[AddressTypeId],[AddressStatusId],[AddressLine1],[AddressLine2],[HouseName],[HouseNumber],[Street],[Locality]
,[City],[Zip],[CountryId],[ValidFromDate],[AddressValidStatusId],[PostBoxNumber],[ContactDetailsId],[LastUpdatedBy],[LastUpdated]
,[Notes],[StateId],PostBox)
OUTPUT INSERTED.AddressId, inserted.PostBox INTO @OutputTblAddress(AddressID,Uniqueid)
SELECT 1,@AddressTypeID,@AddressStatusID,[address],'',[Payable To First],[Payable To Last],'',''
,[City],zipcode,@CountryId,GetDate(),@AddressValidStatusId,'',o.ContactDetailsID ,@BatchUserid,GetDate()
,'Accountid:' + isnull(i.[account #],' ') + ', SalesRep:'+ isnull(i.[Sales Rep],' ') + ', InstallerID:'+ isnull(i.[installer_id],' ')   
,s.stateid,i.uniqueid
FROM SSISHelper.Installers i left join #s s on s.StateCode=i.state and s.countryid = @countryid
join @OutputTbl o on o.Uniqueid=i.uniqueid

INSERT INTO [dbo].[Site]
([Name],[ParentId],[SiteStatusId],[SiteTypeId],[AddressId],[ClientId],[ContactDetailsId],[CompanyName]
,[SiteRef],[LanguageId],[Channel],[Display],CommunicationName, CountryId)
SELECT left([installer_name],50),@ParentID,@SiteStatusid,@SiteTypeID,a.addressid,@clientid,cd.contactdetailsid,left([DM2 Account Name],100),
i.[UNIQUEid],@LanguageID,[branch code],1,[contact_name],@countryid
  FROM SSISHelper.Installers i join @OutputTblAddress a on i.uniqueid=a.uniqueid
  join @OutputTbl cd on i.uniqueid=cd.uniqueid

--update site set parentid = 1994 where parentid=2 and sitetypeid=1 ???? Until we get the group info!

--for the ones that already existed, update them
Update s set s.[Name]= left(i.[installer_name],50),[CompanyName]=left([DM2 Account Name],100), s.Channel=i.[branch code],s.CommunicationName=i.[contact_name]
from SSISHelper.Installers i join [Site] s on i.siteid=s.siteid

Update a set 
a.[AddressLine1]=[address],a.[HouseName]=[Payable To First],a.[HouseNumber]=[Payable To Last],a.[City]=i.city,
a.[Zip]=i.zipcode,[Notes]='Accountid:' + isnull(i.[account #],' ') + ', SalesRep:'+ isnull(i.[Sales Rep],' ') + ', InstallerID:'+ isnull(i.[installer_id],' ')   
,a.[StateId]=s.stateid,a.PostBox=i.uniqueid
FROM SSISHelper.Installers i join address a on a.addressid=i.addressid
left join #s s on s.StateCode=i.state and s.countryid = @countryid

Update cd
set cd.Email=i.contact_email_address, cd.Phone=i.phone
from contactdetails cd join  SSISHelper.Installers i on cd.ContactDetailsId=i.ContactDetailsID

End