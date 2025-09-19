
CREATE PROCEDURE [dbo].[GetUserLoyaltyExtensionData]
(
	@SearchCriteria		NVARCHAR(MAX) =''
)
AS
BEGIN
		IF LEN(@SearchCriteria) = 0 OR ISJSON(@SearchCriteria) < 1
		BEGIN
			SELECT 'InvalidCriteria' AS Result
			RETURN
		END

		DECLARE @UserId		INT				= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.UserId') AS INT),
				@ClientId	INT				= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.ClientId') AS INT),
				@Email		NVARCHAR(100)	= JSON_VALUE(@SearchCriteria,'$.Email'),
				@Phone		NVARCHAR(100)	= JSON_VALUE(@SearchCriteria,'$.Phone')

		DECLARE	@UserLoyaltyDataId	INT,
				@ContactDetailsId	INT,
				@Result NVARCHAR(MAX) = ''


			
				
		IF @ClientId IS NULL
		BEGIN
			SELECT 'InvalidClient' AS Result
			RETURN
		END
		IF @UserId > 0
		BEGIN
			SELECT			Top 1 @UserLoyaltyDataId = u.UserLoyaltyDataId
			FROM			[User] u
			INNER JOIN		UserStatus us
			ON				u.UserStatusId = us.UserStatusId
			WHERE			u.UserId = @UserId 
			AND				us.ClientId = @ClientId 
			AND				us.Name = 'Active'
			
		END
		ELSE
		BEGIN

			IF LEN(ISNULL(@Email,'')) > 0
			BEGIN
				SELECT		TOP 1 @UserLoyaltyDataId = u.UserLoyaltyDataId
				FROM		ContactDetails cd
				INNER JOIN	ContactDetailsType cdt
				ON			cd.ContactDetailsTypeId = cdt.ContactDetailsTypeId
				INNER JOIN  UserContactDetails ucd
				ON			ucd.ContactDetailsId = cd.ContactDetailsId
				INNER JOIN  [User] u
				ON			u.UserId = ucd.UserId
				INNER JOIN  UserStatus us
				ON          u.UserStatusId = us.UserStatusId
				WHERE		cdt.Name = 'Main' 
				AND			cdt.ClientId = @ClientId
				AND			us.ClientId = @ClientId
				AND			us.Name = 'Active'
				AND			cd.Email = @Email
				--AND			u.UserName = @Email
			END

			IF LEN(ISNULL(@Phone,'')) > 0
			BEGIN
				SELECT		TOP 1 @UserLoyaltyDataId = u.UserLoyaltyDataId
				FROM		ContactDetails cd
				INNER JOIN	ContactDetailsType cdt
				ON			cd.ContactDetailsTypeId = cdt.ContactDetailsTypeId
				INNER JOIN  UserContactDetails ucd
				ON			ucd.ContactDetailsId = cd.ContactDetailsId
				INNER JOIN  [User] u
				ON			u.UserId = ucd.UserId
				INNER JOIN  UserStatus us
				ON          u.UserStatusId = us.UserStatusId
				WHERE		cdt.Name = 'Main' 
				AND			cdt.ClientId = @ClientId
				AND			us.ClientId = @ClientId
				AND			us.Name = 'Active'
				AND			cd.MobilePhone = @Phone
				--AND			u.UserName = @Phone
			END

		END

		IF @UserLoyaltyDataId IS NULL
		BEGIN
			SELECT 'UserNotFound' AS Result
			RETURN
		END

		SET @Result = 
		(
			SELECT	uled.PropertyName,uled.PropertyValue
			FROM	UserLoyaltyExtensionData uled
			WHERE	uled.UserLoyaltyDataId = @UserLoyaltyDataId
			FOR		JSON PATH
		)

		SELECT @Result AS Result

END
