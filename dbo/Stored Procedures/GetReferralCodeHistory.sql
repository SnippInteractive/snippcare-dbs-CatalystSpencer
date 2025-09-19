/*---------------------------------- 
Written : Sreejith
Date : 08 Nov 2023
Details : used in catalyst->Cust.service->ReferralHistory
-----------------------------------*/
CREATE PROCEDURE [dbo].[GetReferralCodeHistory]
(
	@ReferralCode		NVARCHAR(50)='',
	@ClientId			INT
)
AS
BEGIN
	
	DECLARE @Result					NVARCHAR(MAX) = ''
	DECLARE @MemberId INT, @FullName NVARCHAR(200), @EmailAddress NVARCHAR(200),@MobilePhone NVARCHAR(15)	, @ContactDetailsTypeId int, @PersonalDetailsId int, @CreatedDate NVARCHAR(20)
	DECLARE  @ReferralCodeUsers TABLE (MemberId INT,FullName NVARCHAR(200),Email NVARCHAR(200),MobilePhone NVARCHAR(15),CreatedDate NVARCHAR(20))
	DECLARE  @RCUsersContactDetails TABLE (MemberId INT,Email NVARCHAR(200),MobilePhone NVARCHAR(15)) -- temporary  save

	SET @ReferralCode = REPLACE(LTRIM(RTRIM(@ReferralCode)),' ','')
	select @ContactDetailsTypeId = ContactDetailsTypeId from ContactDetailsType where clientId = @ClientId and [Name] = 'Main'	

	SELECT TOP 1 @MemberId = u.UserId,@PersonalDetailsId = u.PersonalDetailsId,@CreatedDate = CONVERT(VARCHAR(10), u.CreateDate, 101)
	FROM UserLoyaltyExtensionData ul
		inner join [User] u on u.UserLoyaltyDataId = ul.UserLoyaltyDataId
	WHERE ul.PropertyName = 'MyReferralCode' and ul.PropertyValue = @ReferralCode

	SELECT TOP 1  @FullName = FirstName + ' ' + LastName 
	FROM  PersonalDetails 
	WHERE PersonalDetailsId = @PersonalDetailsId

	SELECT TOP 1 @EmailAddress = cd.Email, @MobilePhone = isnull(cd.MobilePhone,'')
	FROM  UserContactDetails ucd
		inner join ContactDetails cd on cd.ContactDetailsId = ucd.ContactDetailsId and cd.ContactDetailsTypeId = @ContactDetailsTypeId
	WHERE ucd.UserId = @MemberId
	

	IF ISNULL(@MemberId,0) > 0
	BEGIN

		INSERT INTO @ReferralCodeUsers
		SELECT u.UserId, pd.FirstName + ' ' + pd.LastName, '', '', CONVERT(VARCHAR(10), u.CreateDate, 101)	
		FROM UserLoyaltyExtensionData ul
		inner join [User] u on u.UserLoyaltyDataId = ul.UserLoyaltyDataId
		inner join PersonalDetails pd on pd.PersonalDetailsId = u.PersonalDetailsId
		WHERE ul.PropertyName = 'ReferredByCode' and ul.PropertyValue = @ReferralCode
	
		IF EXISTS (SELECT 1 FROM @ReferralCodeUsers)
		BEGIN
			INSERT INTO @RCUsersContactDetails
			SELECT ucd.UserId, cd.Email,  isnull(cd.MobilePhone,'')
			FROM  UserContactDetails ucd
			inner join ContactDetails cd on cd.ContactDetailsId = ucd.ContactDetailsId and cd.ContactDetailsTypeId = @ContactDetailsTypeId
			WHERE ucd.UserId in ( SELECT DISTINCT MemberId FROM  @ReferralCodeUsers)

			UPDATE ru 
			SET ru.Email = rc.Email,
				ru.MobilePhone = rc.MobilePhone
			FROM @ReferralCodeUsers ru inner join @RCUsersContactDetails rc on ru.MemberId = rc.MemberId

		END

		SET @Result = 
		(
			SELECT	(
						SELECT  @MemberId as MemberId, @FullName as FullName, @EmailAddress as Email, @MobilePhone as Phone, @CreatedDate as CreatedDate
						FOR JSON PATH, INCLUDE_NULL_VALUES
					) as OwnedByList,
					(
						SELECT			MemberId, FullName, Email, MobilePhone as Phone,CreatedDate
						FROM			@ReferralCodeUsers
						FOR JSON PATH, INCLUDE_NULL_VALUES				
					) AS ReferralCodeUsers
				
			FOR JSON PATH, INCLUDE_NULL_VALUES
		)

		SELECT @Result AS Result
	END
	ELSE
	BEGIN
		SELECT 'notfound' AS Result
	END
END
