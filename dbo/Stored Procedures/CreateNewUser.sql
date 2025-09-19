
-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <23/06/2016>
-- Description:	<Creates new user>
-- =============================================
CREATE PROCEDURE [dbo].[CreateNewUser]
(
	@ClientName nvarchar(100),
	@UserType nvarchar(30),
	@UserSubType nvarchar(30),
	@Username nvarchar(80),
	@SiteRef nvarchar(30),
	@UserStatus nvarchar(30),
	@LanguageCode nvarchar(2),
	@ContactByEmail int, 
	@ContactByMail int,
	@ContactBySms int, 
	@ContactByPhone int, 
	@FirstName nvarchar(70),
	@LastName nvarchar(70),
	@SecondName nvarchar(70),
	@DateOfBirth datetime, 
	@GenderType nvarchar(20),
	@TitleTypeCode nvarchar(20),
	@SalutationType nvarchar(30),
	@AddressType nvarchar(30),
	@AddressStatus nvarchar(30),
	@AddressLine1 nvarchar(100),
	@AddressLine2 nvarchar(100),
	@HouseName nvarchar(80),
	@HouseNumber nvarchar(50),
	@Street nvarchar(50),
	@Locality nvarchar(80),
	@City nvarchar(60),
	@County nvarchar(60),
	@Zip nvarchar(50),
	@Country nvarchar(2),
	@PostBox int,
	@PostBoxNumber nvarchar(50),
	@Email nvarchar(80),
	@MobilePhone nvarchar(50),
	@Phone nvarchar(50),
	@Fax nvarchar(50),
	@SocialSecurity nvarchar(50),
	@Covercard nvarchar(20),
	@MpiId nvarchar(13),
	@MonetaryBalance decimal(18,2),
	@PointsBalance decimal(18,2),
	@DeviceStatus nvarchar(30),
	@Version nvarchar(10),
	@TurnoverBalance decimal(18,2),
	@DeviceType nvarchar(30),
	@CommunityId nvarchar(30),
	@oldDeviceId nvarchar(50),
	@TurnoverBalanceTemp decimal(18,2)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @outputTable table (id int);
	DECLARE @clientId int;
	DECLARE @userId int;
	DECLARE @personalDetailsId int;
	DECLARE @siteId int;
	DECLARE @userTypeId int;
	DECLARE @userSubTypeId int;
	DECLARE @userStatusId int;
	DECLARE @languageId int;
	DECLARE @genderTypeId int;
	DECLARE @titleTypeId int;
	DECLARE @salutationTypeId int;
	DECLARE @accountStatusTypeId int;
	DECLARE @currencyId int;

	SELECT TOP 1 @clientId = ClientId from Client where Name = @ClientName;
	SELECT TOP 1 @siteId = SiteId from Site where SiteRef = @SiteRef and ClientId = @clientId;
	SELECT TOP 1 @userTypeId = UserTypeId from UserType where Name = @UserType and ClientId = @clientId;
	SELECT TOP 1 @userSubTypeId = UserSubTypeId from UserSubType where Name = @UserSubType and ClientId = @clientId;
	SELECT TOP 1 @userStatusId = UserStatusId from UserStatus where name = @UserStatus and ClientId = @clientId;
	SELECT TOP 1 @languageId = LanguageId from Language where LanguageCode = @LanguageCode and ClientId = @clientId;
	SELECT TOP 1 @genderTypeId = GenderTypeId from GenderType where Name = @GenderType and ClientId = @clientId;
	
	
	DECLARE @titleType VARCHAR(60); 
	DECLARE @salutationTypeCheck VARCHAR(60); 
	-- logic to populate title and salutation type as they are provided using codes
	select 
		@titleType = case 
			when @TitleTypeCode = '01' then	'NULL'
			when @TitleTypeCode = '02' then	'NULL'
			when @TitleTypeCode = '03' then	'NULL'
			when @TitleTypeCode = '05' then	'NULL'
			when @TitleTypeCode = '06' then	'Dr'
			when @TitleTypeCode = '08' then	'Dr med'
			when @TitleTypeCode = '09' then	'Prof'
			when @TitleTypeCode = '10' then	'Dr'
			when @TitleTypeCode = '32' then	'NULL'
			when @TitleTypeCode = '39' then	'Dr med'
			when @TitleTypeCode = '40' then	'Prof'
		end ,
		@salutationTypeCheck = case  
			when @TitleTypeCode = '01' then	'Mr'
			when @TitleTypeCode = '02' then	'Mrs'
			when @TitleTypeCode = '03' then	'Ms'
			--when @TitleTypeCode = '05' then	'NULL'
			when @TitleTypeCode = '06' then	'Mr'
			when @TitleTypeCode = '08' then	'Mr'
			when @TitleTypeCode = '09' then	'Mr'
			when @TitleTypeCode = '10' then	'Mrs'
			when @TitleTypeCode = '32' then	'Company'
			when @TitleTypeCode = '39' then	'Mrs'
			when @TitleTypeCode = '40' then	'Mrs'
		end 

	SELECT TOP 1 @titleTypeId = TitleTypeId from TitleType where Name = @titleType and ClientId = @clientId;
	SELECT TOP 1 @salutationTypeId = SalutationTypeId from SalutationType where Name = 	@salutationTypeCheck and ClientId = @clientId;

    print @DateOfBirth
	--populate personaldetailsid
	INSERT INTO PersonalDetails 
		(Version, Firstname, Lastname, DateOfBirth, GenderTypeId, TitleTypeId, SalutationId, LastUpdated)
	output inserted.PersonalDetailsId into @outputTable
	VALUES 
		(1, @FirstName, @LastName, @DateOfBirth, @genderTypeId, @titleTypeId, @salutationTypeId, GETDATE())

    print 'end personal details'
	select @personalDetailsId = id from @outputTable;
	delete from @outputTable;
	print 'delete from PersonalDetails where PersonalDetailsId = ' + convert(NVARCHAR(15),@personalDetailsId);


	DECLARE @contactDetailsId int;
	DECLARE @contactDetailsTypeId int;
	
	SELECT TOP 1 @contactDetailsTypeId = ContactDetailsTypeId FROM ContactDetailsType where Name = 'Main' and ClientId = @clientId;

	-- populate @contactDetailsId
	INSERT INTO ContactDetails
		(Version, Email, Phone, MobilePhone, Fax, ContactDetailsTypeId, LastUpdated)
		OUTPUT INSERTED.ContactDetailsId into @outputTable
	VALUES
		(1, @Email, @Phone, @MobilePhone, @Fax, @contactDetailsTypeId, GETDATE())
	

	select @contactDetailsId = id from @outputTable;
	delete from @outputTable;
	print 'delete from ContactDetails where ContactDetailsId = ' + convert( NVARCHAR(15),@contactDetailsId);
	
	DECLARE @userLoyaltyDataId int;

	insert into UserLoyaltyData
		(Version, LoyaltySignupDate, LoyaltyApplicationSigned, CreatedBy, LastUpdated, TurnoverYTD, TurnoverLastYear, TurnoverAll)
	output INSERTED.UserLoyaltyDataId into @outputTable
		VALUES(1, GETDATE(), 1, 1400006, GETDATE(), 0, @TurnoverBalance, @TurnoverBalance);


	select @userLoyaltyDataId = id from @outputTable;
	delete from @outputTable;
	print 'delete from UserLoyaltyData where UserLoyaltyDataId = ' + convert( NVARCHAR(15), @userLoyaltyDataId);


	DECLARE @addressId int; 
	DECLARE @addressTypeId int;
	DECLARE @addressStatusId int;
	DECLARE @countryId int;
	DECLARE @addressValidStatusId int;
	
	SELECT TOP 1 @addressTypeId = AddressTypeId FROM AddressType WHERE Name = @AddressType and ClientId = @clientId;
	SELECT TOP 1 @addressStatusId = AddressStatusId FROM AddressStatus WHERE Name = @AddressStatus and ClientId = @clientId;
	SELECT TOP 1 @countryId = CountryId FROM Country WHERE CountryCode = @Country and ClientId = @clientId;
	SELECT TOP 1 @addressValidStatusId = AddressValidStatusId FROM AddressValidStatus where Name = 'Valid' and ClientId = @clientId;


	--populate userid
	INSERT INTO [User]  
		(Version, UserTypeId, UserSubTypeId, Username, Password, SiteId, CreateDate, ExpirationDate, UserStatusId, PersonalDetailsId,UserLoyaltyDataId, LanguageId, ContactByEmail, ContactByMail,
		 ContactBySms, ContactByPhone, LastUpdatedDate, EmailAddressAuthenticated, LoginAttemptCounter, UserAccountLocked, UnauthenticatedUniqueIdentifier ) 
		 OUTPUT INSERTED.UserId into @outputTable
	VALUES
		(1, @userTypeId, @userSubTypeId, @Username,'NotSet', @siteId, GETDATE(), null, @userStatusId, @personalDetailsId, @userLoyaltyDataId, @languageId, @ContactByEmail, @ContactByMail,
		@ContactBySms, @ContactByPhone, GETDATE(), 'false', 0, 0, lower(newid()))
		
	select @userId = id from @outputTable;
	delete from @outputTable;
	print 'delete from [User] where UserId = ' + convert(NVARCHAR(15), @userId);
	
	-- USER CONTACT DETAILS
	insert into UserContactDetails
		(UserId, ContactDetailsId)
	VALUES 
		(@userId, @contactDetailsId);
	print 'delete from [UserContactDetails] where UserId = ' + convert(NVARCHAR(15), @userId);


	--populate addressid
	INSERT INTO Address
		(Version, AddressTypeId, AddressStatusId, AddressLine1, AddressLine2, HouseName, HouseNumber, Street, Locality, City,  Zip, CountryId, ValidFromDate, AddressValidStatusId,
		 PostBox, PostBoxNumber, ContactDetailsId, LastUpdatedBy, LastUpdated)
		 OUTPUT INSERTED.AddressId into @outputTable
	VALUES 
		( 1, @addressTypeId, @addressStatusId, @AddressLine1, @AddressLine2, @HouseName, @HouseNumber, @Street, @Locality, @City,  @Zip, 11, GETDATE(), @addressValidStatusId,
			@PostBox, @PostBoxNumber, @contactDetailsId, 1400006, GETDATE())


	select @addressId = id from @outputTable;
	delete from @outputTable;
	print  'delete from Address where AddressId = ' + convert( NVARCHAR(15),@addressId);

	INSERT INTO UserAddresses
		(Version, UserId, AddressId)
	VALUES
		(1, @userId, @addressId);

	print 'delete from UserAddresses where UserId = ' + convert( NVARCHAR(15),@userId)


	SELECT TOP 1 @accountStatusTypeId = AccountStatusId FROM AccountStatus WHERE name = 'Enable' and ClientId = @clientId;
	SELECT TOP 1 @currencyId = Id FROM Currency WHERE Name = 'USD' and ClientId = @clientId;


	-- change this to populate user balance etc
	--INSERT INTO Account 
	--		(Version, UserId, AccountStatusTypeId, CreateDate, MonetaryBalance, PointsBalance, CurrencyId)
	--	OUTPUT INSERTED.AccountId into @outputTable
	--VALUES
	--		(0, @userId, @accountStatusTypeId, GETDATE(), @MonetaryBalance, @PointsBalance, @currencyId);

	
	--select @accountId = id from @outputTable;
	--print convert( VARchar(1000), 'delete from Account where AccountId = ' + convert( VARchar(100), @accountId))
	--delete from @outputTable;
	
	-- user profile extra info
	INSERT INTO UserProfileExtraInfo
		(UserId, SocialSecurity , Covercard, MpiId)
	VALUES
		(@userId, @SocialSecurity, @Covercard, @MpiId);

	delete from UserProfileExtraInfo where userid = @userId and SocialSecurity is null and Covercard is null and MpiId is null;

	print 'delete from UserProfileExtraInfo where UserId = ' + convert( nvarchar(15),@userId)

	--register device
	DECLARE @deviceId nvarchar(25);
	DECLARE @parentSiteId int;
	DECLARE @deviceUpdateRows int;
	declare @deviceStatusId int;
	DECLARE @deviceTypeId int;

	select top 1 @deviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @clientId and Name = @DeviceStatus;

	select top 1 @deviceTypeId = DeviceTypeId from DeviceType where ClientId = @clientId and Name= @DeviceType;

	-- gets the parent site id from site ref supplied 
	select top 1 @parentSiteId = ParentId from Site where SiteId = @siteId and ClientId = @clientId;

	--print  'Parent Site id ' + CONVERT(nvarchar(2), @parentSiteId)
	--print  'Site id ' + CONVERT(nvarchar(2), @siteId)

	DECLARE @deviceIdOutput TABLE(id nvarchar(25), accountId int)

	-- get available device 
	insert into @deviceIdOutput
	select top 1 d.DeviceId , d.AccountId
	from DeviceProfile dp
	join DeviceProfileTemplate dpt on dp.DeviceProfileId = dpt.id
	join DeviceProfileTemplateType dptt on dpt.DeviceProfileTemplateTypeId = dptt.Id
	join Device d on dp.DeviceId = d.Id
	join DeviceStatus ds on d.DeviceStatusId = ds.DeviceStatusId
	where dptt.Name = 'Loyalty'
	and dptt.ClientId = @clientId
	and d.HomeSiteId = @parentSiteId
	and d.UserId is null
	and ExpirationDate > GETDATE()
	and ds.Name = 'Active'

	select @deviceId = id from @deviceIdOutput;

	update Device
	set userid = @userId,
		HomeSiteId = @siteId,
		StartDate = GETDATE(),
		DeviceStatusId = @deviceStatusId--,
		--Deleted = 0
	where DeviceId = @deviceId
	
	print @deviceId;
	print 'Device updated rows ' + convert(nvarchar(5), @@rowcount);
	

	DECLARE @accountId int;
	select @accountId = accountId from @deviceIdOutput;

	-- update account
	update Account
	set UserId = @userId,
	PointsBalance = @PointsBalance,
	MonetaryBalance = @MonetaryBalance
	where AccountId = @accountId
	and UserId is null;

	print @accountId;

	-- creates inital points transaction
	exec CreateInitialPointsTransactionsSingleUser @deviceId, @PointsBalance, @siteId

	-- inserts into migrated users table
	insert into MigratedUser (id, Version, CommunityId, OldIdentifier, DeviceId) values (@userId, @Version, @CommunityId, @oldDeviceId, @deviceId)
	
	-- returns user id
	return @userId;
END
