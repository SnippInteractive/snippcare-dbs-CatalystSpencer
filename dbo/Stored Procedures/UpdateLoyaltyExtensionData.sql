CREATE PROCEDURE [dbo].[UpdateLoyaltyExtensionData]
(
	@ExtensionData			NVARCHAR(MAX) = '',-- ExtensionData in JSON format
	@UserLoyaltyDataId		INT,
	@LoggedInUserId			INT
)
AS
BEGIN
		SET NOCOUNT ON

		DECLARE @Result			NVARCHAR(MAX) = '',
				@OldExtensions	NVARCHAR(MAX) = '',
				@NewExtensions  NVARCHAR(MAX) = ''

		DECLARE @ExtensionDataTable TABLE
		(
			PropertyName		NVARCHAR(100),
			PropertyValue		NVARCHAR(100),
			AlreadyExists		BIT
		)
		-- Validating whether the passed ExtensionData is in JSON format
		IF ISJSON(@ExtensionData) = 0
		BEGIN
			SET @Result = 'InvalidJson'
			SELECT @Result AS Result
			RETURN
		END

		-- Validating the UserLoyaltyDataId
		IF ISNULL(@UserLoyaltyDataId,0) = 0 OR NOT EXISTS(SELECT Top 1 * FROM UserLoyaltyExtensionData WHERE UserLoyaltyDataId = @UserLoyaltyDataId)
		BEGIN
			SET @Result = 'InvalidLoyaltyDataId'
			SELECT @Result AS Result
			RETURN
		END

		INSERT @ExtensionDataTable(PropertyName,PropertyValue)
		SELECT PropertyName,PropertyValue 
		FROM OPENJSON(@ExtensionData)
		WITH
		(
			PropertyName NVARCHAR(100),
			PropertyValue NVARCHAR(100)
		)

		IF NOT EXISTS(SELECT 1 FROM @ExtensionDataTable)
		BEGIN
			SET @Result = 'InvalidExtensions'
			SELECT @Result AS Result
			RETURN
		END
		--BEGIN TRAN
		BEGIN TRY
				DECLARE @SiteId INT,@UserId INT 
				SELECT TOP 1 @SiteId = SiteId,@UserId = UserId 
				FROM [USer] (nolock) 
				WHERE UserLoyaltyDataId = @UserLoyaltyDataId

				-- Updating the AlreadyExists flag in the temp table
				UPDATE		temp
				SET         temp.AlreadyExists = 1
				FROM        UserLoyaltyExtensiondata uled (nolock)
				INNER JOIN  @ExtensionDataTable temp
				ON			uled.PropertyName COLLATE SQL_Latin1_General_CP1_CI_AS = temp.PropertyName COLLATE SQL_Latin1_General_CP1_CI_AS
				WHERE       uled.UserLoyaltyDataId = @UserLoyaltyDataId


				
				IF EXISTS(SELECT 1 FROM @ExtensionDataTable WHERE ISNULL(AlreadyExists,0) = 1)
				BEGIN
					
					SELECT		@OldExtensions = @OldExtensions + uled.PropertyName  + ':' + ISNULL(uled.PropertyValue ,'') + ',',
								@NewExtensions = @NewExtensions + temp.PropertyName  + ':' + ISNULL(temp.PropertyValue ,'') + ','

					FROM        UserLoyaltyExtensiondata uled (nolock)
					INNER JOIN  @ExtensionDataTable temp
					ON			uled.PropertyName COLLATE SQL_Latin1_General_CP1_CI_AS = temp.PropertyName COLLATE SQL_Latin1_General_CP1_CI_AS
					WHERE       uled.UserLoyaltyDataId = @UserLoyaltyDataId
					AND			temp.AlreadyExists = 1
					AND         uled.PropertyValue COLLATE SQL_Latin1_General_CP1_CI_AS <> temp.PropertyValue COLLATE SQL_Latin1_General_CP1_CI_AS

					SET @OldExtensions = CASE WHEN LEN(@OldExtensions) > 1 THEN LEFT(@OldExtensions,LEN(@OldExtensions)-1) ELSE @OldExtensions END
					SET @NewExtensions = CASE WHEN LEN(@NewExtensions) > 1 THEN LEFT(@NewExtensions,LEN(@NewExtensions)-1) ELSE @NewExtensions END
				END

				-- Updates the existing extension data with new property values.
				UPDATE		uled
				SET         uled.PropertyValue = temp.PropertyValue,
							[Version] = [Version] + 1
				FROM        UserLoyaltyExtensiondata uled (nolock)
				INNER JOIN  @ExtensionDataTable temp
				ON			uled.PropertyName COLLATE SQL_Latin1_General_CP1_CI_AS = temp.PropertyName COLLATE SQL_Latin1_General_CP1_CI_AS
				WHERE       uled.UserLoyaltyDataId = @UserLoyaltyDataId
				AND			temp.AlreadyExists = 1

				-- Auditing the entries
				IF EXISTS(SELECT 1 FROM @ExtensionDataTable WHERE ISNULL(AlreadyExists,0) = 1) AND 
							LEN(ISNULL(@OldExtensions,0))> 0 AND LEN(ISNULL(@NewExtensions,0)) > 0
				BEGIN
					INSERT [Audit](Version,UserId,FieldName,NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType,SiteId,SysUser)
					VALUES(0,@UserId,'Loyalty Extension Data',@NewExtensions,@OldExtensions,GETDATE(),@LoggedInUserId,'Modifying Extension Data','Loyalty Extension Data',@SiteId,0)
				END

				IF EXISTS(SELECT 1 FROM @ExtensionDataTable WHERE ISNULL(AlreadyExists,0) = 0)
				BEGIN
					
					SELECT		@NewExtensions = @NewExtensions + temp.PropertyName  + ':' + ISNULL(temp.PropertyValue ,'') + ','
					FROM        @ExtensionDataTable temp
					WHERE       temp.AlreadyExists = 0

					SET @NewExtensions = CASE WHEN LEN(@NewExtensions) > 1 THEN LEFT(@NewExtensions,LEN(@NewExtensions)-1) ELSE @NewExtensions END
				END

				-- Inserts the new extension values.
				INSERT UserLoyaltyExtensionData(Version,UserLoyaltyDataId,PropertyName,PropertyValue,GroupId,DisplayOrder,Deleted)
				SELECT 0,@UserLoyaltyDataId,PropertyName,PropertyValue,1,1,0 
				FROM @ExtensionDataTable
				WHERE ISNULL(AlreadyExists,0) = 0

				-- Auditing the entries
				IF EXISTS(SELECT 1 FROM @ExtensionDataTable WHERE ISNULL(AlreadyExists,0) = 0) AND 
							LEN(ISNULL(@NewExtensions,0)) > 0
				BEGIN
					INSERT [Audit](Version,UserId,FieldName,NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType,SiteId,SysUser)
					VALUES(0,@UserId,'Loyalty Extension Data',@NewExtensions,NULL,GETDATE(),@LoggedInUserId,'Adding Extension Data','Loyalty Extension Data',@SiteId,0)
				END


				SET @Result = 'ExtensionsUpdated'
				SELECT @Result AS Result



				--COMMIT
		END TRY

		BEGIN CATCH
				SET @Result = 'ExtensionsUpdateFailed' 
				SELECT @Result AS Result
				--ROLLBACK
		END CATCH
END
