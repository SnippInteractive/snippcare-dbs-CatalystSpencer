CREATE Procedure [SSISHelper].[Site_Synch_WIP] as 

Begin
	Declare @FileName nvarchar(100)
	/*Get the filename that is the LAST imported file*/
	SELECT top 1 @FileName = [FileName] from [SSISHelper].[SiteUpdates] order by filename desc

	--Check for the top level Regions and Districts
	Update [SSISHelper].[SiteUpdates] set District_Name='District 55 - OPEN' 
	where District_Name='District - 55 - OPEN' and filename = @FileName ---- they really need to fix the data coming in!
	Drop table if exists #Regions

	--check the Sites table for the regions and check that we have no new ones and that the names are the same as what was there before.
	SELECT [ParentSiteRef],[Region#],[Region_Name], row_number() over(order by region_name) as UniqueID,
	ltrim(rtrim(left(region_name,charindex('-',Region_Name)-1))) as SiteRef, 
	ltrim(rtrim(right(region_name,len(region_name)-charindex('-',Region_Name)-1)))as Region_Rep_Alone 
	INTO #Regions      
	FROM [SSISHelper].[SiteUpdates] where [filename] = @FileName
	group by [ParentSiteRef],[Region#],[Region_Name]

	alter table #Regions add Missing int 
	update r set R.missing = 1 from #Regions r left join Site s on r.SiteRef = s.siteref collate database_default where s.SiteId is null

	DECLARE @OutputTbl			TABLE (Uniqueid nvarchar(10),ContactDetailsID INT)
	DECLARE @OutputTblAddress	TABLE (Uniqueid nvarchar(10),AddressID int)

	DECLARE @Clientid int=1, @Parentid  int, @SiteStatusID int, @SiteStatusInactiveID int,@SiteTypeID_Store int,@SiteTypeID_AreaGroup int,@EmailStatusID int, @ContactDetailsTypeId int,
	@Countryid int,@AddressTypeID int,@AddressStatusID int,@AddressValidStatusId int,@BatchUserid int,@LanguageID int

	SELECT @ContactDetailsTypeId = ContactDetailsTypeId  from contactdetailstype where clientid = @clientid and name = 'Main'
	SELECT @EmailStatusID=emailstatusid from emailstatus where clientid = @clientid and name = 'Valid'

	SELECT @Parentid = siteid from site where parentid = siteid and clientid = @clientid 
	SELECT @SiteStatusID=ss.SiteStatusID  from sitestatus ss where clientid = @clientid and name = 'Active'
	SELECT @SiteStatusInactiveID=ss.SiteStatusID  from sitestatus ss where clientid = @clientid and name = 'InActive'
	SELECT @SiteTypeID_Store=SiteTypeID from sitetype where clientid = @clientid and name = 'Store' 
	SELECT @SiteTypeID_AreaGroup=SiteTypeID from sitetype where clientid = @clientid and name = 'AreaGroup' 
	SELECT @Countryid=Countryid from country where clientid = @clientid and CountryCode = 'US'
	SELECT @AddressTypeID = AddressTypeID from addresstype where clientid = @clientid and name = 'Main'
	SELECT @AddressStatusID = AddressStatusID from addressstatus where clientid = @clientid and name = 'Current'
	SELECT @AddressValidStatusId =AddressValidStatusId from addressvalidstatus where clientid = @clientid and name = 'Valid'
	SELECT @BatchUserid= userid from [user] u join usertype ut on ut.usertypeid=u.usertypeid where u.username = 'batchprocessadmin' and clientid = @clientid
	SELECT @LanguageID = LanguageID from language where clientid = @clientid and name = 'English'

	SELECT @Parentid = siteid from site where parentid = SiteId

	insert into address ([Version],[AddressTypeId],[AddressStatusId],[AddressLine1],[AddressLine2],[HouseName],[HouseNumber],[Street],[Locality]
	,[City],[Zip],[CountryId],[ValidFromDate],[AddressValidStatusId],[PostBoxNumber],[ContactDetailsId],[LastUpdatedBy],[LastUpdated]
	,[Notes],[StateId], PostBox)
	OUTPUT INSERTED.AddressId, inserted.PostBox INTO @OutputTblAddress(AddressID,Uniqueid)
	SELECT 1,@AddressTypeID,@AddressStatusID,'','','','','',''
	,'','',@CountryId,GetDate(),@AddressValidStatusId,'',null ,@BatchUserid,GetDate()
	,', SalesRep:'+ isnull(r.Region_Rep_Alone,' ') 
	,NULL,uniqueid
	FROM #Regions r where r.Missing = 1

	INSERT INTO [dbo].[Site]
	([Name],[ParentId],[SiteStatusId],[SiteTypeId],[AddressId],[ClientId],[ContactDetailsId],[CompanyName]
	,[SiteRef],[LanguageId],[Channel],[Display],CommunicationName, CountryId, UpdatedBy, UpdatedDate)
	SELECT left(i.Region_Name,50),@ParentID,@SiteStatusid,@SiteTypeID_AreaGroup,a.addressid,@clientid,null,ParentSiteRef,
	SiteRef,@LanguageID,'Region',1,Region_Rep_Alone,@countryid, @BatchUserid, GetDate()
	FROM #Regions i join @OutputTblAddress a on i.uniqueid=a.uniqueid

	Drop table if exists #Districts
	SELECT st.siteid ParentSiteID,st.SiteRef as ParentSiteRef,
	s.[Region#],s.[Region_Name],[District#],[District_Name], row_number() over(order by district_name) as UniqueID,
	Replace(ltrim(rtrim(left(District_Name,charindex('-',District_Name)-1))),' ','_') as District_Name_Alone,
	ltrim(rtrim(right(District_Name,len(District_Name)-charindex('-',District_Name)-1))) as District_Rep_Alone into #Districts
	FROM [SSISHelper].[SiteUpdates] s join #Regions r on r.Region_Name=s.Region_Name
	join site st on st.siteref=r.SiteRef collate database_default and [filename] = @FileName
	group by st.siteid,s.[Region#],s.[Region_Name],[District#],[District_Name],st.SiteRef 

	alter table #Districts add Missing int 
	update d set d.missing = 1 from #Districts d left join Site s on d.District_Name_Alone = s.siteref collate database_default where s.SiteId is null and District_Name_Alone!='District'

	DECLARE @OutputTblDIS			TABLE (Uniqueid nvarchar(10),ContactDetailsID INT)
	DECLARE @OutputTblAddressDIS	TABLE (Uniqueid nvarchar(10),AddressID int)

	insert into address ([Version],[AddressTypeId],[AddressStatusId],[AddressLine1],[AddressLine2],[HouseName],[HouseNumber],[Street],[Locality]
	,[City],[Zip],[CountryId],[ValidFromDate],[AddressValidStatusId],[PostBoxNumber],[ContactDetailsId],[LastUpdatedBy],[LastUpdated]
	,[Notes],[StateId], PostBox)
	OUTPUT INSERTED.AddressId, inserted.PostBox INTO @OutputTblAddressDIS(AddressID,Uniqueid)
	SELECT 1,@AddressTypeID,@AddressStatusID,'','','','','',''
	,'','',@CountryId,GetDate(),@AddressValidStatusId,'',null ,@BatchUserid,GetDate()
	,', SalesRep:'+ isnull(r.District_Rep_Alone,' ') 
	,NULL,uniqueid
	FROM #Districts r where missing=1 

	INSERT INTO [dbo].[Site]
	([Name],[ParentId],[SiteStatusId],[SiteTypeId],[AddressId],[ClientId],[ContactDetailsId],[CompanyName]
	,[SiteRef],[LanguageId],[Channel],[Display],CommunicationName, CountryId, UpdatedBy, UpdatedDate)
	SELECT left(i.district_Name,50),ParentSiteID,@SiteStatusid,@SiteTypeID_AreaGroup,a.addressid,@clientid,null,ParentSiteRef,
	District_Name_Alone,@LanguageID,'District',1,District_Rep_Alone,@countryid, @BatchUserid, GetDate()
	FROM #Districts i join @OutputTblAddressDIS a on i.uniqueid=a.uniqueid

	Drop table if exists #Stores

	SELECT st.siteid as ParentSiteID,s.*,sta.stateid, isnull(co.CountryId,@Countryid) CountryID,
	row_number() over(order by s.siteref)as UniqueID into #Stores
	from [SSISHelper].[SiteUpdates] s join site st on st.SiteRef =s.siteref collate database_default
	and s.siteref collate database_default not in (SELECT siteref from site) 
	and [filename] = @FileName
	left join state sta on s.state=sta.statecode collate database_default and sta.countryid = @Countryid
	left join country co on s.country=co.CountryCode collate database_default

	DECLARE @OutputTblSto			TABLE (Uniqueid nvarchar(10),ContactDetailsID INT)
	DECLARE @OutputTblAddressSto	TABLE (Uniqueid nvarchar(10),AddressID int)

	insert into contactdetails (Version,Email,Phone,MobilePhone,Fax, ContactDetailsTypeId,EmailStatusId,LastUpdated)
	OUTPUT INSERTED.ContactDetailsId, inserted.fax INTO @OutputTblSto(ContactDetailsID,Uniqueid)
	SELECT 1,'',phone,null,uniqueid,@ContactDetailsTypeId,@EmailStatusID,GetDate() from #Stores

	insert into address ([Version],[AddressTypeId],[AddressStatusId],[AddressLine1],[AddressLine2],[HouseName],[HouseNumber],[Street],[Locality]
	,[City],[Zip],[CountryId],[ValidFromDate],[AddressValidStatusId],[PostBoxNumber],[ContactDetailsId],[LastUpdatedBy],[LastUpdated]
	,[StateId],PostBox)
	OUTPUT INSERTED.AddressId, inserted.PostBox INTO @OutputTblAddresssto(AddressID,Uniqueid)
	SELECT 1,@AddressTypeID,@AddressStatusID,Addressline1, AddressLine2,'','','',''
	,[City],Zip,CountryId,GetDate(),@AddressValidStatusId,'',o.ContactDetailsID ,@BatchUserid,GetDate()
	,stateid,i.uniqueid
	FROM #stores i 
	join @OutputTblsto o on o.Uniqueid=i.uniqueid

	SELECT ParentSiteID, StoreName, ParentSiteRef, SiteRef, SiteType, Addressline1, AddressLine2,City,Zip,stateid,CountryID, uniqueid, 
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
	FROM #Stores i join @OutputTblAddressSto a on i.uniqueid=a.uniqueid join @OutputTblSto cd on i.uniqueid=cd.uniqueid

	Drop table if exists #Regions
	Drop table if exists #Districts
	Drop table if exists #Stores

  
end 