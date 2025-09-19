
CREATE PROCEDURE [dbo].[UpdateShelterDataAndAddBonusCode]
(
	@ClientId		INT,
	@UserId			INT,
	@BonusValue		INT = 25,
	@ExtensionData	NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @UserLoyaltyDataId INT,
			@BonusCode INT,
			@ShelterBonusCode NVARCHAR(100)= 'SHELTERBONUS',
			@SiteId INT,
			@DeviceStatusId INT,
			@ExpirationDate DATETIME,
			@Result VARCHAR(2) = '0',
			@ExistingShelterBonusCode NVARCHAR(100)

	DECLARE @ExtensionTable TABLE
	(
		Id					INT IDENTITY(1,1),
		UserLoyaltyDataId	INT, 
		PropertyName		VARCHAR(100),
		PropertyValue		VARCHAR(100)
	)

	SELECT	@UserLoyaltyDataId = UserLoyaltyDataId 
	FROM	[User]
	WHERE	UserId = @UserId



	SELECT	@BonusCode = ISNULL(MAX(convert(int,replace (propertyvalue,'SHELTERBONUS',''))),1000)+1
	FROM	userloyaltyextensiondata
	WHERE	propertyname = 'shelter_bonus_code'

	SELECT	@SiteId = SiteId 
	FROM	[Site] 
	WHERE	ClientId = @ClientId
	AND		SiteRef = 'CLOROXHEAD'

	SELECT  @DeviceStatusId = DeviceStatusId
	FROM    DeviceStatus
	WHERE   ClientId = @ClientId
	AND		NAme = 'Active'

	SET     @ExpirationDate = '2025-01-01'

	SET @ShelterBonusCode = @ShelterBonusCode + CAST(@BonusCode AS VARCHAR(100))
	SET NOCOUNT ON;  
	SET XACT_ABORT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
	BEGIN TRY

		/*-------------------------------------------------
			CHECKING WHETHER THE GIVEN STRING IS IN JSON FORMAT
		---------------------------------------------------*/
		IF ISJSON(@ExtensionData)= 0 OR ISNULL(ISJSON(@ExtensionData),'')= ''
		BEGIN
			SELECT '0' as Result
			RETURN
		END

		/*-------------------------------------------------
			ADDING JSON DATA IN A TABLE VARIABLE
		---------------------------------------------------*/
		INSERT	@ExtensionTable(UserLoyaltyDataId,PropertyName,PropertyValue)
		SELECT	@UserLoyaltyDataId,PropertyName,PropertyValue
		FROM	OPENJSON(@ExtensionData)
		WITH	
		(
				PropertyName VARCHAR(100),
				PropertyValue VARCHAR(100)
		)
		/*
			AVOIDING THE SHELTER TO BE UPDATED AS APPROVED IF ein_validation IS TRUE AND
			ein IS BEING USED BY OTHER SHELTERS
		*/
		IF EXISTS(SELECT 1 FROM @ExtensionTable WHERE PropertyName = 'ein_validation' AND LOWER(PropertyValue) = 'y')
		AND EXISTS(SELECT 1 FROM @ExtensionTable WHERE PropertyName ='Status' AND LOWER(PropertyValue) = 'approved')
		BEGIN
			DECLARE @ein NVARCHAR(100)='',@shelterCount INT
			SELECT @ein = PropertyValue 
			FROM @ExtensionTable
			WHERE LOWER(PropertyName) = 'ein'

			SELECT @shelterCount = COUNT(1) 
			FROM
			(
				SELECT	UserLoyaltyDataId,PropertyName,PropertyValue 
				FROM	UserLoyaltyExtensionData 
				WHERE	PropertyName IN ('Name','Ein','Status')
				AND		UserLoyaltyDataId <> @UserLoyaltyDataId 

			)Table1
			PIVOT
			(
				MIN(PropertyValue)
				FOR 
				PropertyName
				IN(Name,Ein,Status)
			)as p
			WHERE p.Status = 'Approved'
			AND   p.Ein = @ein

			IF @shelterCount > 0
			
			BEGIN
				SET @Result = '2'
				SELECT @Result as Result
				RETURN
			END
		END

		BEGIN TRAN
		/*-------------------------------------------------
			UPDATING EXTENSION DATA
		---------------------------------------------------*/
		IF(SELECT COUNT(Id) FROM @ExtensionTable)> 0
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM UserLoyaltyExtensionData WHERE UserLoyaltyDataId = @UserLoyaltyDataId AND LOWER(PropertyName) = 'status_log')
			BEGIN
				DECLARE @statusLog NVARCHAR(MAX)=''
				SELECT @statusLog = PropertyValue FROM @ExtensionTable WHERE LOWER(PropertyName) = 'status_log' 
				INSERT UserLoyaltyExtensionData(Version,UserLoyaltyDataId,PropertyName,PropertyValue,GroupId,DisplayOrder,Deleted)
				VALUES(1,@UserLoyaltyDataId,'status_log',@statusLog,1,1,0)
			END
			UPDATE		uled
			SET			uled.PropertyValue = tuled.PropertyValue
			FROM		UserLoyaltyExtensionData uled
			INNER JOIN	@ExtensionTable tuled
			ON			uled.UserLoyaltyDataId = tuled.UserLoyaltyDataId
			WHERE		uled.PropertyName COLLATE SQL_Latin1_General_CP1_CI_AS = tuled.PropertyName COLLATE SQL_Latin1_General_CP1_CI_AS
		END

		/*-------------------------------------------------
			ADDING BONUS CODE EXTENSION DATA
		---------------------------------------------------*/
		IF NOT EXISTS(SELECT 1 FROM UserLoyaltyExtensionData WHERE UserLoyaltyDataId = @UserLoyaltyDataId AND PropertyName = 'shelter_bonus_code')
		AND EXISTS(SELECT 1 FROM UserLoyaltyExtensionData WHERE UserLoyaltyDataId = @UserLoyaltyDataId AND PropertyName = 'Status'
		AND LOWER(PropertyValue) = 'approved')
		BEGIN
			INSERT UserLoyaltyExtensionData(Version,UserLoyaltyDataId,PropertyName,PropertyValue,GroupId,DisplayOrder,Deleted)
			VALUES(0,@UserLoyaltyDataId,'shelter_bonus_code',@ShelterBonusCode,1,1,0)

			IF NOT EXISTS(SELECT 1 FROM VoucherCodes WHERE DeviceId = @ShelterBonusCode)
			BEGIN
				INSERT VoucherCodes(DeviceId,UserId,ClientId,SiteId,DeviceStatusId,ExpirationDate,ExtReference,[Value],ValueType,Classical,DateUsed,DeviceLotId,[code_id],[usage_id])
				VALUES(@ShelterBonusCode,@UserId,@ClientId,@SiteId,@DeviceStatusId,@ExpirationDate,'ShelterCode',@BonusValue,'Points',1,NULL,NULL,@UserId,NULL)
			END	
		END

		/*-------------------------------------------------
			Deleting shelter data if Rejected from Approved
		---------------------------------------------------*/
		IF EXISTS(SELECT 1 FROM UserLoyaltyExtensionData WHERE UserLoyaltyDataId = @UserLoyaltyDataId AND PropertyName = 'shelter_bonus_code')
		AND EXISTS(SELECT 1 FROM UserLoyaltyExtensionData WHERE UserLoyaltyDataId = @UserLoyaltyDataId AND PropertyName = 'Status'
		AND LOWER(PropertyValue) = 'rejected')
		BEGIN

			SELECT @ExistingShelterBonusCode = PropertyValue FROM UserLoyaltyExtensionData WHERE UserLoyaltyDataId = @UserLoyaltyDataId AND PropertyName = 'shelter_bonus_code'
			DELETE FROM UserLoyaltyExtensionData WHERE UserLoyaltyDataId = @UserLoyaltyDataId AND PropertyName = 'shelter_bonus_code'
			
			IF EXISTS(SELECT 1 FROM VoucherCodes WHERE DeviceId = @ExistingShelterBonusCode)
			BEGIN
				-- ToBe Decided
				UPDATE VoucherCodes Set UserId = null WHERE DeviceId = @ExistingShelterBonusCode
			END	
		END

		COMMIT 
		SET @Result = '1'

	END TRY
	BEGIN CATCH
	ROLLBACK 
		SET @Result = '0'

	END CATCH

	SELECT @Result as Result
END
