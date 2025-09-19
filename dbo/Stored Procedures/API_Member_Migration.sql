
-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <19/11/2017>
-- Description:	<Bulk user import>
-- =============================================
CREATE PROCEDURE [dbo].[API_Member_Migration]
(
	@DataSource nvarchar(126),
	@ClientName nvarchar(50),
	@AuditReason nvarchar(256),
	@ApplyPoints bit = 1
)
AS
BEGIN
	SET NOCOUNT ON;
	--populate phonetic keys

	declare @outputPersonalDetails table (UniqueId int, PersonalDetailsId int);
	declare @outputContactDetails table (UniqueId int, ContactDetailsId int);
	declare @outputUserLoyaltyData table (UniqueId int, UserLoyaltyDataId int);
	declare @outputUser table (UniqueId int, UserId int, SiteId int);
	declare @outputAddress table (UniqueId int, AddressId int);
	declare @outputTrx table (TrxId int, Points int);

	declare @clientId int;
	Declare @trxStatusTypeId int;
	Declare @trxTypeId int;

	declare @addressId int; 
	declare @addressTypeId int;
	declare @addressStatusId int;
	declare @addressValidStatusId int;
	declare @adminUserId int;
	declare @currentDate datetime;
	declare @deviceStatusId int, @EmailStatusId int


	set @EmailStatusId = 1
	select top 1 @clientId = ClientId from Client where Name = @ClientName;
	select top 1 @adminUserId = UserId from [user] u join site s on s.siteid = u.siteid where username = 'helpdesksupervisor' and clientid = @clientid;

	select top 1 @addressTypeId = AddressTypeId FROM AddressType where Name = 'Main' and ClientId = @clientId;
	select top 1 @addressStatusId = AddressStatusId FROM AddressStatus where Name = 'Current' and ClientId = @clientId;
	select top 1 @addressValidStatusId = AddressValidStatusId FROM AddressValidStatus where Name = 'Valid' and ClientId = @clientId;

	select top 1 @trxStatusTypeId = TrxStatusId from TrxStatus where Name = 'Completed';
	select top 1 @trxTypeId = TrxTypeId from TrxType where ClientId = @ClientId and Name = 'InitialPointsBalanceSet';

	select top 1 @deviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @clientId and Name = 'Active';


	IF OBJECT_ID('tempdb..#data') IS NOT NULL
	BEGIN
		DROP TABLE #data
	END

	select *  
	into #data 
	from MemberImport
	where Actioned = 'ReadyForImport' 
	and ErrorCode is null 
	and ImportTableName = @DataSource 
	--and ImportDate = @ImportDate 

	--insert into #data
	--exec ('select  * from ' + @DataSource)

	--alter table #data
	--add UniqueId int identity(1,1)

	
	set @currentDate = getdate();

	MERGE INTO PersonalDetails 
	USING #data d 
	left join GenderType gt on gt.Name = isnull(d.GenderType, 'NULL') and gt.ClientId = @clientId
	left join TitleType tt on tt.Name = isnull(d.TitleType,'NULL') and gt.ClientId = @clientId
	left join SalutationType st on st.Name = d.SalutationType and gt.ClientId = @clientId
	ON 1 = 0
	WHEN NOT MATCHED THEN
	INSERT 	(Version, Firstname, Lastname, DateOfBirth, GenderTypeId, TitleTypeId, SalutationId, LastUpdated)
	values( 1, Firstname, isnull(Lastname,''), case when  ISDATE(dob) = 1 then CONVERT(datetime, DOB, 120) else null end, gt.gendertypeid, tt.TitleTypeId, st.SalutationTypeId, @currentDate)
	OUTPUT d.UniqueId, inserted.PersonalDetailsId
	INTO @outputPersonalDetails (UniqueId, PersonalDetailsId);

	MERGE INTO ContactDetails 
	USING #data d 
	join @outputPersonalDetails opd on opd.UniqueId = d.UniqueId
	left join ContactDetailsType cdt on cdt.Name = d.ContactDetailsType and cdt.ClientId = @clientId
	ON 1 = 0
	WHEN NOT MATCHED THEN
	INSERT (Version, Email, Phone, MobilePhone, Fax, ContactDetailsTypeId, EmailStatusId,  LastUpdated)
	values( 1, Email, Phone, Mobile, null, cdt.ContactDetailsTypeId,  case when email is not null and email <> '' then @EmailStatusId else null end, @currentDate)
	OUTPUT opd.UniqueId, inserted.ContactDetailsId
	INTO @outputContactDetails (UniqueId, ContactDetailsId);
	
	MERGE INTO UserLoyaltyData 
	USING #data d 
	join @outputPersonalDetails opd on opd.UniqueId = d.UniqueId
	ON 1 = 0
	WHEN NOT MATCHED THEN
	INSERT (Version, LoyaltySignupDate, LoyaltyApplicationSigned, CreatedBy, LastUpdated, TurnoverYTD, TurnoverLastYear, TurnoverAll, TurnoverAllTemp)
	values (1, @currentDate, 1, @adminUserId, @currentDate, 0, 0, 0, TurnoverBalance)
	OUTPUT opd.UniqueId, inserted.UserLoyaltyDataId
	INTO @outputUserLoyaltyData (UniqueId, UserLoyaltyDataId);
	
	MERGE INTO [User] 
	USING #data d 
	join @outputPersonalDetails opd on opd.UniqueId = d.UniqueId
	join @outputUserLoyaltyData uld on uld.UniqueId = d.UniqueId
	join Site s on s.SiteRef = d.SiteRef and s.ClientId = @clientId
	left join language l on l.LanguageCode = d.LanguageCode and l.ClientId = @clientId
	left join UserStatus us on us.Name = 'Active' and us.ClientId = @clientId
	left join UserType ut on ut.Name = d.UserType and ut.ClientId = @clientId
	left join UserSubType ust on ust.Name = d.UserSubType and ust.ClientId = @clientId
	ON 1 = 0
	WHEN NOT MATCHED THEN
	INSERT (Version, UserTypeId, UserSubTypeId, Username, Password, SiteId, CreateDate, 
	ExpirationDate, 
	UserStatusId, PersonalDetailsId, UserLoyaltyDataId, LanguageId, ContactByEmail, ContactByMail,
		 ContactBySms, ContactByPhone, LastUpdatedDate, EmailAddressAuthenticated, LoginAttemptCounter, UserAccountLocked, 
		 UnauthenticatedUniqueIdentifier, LegacyNumber, Notes ) 
	values 	(1, ut.UserTypeId, ust.UserSubTypeId, isnull(Lastname, Firstname), 'NotSet', s.SiteId, @currentDate,
	 null, 
	us.UserStatusId, opd.PersonalDetailsId, uld.UserLoyaltyDataId, l.LanguageId, 
		case when ContactByEmail = 'Y' then 1 else 0 end, 
		case when ContactByMail = 'Y' then 1 else 0 end , 
		case when ContactBySms = 'Y' then 1 else 0 end, 
		case when ContactByPhone = 'Y' then 1 else 0 end, @currentDate, 'false', 0, 0, lower(newid()), OldMemberId, 'Migrated by [API_Member_Migration]')
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
	left join Country c on c.CountryCode = d.Country and c.ClientId = @clientId
	ON 1 = 0
	WHEN NOT MATCHED THEN
	INSERT (Version, AddressTypeId, AddressStatusId, AddressLine1, AddressLine2, HouseName, HouseNumber, Street, Locality, City, County, Zip, CountryId, ValidFromDate, AddressValidStatusId,
		 PostBox, PostBoxNumber, ContactDetailsId, LastUpdatedBy, LastUpdated)
	values ( 1, @addressTypeId, @addressStatusId, AddressLine1, null, null, null, Street, null, City, null, Zip, c.Countryid, @currentDate, 
	@addressValidStatusId,	null,null, ocd.ContactDetailsId, @adminUserId, @currentDate)
	OUTPUT ocd.UniqueId, inserted.AddressId
	INTO @outputAddress (UniqueId, AddressId);
			
	INSERT INTO UserAddresses
		(Version, UserId, AddressId)
	select 1, UserId, oa.AddressId
	from @outputUser ou 
	join @outputAddress oa on oa.UniqueId = ou.UniqueId

	INSERT INTO UserProfileExtraInfo
		(UserId, SocialSecurity , Covercard, MpiId)
	select ou.UserId, d.SocialSecurity, d.Covercard, d.MpiId
	from #data d
	join @outputUser ou  on ou.UniqueId = d.UniqueId;

	update dv
		set dv.UserId = ou.UserId,
			dv.HomeSiteId = ou.SiteId,
			dv.StartDate = @currentDate,
			dv.DeviceStatusId = @deviceStatusId
	from Device dv 
	join #data d on d.DeviceId = dv.DeviceId
	join @outputUser ou  on ou.UniqueId = d.UniqueId;
	
	update a
		set a.UserId = ou.UserId,
			a.PointsBalance = isnull(d.Points,0)
		from Account a 
		join #data d on d.AccountId = a.AccountId
		join @outputUser ou  on ou.UniqueId = d.UniqueId;


	if (@ApplyPoints = 1)
	begin

		insert into TrxHeader (version, DeviceId, TrxTypeId, TrxDate, ClientId, SiteId, Reference, TrxStatusTypeId, CreateDate, CallContextId, AccountPointsBalance, LastUpdatedDate)
		OUTPUT Inserted.TrxId, Inserted.AccountPointsBalance 
		INTO @outputTrx 
		select  0, d.DeviceId, @trxTypeId, @currentDate, @ClientId, ou.SiteId, 'DB', @trxStatusTypeId, @currentDate, NEWID(), d.Points, @currentDate
		from #data d
		join @outputUser ou  on ou.UniqueId = d.UniqueId;

		insert into TrxDetail (Version, TrxID, LineNumber, ItemCode, Description, Quantity, Value, Points, ConvertedNetValue)
		select 0, ot.TrxId, 1, null, 'Initial Points', 1, 0, ot.Points, 0
		from @outputTrx ot
	end 

	INSERT INTO Audit
		(version, UserId, FieldName, NewValue, OldValue, ChangeDate, ChangeBy, Reason, ReferenceType)
	select 1, ou.Userid, 'UserId', ou.UserId, null, @currentDate, @adminUserId,  @AuditReason, 'User'
	from @outputUser ou

	-- add date here to ensure it all works :D 
	update mi
	set MemberId = ou.UserId, 
		ProcessedDate = @currentDate, 
		Actioned = 'Processed'
	from MemberImport mi
	join @outputUser ou on ou.UniqueId = mi.UniqueId;


	IF OBJECT_ID('tempdb..#data') IS NOT NULL
	BEGIN
		DROP TABLE #data
	END

END
