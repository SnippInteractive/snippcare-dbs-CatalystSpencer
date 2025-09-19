CREATE PROCEDURE [dbo].[SavePetInfo]
	@MemberId INT,
	--@IsUpdate BIT,
	@GroupId INT,
	@PetInfoXml nvarchar(max)
AS
BEGIN
	DECLARE @xml XML, @UserLoyaltyDataId INT		

	SET @xml = @PetInfoXml

	SELECT  @UserLoyaltyDataId = ISNULL(UserLoyaltyDataId ,0) FROM	[User] WHERE   UserId = @MemberId

	DECLARE @ExtensionTable TABLE ([Key] VARCHAR(100),[Value] VARCHAR(100))

	INSERT @ExtensionTable ([Key],[Value])
	SELECT T.a.value('(Key)[1]','VARCHAR(100)')as [Key],T.a.value('(Value)[1]','VARCHAR(MAX)')as [Value]
	FROM @xml.nodes('/ArrayOfKeyValueOfstringstring/KeyValueOfstringstring') T(a)

	IF @UserLoyaltyDataId <> 0
	BEGIN
		
		IF EXISTS
		(
			SELECT		ext.ID
			FROM		UserLoyaltyExtensionData ext
			INNER JOIN	@ExtensionTable temp ON	ext.PropertyName COLLATE DATABASE_DEFAULT = temp.[Key] COLLATE DATABASE_DEFAULT
			--INNER JOIN  UserLoyaltyExtensionDataMapping extMap ON extMap.UserLoyaltyExtensionDataId = ext.ID 
			WHERE		UserLoyaltyDataId = @UserLoyaltyDataId and ext.GroupId = @GroupId				
		)
		BEGIN
			
			UPDATE		ext
			SET			ext.PropertyValue = temp.[Value]
			FROM        UserLoyaltyExtensionData ext
			INNER JOIN  @ExtensionTable temp ON	ext.PropertyName COLLATE DATABASE_DEFAULT = temp.[Key] COLLATE DATABASE_DEFAULT
			--INNER JOIN  UserLoyaltyExtensionDataMapping extMap ON extMap.UserLoyaltyExtensionDataId = ext.ID 
			WHERE		UserLoyaltyDataId = @UserLoyaltyDataId and ext.GroupId = @GroupId

		END
		ELSE
		BEGIN

			IF @GroupId = 0 
			BEGIN
				SET @GroupId = (SELECT		ISNULL(max(ext.groupId),0)+1
								FROM		UserLoyaltyExtensionData ext 
								WHERE		UserLoyaltyDataId = @UserLoyaltyDataId
											AND LOWER(ext.PropertyName) like 'pet%')
			END

			DECLARE @Key NVARCHAR(100), @Value NVARCHAR(MAX), @UserLoyaltyExtensionDataId INT;

			DECLARE cursor_petInfo CURSOR
			FOR SELECT [Key], [Value]
				FROM @ExtensionTable;

						OPEN cursor_petInfo;

						FETCH NEXT FROM cursor_petInfo INTO @Key, @Value;

						WHILE @@FETCH_STATUS = 0
							BEGIN

								if @Value = 'Select'
								Begin
									set @Value = ''
								end

								INSERT UserLoyaltyExtensionData(Version,UserLoyaltyDataId,PropertyName,PropertyValue,GroupId)
								VALUES(0,@UserLoyaltyDataId,@Key,@Value,@GroupId)


								FETCH NEXT FROM cursor_petInfo INTO @Key, @Value;
							END;

						CLOSE cursor_petInfo;
						DEALLOCATE cursor_petInfo;



		END
	END	
END