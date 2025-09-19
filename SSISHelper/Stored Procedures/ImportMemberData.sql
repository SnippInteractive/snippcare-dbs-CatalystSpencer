CREATE Procedure [SSISHelper].[ImportMemberData] (@DataSource nvarchar(126)='FullImport',	@ClientName nvarchar(50)='cloroxpawpoints',	
	@AuditReason nvarchar(256) ='Import client migrated Data',	
	@ApplyPoints bit = 0, @SiteRef nvarchar(25) =null, @Country_Default nvarchar(2)='US', @allocateDevice bit = 0
)
as
/*
Created by Niall 2021-04-26
Import data from the table ImportMemberTable and place it into all the entities involved.
currently we do NOT allow for a balance to be imported and the Create a transactions from Legacy 
system to give the balance



*/

Begin

/*
Getting the structure from our format..........
insert into importmembertable ([Clients_Identifier_Int], [Email], [Salutation], [GivenName], 
[MiddleName], [FamilyName], 
[Phone_Fixed], [Phone_Mobile], [Add1], [Add2], [City], [County], 
[Zip], [Country], [CreateDate], [LastModified], [LastLogin], [Clients_Identifier_String], [External_Communications_Reference])
select [Clients_Identifier_Int], [Email], [Title], [GivenName], [MiddleName], [FamilyName], [Phone_Fixed], [Phone_Mobile], [Add1], [Add2], [City], [County], [Zip], [Country], [CreateDate], [LastModified], case when [LastLogin]='NULL' then null else convert(datetime,[LastLogin]) end, [Clients_Identifier_String], [External_Communications_Reference] 
from [CatalystBaselineQA].[dbo].[__Temp_Clorox_MemberImport]
*/


/*
	Declare @DataSource nvarchar(126)='FullImport',	@ClientName nvarchar(50)='cloroxpawpoints',	@AuditReason nvarchar(256) ='Import client migrated Data',	
	@ApplyPoints bit = 0, @SiteRef nvarchar(25) =null, @Country_Default nvarchar(2)='US', @allocateDevice bit = 0
	*/
	declare @outputPersonalDetails table (UniqueId int, PersonalDetailsId int);
	declare @outputContactDetails table (UniqueId int, ContactDetailsId int);
	declare @outputUserLoyaltyData table (UniqueId int, UserLoyaltyDataId int);
	declare @outputUser table (UniqueId int, UserId int, SiteId int);
	declare @outputAddress table (UniqueId int, AddressId int);
	declare @outputTrx table (TrxId int, Points int);

	declare @RecsToProcess int=0, @RecsRejected int=0, @ParentSiteID int=0, @ContactDetailsType int=0
	declare @Clientid int=0, @UserType int=0, @UserSubType int=0, @UserStatusID int=0, @LanguageID int=0, @UserSubTypeNormal int=0
	declare @GenderFemale int=0, @GenderMale int=0, @AddressTypeId int=0, @AddressStatusId int=0, @UpdateUser int=0, @AddressValidStatusid int=0
	declare @UserLoyaltyDataID int, @RecsImported int=0

	select top 1 @clientid =  clientid from Client where [Name] = @ClientName
	select @ParentSiteID=siteid from Site where clientid = @clientid and ParentId=siteid
	select @clientid
	--select @Siteref = siteref from Site where Siteid = @ParentSiteID
	select @GenderMale = GenderTypeId from GenderType where ClientId=@Clientid and name = 'male'
	select @GenderFemale = GenderTypeId from GenderType where ClientId=@Clientid and name = 'female'
	select @UpdateUser=userid from [user] where Username='batchprocessadmin' and SiteId=@ParentSiteID

	select @ContactDetailsType=ContactDetailsTypeID from ContactDetailstype where clientid=@clientid and Name = 'Main'
	select @UserType=UserTypeId from usertype where ClientId=@clientid and Name='LoyaltyMember'
	select @UserSubTypeNormal=UserSubTypeId from UserSubType where ClientId=@clientid and Name='normal'
	select @UserStatusID=userstatusid from UserStatus where clientid = @clientid and [Name] = 'Active'
	select @LanguageID=LanguageId from [Language] where clientid = @clientid and [Name] = 'English'
	select @AddressTypeId=AddressTypeId from AddressType where ClientId=@clientid and [Name]='Main'
	select @AddressStatusId=AddressStatusId from AddressStatus where ClientId=@clientid and [Name]='Current'
	select @AddressValidStatusid=AddressValidStatusid from AddressValidStatus where ClientId=@Clientid and [Name]='Valid'

	Declare @trxStatusTypeId int, @trxTypeId int, @addressId int, @adminUserId int,@currentDate datetime,
			@deviceStatusId int, @EmailStatusId int,@CountryID int
			
	select top 1 @clientId = ClientId from Client where Name = @ClientName;
	select top 1 @adminUserId = UserId from [user] u join site s on s.siteid = u.siteid where username = 'batchprocessadmin' and clientid = @clientid;
	select top 1 @EmailStatusId = EmailStatusId from EmailStatus where name = 'Valid' and clientid = @clientid
	select top 1 @addressTypeId = AddressTypeId FROM AddressType where Name = 'Main' and ClientId = @clientId;
	select top 1 @addressStatusId = AddressStatusId FROM AddressStatus where Name = 'Current' and ClientId = @clientId;
	select top 1 @addressValidStatusId = AddressValidStatusId FROM AddressValidStatus where Name = 'Valid' and ClientId = @clientId;

	select top 1 @trxStatusTypeId = TrxStatusId from TrxStatus where Name = 'Completed';
	select top 1 @trxTypeId = TrxTypeId from TrxType where ClientId = @ClientId and Name = 'InitialPointsBalanceSet';
	
	select top 1 @deviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @clientId and Name = 'Active';

	select top 1 @CountryID=countryid from country where clientid = 2 and countrycode = @Country_Default
	
	--select * from [ImportMemberTable]
	IF OBJECT_ID('tempdb..#data') IS NOT NULL 	BEGIN  DROP TABLE #data END

	select * into #data from [ImportMemberTable] --Which records for this migration / import
	where Actioned = 'Imported' and ErrorCode is null and rejectreason is null and ImportFileName = @DataSource 
	
	set @currentDate = getdate();
/*	delete from PersonalDetails where personaldetailsid in (
	select pd.personaldetailsid from PersonalDetails pd left join [user] u on pd.personaldetailsid=u.personaldetailsid
	where userid is  null)*/
	MERGE INTO PersonalDetails 
	USING #data d 
	left join GenderType gt on gt.Name collate database_default = isnull(d.Gender, 'NULL') and gt.ClientId = @clientId
	left join TitleType tt on tt.Name collate database_default = isnull(d.Title,'NULL') and gt.ClientId = @clientId
	left join SalutationType st on st.Name collate database_default = d.Salutation and gt.ClientId = @clientId
	ON 1 = 0
	WHEN NOT MATCHED THEN
	INSERT 	(Version, Firstname, Lastname, DateOfBirth, GenderTypeId, TitleTypeId, SalutationId, LastUpdated)
	values( 1, Givenname, isnull(FamilyName,''), case when  ISDATE(dob) = 1 then CONVERT(datetime, DOB, 120) else null end, gt.gendertypeid, tt.TitleTypeId, 
	st.SalutationTypeId, @currentDate)
	OUTPUT d.UniqueId, inserted.PersonalDetailsId
	INTO @outputPersonalDetails (UniqueId, PersonalDetailsId);
	/*
	delete from contactdetails where contactdetailsid in (
	select cd.contactdetailsid from contactdetails cd left join usercontactdetails ucd on cd.contactdetailsid=ucd.contactdetailsid
	where ucd.userid is null)
	and contactdetailsid not in (select contactdetailsid from address where contactdetailsid is not null )
	*/
	MERGE INTO ContactDetails 
	USING #data d 
	join @outputPersonalDetails opd on opd.UniqueId = d.UniqueId
	ON 1 = 0
	WHEN NOT MATCHED THEN
	INSERT (Version, Email, Phone, MobilePhone, Fax, ContactDetailsTypeId, EmailStatusId,  LastUpdated)
	values( 1, Email, [Phone_Fixed], [Phone_Mobile], null, @ContactDetailsType,  case when email is not null and email <> '' then @EmailStatusId else null end, @currentDate)
	OUTPUT opd.UniqueId, inserted.ContactDetailsId
	INTO @outputContactDetails (UniqueId, ContactDetailsId);
	
	MERGE INTO UserLoyaltyData 
	USING #data d 
	join @outputPersonalDetails opd on opd.UniqueId = d.UniqueId
	ON 1 = 0
	WHEN NOT MATCHED THEN
	INSERT (Version, LoyaltySignupDate, LoyaltyApplicationSigned, CreatedBy, LastUpdated, TurnoverYTD, TurnoverLastYear, TurnoverAll)
	values (1, @currentDate, 1, @adminUserId, @currentDate, 0, 0, 0)
	OUTPUT opd.UniqueId, inserted.UserLoyaltyDataId
	INTO @outputUserLoyaltyData (UniqueId, UserLoyaltyDataId);
	
	MERGE INTO [User] 
	USING #data d 
	join @outputPersonalDetails opd on opd.UniqueId = d.UniqueId
	join @outputUserLoyaltyData uld on uld.UniqueId = d.UniqueId
	left join Site s on s.SiteRef collate database_default = d.SiteRef and s.ClientId = @clientId
	--left join language l on l.LanguageCode = d.[LanguageCode] and l.ClientId = @clientId
	ON 1 = 0
	WHEN NOT MATCHED THEN
	INSERT (Version, UserTypeId, UserSubTypeId, Username, Password, SiteId, CreateDate, ExpirationDate, 
	UserStatusId, PersonalDetailsId, UserLoyaltyDataId, LanguageId, ContactByEmail, ContactByMail,
		 ContactBySms, ContactByPhone, LastUpdatedDate, EmailAddressAuthenticated, LoginAttemptCounter, UserAccountLocked, 
		 UnauthenticatedUniqueIdentifier, LegacyNumber, Notes ) 
	values 	(1, @UserType/*ut.UserTypeId*/, @UserSubTypeNormal/*ust.UserSubTypeId*/, isnull(isnull(Familyname, GivenName),[Clients_Identifier_String]), 'NotSet', isnull(s.SiteId,@ParentSiteID), 
	isnull(d.createdate, @currentDate),null, 
	@UserStatusID, opd.PersonalDetailsId, uld.UserLoyaltyDataId, @LanguageId, 
		case when [EmailContact] = 'Y' then 1 else 0 end, 
		case when [PostContact] = 'Y' then 1 else 0 end , 
		case when [SmsContact] = 'Y' then 1 else 0 end, 
		case when [PhoneContact] = 'Y' then 1 else 0 end, isnull([LastModified],@currentDate), 'false', 0, 0, lower(newid()), [Clients_Identifier_Int], 'Migrated by Import')
	OUTPUT opd.UniqueId, inserted.UserId, s.SiteId
	INTO @outputUser (UniqueId, UserId, SiteId);
	
	insert into UserContactDetails
		(UserId, ContactDetailsId)
	select UserId, ocd.ContactDetailsId
	from @outputUser ou 
	join @outputContactDetails ocd on ocd.UniqueId = ou.UniqueId

	MERGE INTO Address 
	USING #data d 
	join @outputContactDetails ocd on ocd.UniqueId = d.UniqueId
	left join Country c on c.CountryCode collate database_default = d.Country and c.ClientId = @clientId
	left join State s on s.Name collate database_default  = d.County and c.ClientId = @clientId
	ON 1 = 0
	WHEN NOT MATCHED THEN
	
	INSERT (Version, AddressTypeId, AddressStatusId, AddressLine1, AddressLine2, HouseName, HouseNumber, Street, Locality, City, StateId, Zip, CountryId, ValidFromDate, AddressValidStatusId,
		 PostBox, PostBoxNumber, ContactDetailsId, LastUpdatedBy, LastUpdated)
	values ( 1, @addressTypeId, @addressStatusId, Add1, Add2, null, null, Street, null, City, s.[StateID], Zip, isnull(c.Countryid,@CountryID), @currentDate, 
	@addressValidStatusId,	null,null, ocd.ContactDetailsId, @adminUserId, @currentDate)
	OUTPUT ocd.UniqueId, inserted.AddressId
	INTO @outputAddress (UniqueId, AddressId);
			
	INSERT INTO UserAddresses
		(Version, UserId, AddressId)
	select 1, UserId, oa.AddressId
	from @outputUser ou 
	join @outputAddress oa on oa.UniqueId = ou.UniqueId

	if @allocateDevice = 1
	Begin
		IF OBJECT_ID('tempdb..#usersToGetDevice') IS NOT NULL 	BEGIN 		DROP TABLE #usersToGetDevice 	END
		/*
		This is for Migrations where there is no Devices passed to us but we need to create a virtual 
		device so we can add transactions and also an account for the balance
		*/
		Declare @LastDeviceLotID  int, @NewDeviceLotID int,@NumberOfDevices int
		select --@NumberOfDevices = count(i.userid) 
		i.userid into #usersToGetDevice
		from [ImportMemberTable] i left join device dv on i.userid=dv.userid
		where i.[ImportFileName]='FullImport' and Actioned = 'Processed' and dv.userid is null
		alter table #usersToGetDevice add id int identity (1,1)
		select @NumberOfDevices = count(*) from #usersToGetDevice
	
		select @LastDeviceLotID = max(devicelotid) from devicelotdeviceprofile where deviceprofileid in (
		select top 1 id from deviceprofiletemplate where deviceprofiletemplatetypeid = 
		(select top 1 id from deviceprofiletemplatetype where clientid = @clientid and name = 'Loyalty'))
		select @NumberOfDevices
	
		INSERT INTO [dbo].[DeviceLot]
		([Version],[Created],[Updated],[CreatedBy],[UpdatedBy],[StatusId],[NumberOfDevices],[StartDate],[InitialCashBalance]
		,[Name],[Reference],[InitialPointsBalance],[ExpiryDate],[DevicesAssigned],[DeviceStatusId])
		select [Version],GetDate(),GetDate(),[CreatedBy],[UpdatedBy],[StatusId],@NumberOfDevices,GetDate(),[InitialCashBalance]
		,[Name],[Reference],[InitialPointsBalance],DateAdd(Year,10,GetDate()),0,[DeviceStatusId] from devicelot where id = @LastDeviceLotID
		set @NewDeviceLotID = Scope_identity()
		INSERT INTO [dbo].[DeviceLotDeviceProfile]
				([Version],[DeviceLotId],[DeviceProfileId])
		select 1,@NewDeviceLotID,[DeviceProfileId] from devicelotdeviceprofile where devicelotid = @LastDeviceLotID
	
		exec bws_CreateDevices @clientid,@NewDeviceLotID,0

		select deviceid, accountid into #ToUpdate from device where devicelotid = @NewDeviceLotID--2176

		alter table #ToUpdate add id int identity (1,1)

		CREATE NONCLUSTERED INDEX idx_Usr ON [#usersToGetDevice] ([id]) INCLUDE ([userid])

		select Deviceid, Accountid, userid into #u from #ToUpdate t join #usersToGetDevice i on t.id=i.id
	
		Update dv set dv.userid = x.userid from device  dv join #u x on x.deviceid=dv.deviceid
		Update dv set dv.userid = x.userid from Account dv join #u  x on x.accountid=dv.accountid
		IF OBJECT_ID('tempdb..#u') IS NOT NULL 					BEGIN 		DROP TABLE #u 					END
		IF OBJECT_ID('tempdb..#usersToGetDevice') IS NOT NULL 	BEGIN 		DROP TABLE #usersToGetDevice 	END
		IF OBJECT_ID('tempdb..#ToUpdate') IS NOT NULL 			BEGIN 		DROP TABLE #ToUpdate 			END
	END 
	/*

	if (@ApplyPoints = 1)
	begin

		insert into TrxHeader (version, DeviceId, TrxTypeId, TrxDate, ClientId, SiteId, Reference, TrxStatusTypeId, CreateDate, CallContextId, AccountPointsBalance, LastUpdatedDate)
		OUTPUT Inserted.TrxId, Inserted.AccountPointsBalance 
		INTO @outputTrx 
		select  0, d.DeviceId, @trxTypeId, @currentDate, @ClientId, ou.SiteId, 'Import', @trxStatusTypeId, @currentDate, NEWID(), d.Points, @currentDate
		from #data d
		join @outputUser ou  on ou.UniqueId = d.UniqueId;

		insert into TrxDetail (Version, TrxID, LineNumber, ItemCode, Description, Quantity, Value, Points, ConvertedNetValue)
		select 0, ot.TrxId, 1, null, 'Initial Points', 1, 0, ot.Points, 0
		from @outputTrx ot
	end 
*/
	INSERT INTO Audit
		(version, UserId, FieldName, NewValue, OldValue, ChangeDate, ChangeBy, Reason, ReferenceType)
	select 1, ou.Userid, 'UserId', ou.UserId, null, @currentDate, @adminUserId,  @AuditReason, 'User'
	from @outputUser ou
	
	-- add date here to ensure it all works :D 
	update mi
	set UserID = ou.UserId, 
		ProcessedDate = @currentDate, 
		Actioned = 'Processed',
		ImportDate = GetDate()
	from [ImportMemberTable] mi
	join @outputUser ou on ou.UniqueId = mi.UniqueId;


	IF OBJECT_ID('tempdb..#data') IS NOT NULL 	BEGIN 		DROP TABLE #data 	END

/*

select * from [user]	--Update ImportMemberTable set importfilename = 'SecondAttempt', actioned = 'Imported' where UniqueId>3 
	select * from ImportMemberTable where UniqueId< 4
	select * from userloyaltydata
*/

END
