CREATE Procedure [SSISHelper].[Site_Synch] as 

Begin 

Declare @FileName nvarchar(100)
select top 1 @FileName = [FileName] from [SSISHelper].[SiteUpdates] order by filename desc

drop table if exists #AllSites
drop table if exists #Stores
drop table if exists #ImportSites
Drop table if exists #Regions
Drop table if exists #Districts
drop table if exists #RegionsChangeInDistricts
drop table if exists #RegionalDistrictsInSites
drop table if exists #RegionalDistrictsInFile
drop table if exists #SitesChangeInRegions
drop table if exists #PotentiallyMissingDistricts

select *,
ltrim(rtrim(LEFT(region_name,charindex('-',region_name)-1) )) as Region,
ltrim(rtrim(right(region_name,LEN(region_name)-charindex('-',region_name))  )) as CommunicationName,
replace(ltrim(rtrim(LEFT(District_Name,charindex('-',District_Name)-1) )),' ','_') as District,
ltrim(rtrim(right(District_Name,LEN(District_Name)-charindex('-',District_Name))  )) as DistrictCommunicationName
into #AllSites from [SSISHelper].[SiteUpdates] where filename = @FileName

select asi.District#, asi.District_Name , asi.region, asi.communicationname, sr.SiteId Region_SiteID, sr.parentid Region_ParentID
into #PotentiallyMissingDistricts
from #AllSites asi left join site s on asi.district_name = s.name collate database_default
left join site sr on replace(asi.Region,' ','')  = replace(sr.siteref,' ','')   collate database_default
where s.Name is null
group by asi.District#, asi.District_Name , asi.region, asi.communicationname, s.siteid, s.ParentId, sr.SiteId, sr.ParentId
/*select top 5 * from Site where Name like 'Distric%'
select * from Address where AddressId in (
5811,
5812,
5813,
5814,
5815)
select * from #PotentiallyMissingDistricts
*/
/*
We need to add this as a site of type DISTRICT. Even it the Distric has changed a NEW one will go in here. NO contact details needed
*/



DECLARE @OutputTbl			TABLE (Uniqueid nvarchar(10),ContactDetailsID INT)
DECLARE @OutputTblAddress	TABLE (Uniqueid nvarchar(10),AddressID int)

declare @Clientid int=1, @Parentid  int, @SiteStatusID int, @SiteStatusInactiveID int,@SiteTypeID_Store int,@SiteTypeID_AreaGroup int,@EmailStatusID int, @ContactDetailsTypeId int,
@Countryid int,@AddressTypeID int,@AddressStatusID int,@AddressValidStatusId int,@BatchUserid int,@LanguageID int

select @ContactDetailsTypeId = ContactDetailsTypeId  from contactdetailstype where clientid = @clientid and name = 'Main'
select @EmailStatusID=emailstatusid from emailstatus where clientid = @clientid and name = 'Valid'

select @Parentid = siteid from site where parentid = siteid and clientid = @clientid 
select @SiteStatusID=ss.SiteStatusID  from sitestatus ss where clientid = @clientid and name = 'Active'
select @SiteStatusInactiveID=ss.SiteStatusID  from sitestatus ss where clientid = @clientid and name = 'InActive'
select @SiteTypeID_Store=SiteTypeID from sitetype where clientid = @clientid and name = 'Store' 
select @SiteTypeID_AreaGroup=SiteTypeID from sitetype where clientid = @clientid and name = 'AreaGroup' 
select @Countryid=Countryid from country where clientid = @clientid and CountryCode = 'US'
select @AddressTypeID = AddressTypeID from addresstype where clientid = @clientid and name = 'Main'
select @AddressStatusID = AddressStatusID from addressstatus where clientid = @clientid and name = 'Current'
select @AddressValidStatusId =AddressValidStatusId from addressvalidstatus where clientid = @clientid and name = 'Valid'
select @BatchUserid= userid from [user] u join usertype ut on ut.usertypeid=u.usertypeid where u.username = 'batchprocessadmin' and clientid = @clientid
select @LanguageID = LanguageID from language where clientid = @clientid and name = 'English'

select @Parentid = siteid from site where parentid = SiteId
DECLARE @OutputTblSto			TABLE (Uniqueid nvarchar(10),ContactDetailsID INT)
DECLARE @OutputTblAddressSto	TABLE (Uniqueid nvarchar(10),AddressID int)

select a.*, sp.siteid as ParentID into #ImportSites from #AllSites a left join site s on a.siteref = s.siteref collate database_default
left join site sp on 'District_' + a.district#= sp.siteref collate database_default
where  s.siteid is null

/*This is to allow for CHANGES to the REGIONS and DISTRICTS*/

select region_name,Region,CommunicationName into #Regions from #AllSites group by region_name,Region,CommunicationName  order by region_name 
update s set S.Name = r.Region_Name, S.Channel=r.Region,S.CommunicationName=r.CommunicationName from #regions r left join Site s on r.Region=s.siteref collate DATABASE_default
where Region_Name !=s.name collate DATABASE_default

select District_Name,District,DistrictCommunicationName into #Districts from #AllSites group by District_Name,District,DistrictCommunicationName  order by District_Name 
Update s set S.name = d.District_Name, S.CommunicationName=d.DistrictCommunicationName
from #Districts d left join Site s on d.District=s.siteref collate DATABASE_default
where d.District!=isnull(s.name,'') collate DATABASE_default
and d.District_Name!=s.Name collate DATABASE_default

select st.siteid as ParentSiteID,s.*,sta.stateid, isnull(co.CountryId,@Countryid) CountryID,
row_number() over(order by s.siteref)as UniqueID into #Stores
from #ImportSites s join site st on st.name =s.District_Name collate database_default
and s.siteref collate database_default not in (select siteref from site) 
left join state sta on s.state=sta.statecode collate database_default and sta.countryid = @Countryid
left join country co on s.country=co.CountryCode collate database_default

insert into contactdetails (Version,Email,Phone,MobilePhone,Fax, ContactDetailsTypeId,EmailStatusId,LastUpdated)
OUTPUT INSERTED.ContactDetailsId, inserted.fax INTO @OutputTblSto(ContactDetailsID,Uniqueid)
select 1,'',phone,null,uniqueid,@ContactDetailsTypeId,@EmailStatusID,GetDate() from #Stores

insert into address ([Version],[AddressTypeId],[AddressStatusId],[AddressLine1],[AddressLine2],[HouseName],[HouseNumber],[Street],[Locality]
,[City],[Zip],[CountryId],[ValidFromDate],[AddressValidStatusId],[PostBoxNumber],[ContactDetailsId],[LastUpdatedBy],[LastUpdated]
,[StateId],PostBox)
OUTPUT INSERTED.AddressId, inserted.PostBox INTO @OutputTblAddresssto(AddressID,Uniqueid)
SELECT 1,@AddressTypeID,@AddressStatusID,Addressline1, AddressLine2,'','','',''
,[City],Zip,CountryId,GetDate(),@AddressValidStatusId,'',o.ContactDetailsID ,@BatchUserid,GetDate()
,stateid,i.uniqueid
FROM #stores i 
join @OutputTblsto o on o.Uniqueid=i.uniqueid

select ParentSiteID, StoreName, ParentSiteRef, SiteRef, SiteType, Addressline1, AddressLine2,City,Zip,stateid,CountryID, uniqueid, 
case Active when 1 then @SiteStatusID else @SiteStatusInactiveID end SiteStatusID from #Stores

SELECT left([StoreName],50),ParentSiteID,@SiteStatusid,@SiteTypeID_Store,a.addressid,@clientid,cd.contactdetailsid,ParentSiteRef,
SiteRef,@LanguageID,'Store',1,'',@countryid, @BatchUserid, GetDate()
  FROM #Stores i join @OutputTblAddressSto a on i.uniqueid=a.uniqueid
  join @OutputTblSto cd on i.uniqueid=cd.uniqueid
  

INSERT INTO [dbo].[Site]
([Name],[ParentId],[SiteStatusId],[SiteTypeId],[AddressId],[ClientId],[ContactDetailsId],[CompanyName]
,[SiteRef],[LanguageId],[Channel],[Display],CommunicationName, CountryId, UpdatedBy, UpdatedDate )
SELECT left([StoreName],50),ParentSiteID,@SiteStatusid,@SiteTypeID_Store,a.addressid,@clientid,cd.contactdetailsid,ParentSiteRef,
SiteRef,@LanguageID,'Store',1,'',@countryid, @BatchUserid, GetDate()
  FROM #Stores i join @OutputTblAddressSto a on i.uniqueid=a.uniqueid
  join @OutputTblSto cd on i.uniqueid=cd.uniqueid


/*Have Regions moved in districts*/

select Count(*) Amt, Region , Region_Name,  District, District_name into #RegionalDistrictsInFile
from #AllSites
group by Region , Region_Name,  District, District_name
Order by Region,District


select sr.siteid RegionSiteID,sr.name RegionName, sr.siteref RegionSiteRef, sp.siteid DistrictSiteID ,sp.name DistrictName, sp.siteref DistrictSiteRef , sp.ParentId
into #RegionalDistrictsInSites
from Site sr join Site sp on sp.parentid=sr.siteid
where sr.Name like 'region%'
order by sr.Name, sp.name

select inf.Region RegionInFile, s.SiteId,s.Name, s.parentid, ins.RegionSiteRef RegionInSite, inr.siteid ToMoveToParentID
Into #RegionsChangeInDistricts
from #RegionalDistrictsInFile inf left join  #RegionalDistrictsInSites ins on inf.District  = ins.DistrictSiteRef  collate database_default
join site s on inf.District=s.SiteRef collate database_default
join Site inr on inf.Region=inr.siteref collate database_default
where inf.region!=ins.regionsiteref collate database_default

Insert into Audit (Version,UserId,FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType, OperatorId,SiteId,AdminScreen,SysUser)
select 1,@BatchUserid,'ParentID',[regionInFile],regionInsite,GetDate(),@BatchUserid,'Import Batch',@FileName,
@BatchUserid,SiteID,'Site',@BatchUserid
from #RegionsChangeInDistricts

Update s set s.ParentId = r.ToMoveToParentID from #RegionsChangeInDistricts r join Site s on s.SiteId = r.SiteId

/*Have Sites moved in Regions*/
select s.siteid,s.siteref,sp.SiteRef ParentsSite, s.ParentId OldParentID,sm.siteid NewParentID, sm.siteref MoveToParent 
into #SitesChangeInRegions
from #AllSites a join site s on s.SiteRef=a.siteref collate database_default
join Site sp on s.ParentId=sp.SiteId
join Site sm on a.District =sm.siteref collate database_default
where sp.SiteRef!=a.District collate database_default
order by a.SiteRef

Insert into Audit (Version,UserId,FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType, OperatorId,SiteId,AdminScreen,SysUser)
select 1,@BatchUserid,'ParentID',MoveToParent,ParentsSite,GetDate(),@BatchUserid,'Import Batch',@FileName,
@BatchUserid,SiteID,'Site',@BatchUserid
from #SitesChangeInRegions

Update s set s.ParentId = r.NewParentID from #SitesChangeInRegions r join Site s on s.SiteId = r.SiteId

drop table if exists #SitesChangeInRegions
drop table if exists #RegionsChangeInDistricts
drop table if exists #RegionalDistrictsInSites
drop table if exists #RegionalDistrictsInFile
drop table if exists #AllSites
drop table if exists #Stores
drop table if exists #ImportSites
Drop table if exists #Regions
Drop table if exists #Districts
drop table if exists #PotentiallyMissingDistricts

end

