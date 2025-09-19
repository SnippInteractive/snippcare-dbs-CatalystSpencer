-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <18/08/2016>
-- Description:	<Creates new site>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateClientSite](
		@ClientId int,
		@AddressLine1 nvarchar(100),
		@City nvarchar(60),
		@Country nvarchar(60),
		@Zip nvarchar(10),
		@Email nvarchar (80),
		@Phone nvarchar (50),
		@MobilePhone nvarchar (50),
		@Fax nvarchar (50),
		@SiteName nvarchar(50),
		@SiteType nvarchar(75),
		@CompanyName nvarchar(100),
		@SiteRef nvarchar(30),
		@Language nvarchar(80),
		@CashToPointThreshold decimal(18, 2),
		@PointsToCashThreshold decimal(18, 2))
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @table table (id int)
	DECLARE @contactDetailsId int
	DECLARE @addressId int
	DECLARE @addressTypeId int
	DECLARE @addressStatusId int
	DECLARE @countryId int
	DECLARE @addressValidStatusId int
	DECLARE @contactDetailsTypeId int
	DECLARE @parentTypeId int
	DECLARE @parentSiteId int
	DECLARE @siteStatusId int
	DECLARE @siteTypeId int
	DECLARE @languageId int
	
	select @contactDetailsTypeId = ContactDetailsTypeId 
	from ContactDetailsType
	where ClientId = @ClientId
	and Name = 'Main';
	
	insert into ContactDetails (Version, Email, Phone, MobilePhone, Fax, ContactDetailsTypeId, LastUpdated)
	output Inserted.ContactDetailsId  into @table
	values (
		1, @Email, @Phone, 
		@MobilePhone, @Fax, 
		@contactDetailsTypeId, GETDATE()
	);

	select @addressTypeId =  AddressTypeId from addresstype
	where clientid = @ClientId
	and Name = 'Main';

	select @addressStatusId = AddressStatusId from AddressStatus
	where clientid = @ClientId
	and Name = 'Current';

	select @countryId = CountryId from Country
	where ClientId = @ClientId
	and lower(Name) = lower(@Country);

	select @addressValidStatusId = AddressValidStatusId 
	from AddressValidStatus
	where ClientId = @ClientId
	and Name = 'Valid';

	SELECT @contactDetailsId = id from @table;

	delete from @table;
    
	insert into Address (Version,AddressTypeId,AddressStatusId,AddressLine1,AddressLine2,City,CountryId, Zip, ValidFromDate,ContactDetailsId, AddressValidStatusId ,LastUpdatedBy ,LastUpdated)
	output Inserted.AddressId into @table
	values (
		1, @addressTypeId, @addressStatusId, 
		@AddressLine1, '', @City, @countryId, @Zip ,
		GETDATE(), @contactDetailsId,
		@addressValidStatusId, 1400006, getdate()
	);

	SELECT @addressId = id from @table;
	
	select @parentSiteId = SiteTypeId
	from SiteType
	where ClientId = @ClientId
	and Name = 'HeadOffice';

	select @parentSiteId = SiteId
	from Site 
	where SiteTypeId = @parentSiteId
	and ClientId = @ClientId;

	select @siteStatusId = SiteStatusId
	from SiteStatus
	where ClientId = @ClientId
	and Name = 'Active';

	select @siteTypeId = SiteTypeId
	from SiteType
	where ClientId = @ClientId
	and Name = @SiteType;

	select @languageId = LanguageId
	from Language
	where ClientId = @ClientId
	and lower(Name) = lower(@Language);

	insert into Site (
		Version, Name, ParentId, SiteStatusId, 
		SiteTypeId, AddressId, ClientId, ContactDetailsId, CompanyName, SiteRef, 
		LanguageId, Display, CountryId, UpdatedBy, UpdatedDate, 
		CashToPointThreshold, PointsToCashThreshold)
	output Inserted.SiteId
	values(
		1, @SiteName, @parentSiteId,
		@siteStatusId, @siteTypeId, @addressId,
		@ClientId, @ContactDetailsId, 
		@CompanyName, @SiteRef, @languageId, 1, @countryId, 1400006, getdate(),
		@CashToPointThreshold, @PointsToCashThreshold
	);

END
