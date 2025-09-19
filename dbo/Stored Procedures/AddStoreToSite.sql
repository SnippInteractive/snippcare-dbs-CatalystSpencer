-- =============================================
-- Author:		WEI LIU
-- Create date: 24/08/2022
-- Description:	Validate Site information from IPE
-- =============================================
CREATE PROCEDURE [dbo].[AddStoreToSite] (@StoreName NVARCHAR(100), @StoreId NVARCHAR(100), @LocationId NVARCHAR(100) = '',
		@City NVARCHAR(100) = '', @State NVARCHAR(10)= '', @ZipCode NVARCHAR(100)= '', @Phone NVARCHAR(100)= '', @ClientId INT=1, 
		@Source NVARCHAR(20)='IPE', @StoreNumber NVARCHAR(100) = '0')
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets FROM
    SET NOCOUNT ON;

	-- This SP validate Site Taking from IPE
    -- It takes tree structure approach:
	-- Root - Head Office Site
	-- Branch - US or CA Site under Root Site
	-- Sub Branch - Group site by store id which under the Branch site
	-- Leaf - Location Site stored under Sub-Branch Site

    DECLARE @batchprocessAdmin INT, 
	@StoreSiteId INT = 0,
	@ParentHeadId INT,
	@ParentGroupId INT= 0,
	@CountryId INT = 7,
	@CountryCode NVARCHAR(10)= 'US',
	@StateId INT,
	@AddressTypeId INT, 
	@AddressStatusId INT,
	@AddressValidStatusId INT,
	@AddressId INT,
	@ContactDetailsId INT,
	@SiteRef NVARCHAR(50),
	@InstallerRequired NVARCHAR(10) = 'false',
	@SiteTypeId INT,
	@SiteTypeGroupId INT;

	SELECT @AddressTypeId = AddressTypeId FROM AddressType WHERE [Name] = 'Main'

	SELECT @AddressStatusId = AddressStatusId FROM AddressStatus WHERE [Name] = 'Current'

	SELECT @AddressValidStatusId = AddressValidStatusId FROM AddressValidStatus WHERE [Name] = 'Valid'

	SELECT @batchprocessAdmin = UserId FROM [User] WHERE Username='batchprocessadmin'

    SELECT @StoreSiteId = SiteId FROM [Site] WHERE SiteRef = @StoreId and ClientId=@ClientId 

	SELECT @SiteTypeId = SiteTypeId FROM SiteType WHERE Name = 'Store' and Clientid=@ClientId

	SELECT @SiteTypeGroupId = SiteTypeId FROM SiteType WHERE Name = 'AreaGroup' and Clientid=@ClientId

	SELECT @InstallerRequired=Value FROM ClientConfig WHERE [Key] ='InstallerInfoRequired' and ClientId=@ClientId

	-- Default to US for now, need to find solution for default country of each client
	SELECT @CountryId = CountryId FROM Country WHERE CountryCode = @CountryCode
	-----Get Country info by state (can be US or CA)
	IF @State != ''
	BEGIN
		SELECT Top 1 @CountryId = CountryId, @StateId = StateId FROM [State] WHERE StateCode = @State
		SELECT @CountryCode = CountryCode FROM Country WHERE CountryId = @CountryId
	END

	--Check Branch site - IKO
	IF @CountryCode = 'US' and @State != ''
	BEGIN
		IF EXISTS(SELECT [NAME] FROM CLIENT WHERE [NAME] = 'iko')
		BEGIN
			SELECT @ParentGroupId = SiteId FROM [Site] WHERE SiteRef = 'IKO_USA'
		END
	END
	ELSE IF @CountryCode = 'CA' and @State != ''
	BEGIN
		IF EXISTS(SELECT [NAME] FROM CLIENT WHERE [NAME] = 'iko')
		BEGIN
			SELECT @ParentGroupId = SiteId FROM [Site] WHERE SiteRef = 'IKO_Canada'
		END
	END
	
	-- IF other client that is not IKO, then select the default head site
	IF @ParentGroupId = 0
	BEGIN
		 SELECT @ParentGroupId = SiteId FROM [Site] WHERE [Name] like '%Head%' and ClientId=@ClientId
	END

	IF @InstallerRequired = 'true'
	BEGIN
		SELECT @SiteTypeId=SiteTypeId FROM SiteType WHERE Name='Installer' and Clientid=@ClientId
	END

	-- First Check: Make sure if site exist by location id (Leaf)
	IF EXISTS (SELECT TOP 1 * FROM [Site] WHERE SITEREF = @LocationId)
	BEGIN
		-- Check if the address exist for the location store (leaf)
		IF (SELECT AddressId FROM [Site] WHERE SITEREF = @LocationId) IS NULL
		BEGIN
			-- If does not exist then we add the address give and update the address id in site table
			INSERT INTO [dbo].[Address] ([Version] ,[AddressTypeId] ,[AddressStatusId],[AddressLine1],[City],[Zip],[CountryId], [AddressValidStatusId], [LastUpdatedBy],[LastUpdated] ,[StateId])
			VALUES ( 0, @AddressTypeId, @AddressStatusId , @StoreName , @City, @ZipCode, @CountryId, @AddressValidStatusId,  @batchprocessAdmin, GETDATE(), @StateId)

			SELECT @AddressId = SCOPE_IDENTITY()

			UPDATE [SITE] SET AddressId = @AddressId WHERE SITEREF = @LocationId

		END
		-- Check if contact detail for the location store exist
		IF (SELECT ContactDetailsId FROM [Site] WHERE SITEREF = @LocationId) IS NULL
		BEGIN
			-- If does not exist then we add the address give and update the address id in site table
			INSERT INTO [dbo].[ContactDetails] ([Version] , Phone, MobilePhone, ContactDetailsTypeId, EmailStatusId, LastUpdated)
			VALUES ( 0, @Phone, @Phone, 1, 1, GETDATE())

			SELECT @ContactDetailsId = SCOPE_IDENTITY()

			UPDATE [SITE] SET ContactDetailsId = @ContactDetailsId WHERE SITEREF = @LocationId

		END
		-- Check if store number/store branch already exist in the site table (Permission field = store number)
		IF (SELECT Permission FROM [Site] WHERE SITEREF = @LocationId) IS NULL
		BEGIN
			UPDATE [SITE] SET Permission = @StoreNumber WHERE SITEREF = @LocationId
		END
	END
	-- Second Check If first check does not meet the condition: 
	-- Then if store exist with store id (group) then we add (leaf) site under the store group site (sub-branch) 
	ELSE IF @StoreSiteId != 0
	BEGIN
		IF @LocationId != ''
		BEGIN
			INSERT INTO [dbo].[Address] ([Version] ,[AddressTypeId] ,[AddressStatusId],[AddressLine1],[City],[Zip],[CountryId], [AddressValidStatusId], [LastUpdatedBy],[LastUpdated] ,[StateId])
			VALUES ( 0, @AddressTypeId, @AddressStatusId , @StoreName , @City, @ZipCode, @CountryId, @AddressValidStatusId,  @batchprocessAdmin, GETDATE(), @StateId)

			SELECT @AddressId = SCOPE_IDENTITY()

			INSERT INTO [dbo].[ContactDetails] ([Version] , Phone, MobilePhone, ContactDetailsTypeId, EmailStatusId, LastUpdated)
			VALUES ( 0, @Phone, @Phone, 1, 1, GETDATE())

			SELECT @ContactDetailsId = SCOPE_IDENTITY()
			-- Add new location store site(leaf)
			INSERT INTO [Site] (Version,Name,ParentId,SiteStatusId,SiteTypeId,ClientId, AddressId, ContactDetailsId,  CompanyName,SiteRef,LanguageId,Display,CountryId,UpdatedBy,UpdatedDate,CashToPoINTThreshold,PoINTsToCashThreshold,CommunicationName,Channel, Permission) 
			VALUES (1, @StoreName + ' - ' + @City, @StoreSiteId, 1 ,@SiteTypeId, @ClientId, @AddressId, @ContactDetailsId, @StoreName, @LocationId, 1, 1, @CountryId, @batchprocessAdmin, GETDATE(), 1, 100, @StoreId, @Source, @StoreNumber)
		END
	END
	-- Third Check if Store group site also does not exist
	-- Then Add store site (sub-branch) and location site (leaf) with the address and contact info
	ELSE IF @StoreSiteId = 0
	BEGIN

		INSERT INTO [dbo].[Address] ([Version] ,[AddressTypeId] ,[AddressStatusId],[AddressLine1],[City],[Zip],[CountryId], [AddressValidStatusId], [LastUpdatedBy],[LastUpdated] ,[StateId])
		VALUES ( 0, @AddressTypeId, @AddressStatusId , @StoreName , @City, @ZipCode, @CountryId, @AddressValidStatusId,  @batchprocessAdmin, GETDATE(), @StateId)

		SELECT @AddressId = SCOPE_IDENTITY()

		INSERT INTO [dbo].[ContactDetails] ([Version] , Phone, MobilePhone, ContactDetailsTypeId, EmailStatusId, LastUpdated)
		VALUES ( 0, @Phone, @Phone, 1, 1, GETDATE())

		SELECT @ContactDetailsId = SCOPE_IDENTITY()

		-- Add new group store site (sub-branch)
		INSERT INTO [Site] (Version,Name,ParentId,SiteStatusId,SiteTypeId,ClientId, CompanyName,SiteRef,LanguageId,Display,CountryId,UpdatedBy,UpdatedDate,CashToPoINTThreshold,PoINTsToCashThreshold,CommunicationName,Channel) 
		VALUES (1, @StoreName , @ParentGroupId, 1 ,@SiteTypeGroupId, @ClientId, @StoreName, @StoreId, 1, 1, @CountryId, @batchprocessAdmin, GETDATE(), 1, 100, @StoreId, @Source)

		-- Add new location store site(leaf)
		INSERT INTO [Site] (Version,Name,ParentId,SiteStatusId,SiteTypeId,ClientId, AddressId, ContactDetailsId,  CompanyName,SiteRef,LanguageId,Display,CountryId,UpdatedBy,UpdatedDate,CashToPoINTThreshold,PoINTsToCashThreshold,CommunicationName,Channel, Permission) 
		VALUES (1, @StoreName + ' - ' + @City, SCOPE_IDENTITY(), 1 ,@SiteTypeId, @ClientId, @AddressId, @ContactDetailsId, @StoreName, @LocationId, 1, 1, @CountryId, @batchprocessAdmin, GETDATE(), 1, 100, @StoreId, @Source, @StoreNumber)

	END
    
END
