-- =============================================
-- Author:		Wei Liu
-- Create date: 2020-07-08
-- Description:	Use by membercheck to assign v-device for multi-channel receipt upload
-- Note: @Username coming from membercheck can either be email or phone
-- =============================================
CREATE PROCEDURE [dbo].[AssignVirtualDeviceToUnRegisterUser] (@Username nvarchar(80), @Email nvarchar(80) = null,@EmailAlias nvarchar(80)= null, @Phone nvarchar(50) = null)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @clientId int, @DeviceID nvarchar(50), @VirtualDeviceID nvarchar(50), @profileType nvarchar(50), @IsVirtual bit, @UserId int
	SET @clientId = 1
	SET @profileType = 'Loyalty'
	SET @IsVirtual = 1

	-- Check any user exists with the username/email/phone 
	  SELECT u.UserId, pd.Firstname, pd.Lastname FROM [dbo].[User] u
                  INNER JOIN [dbo].[UserContactDetails] ucd ON u.UserId = ucd.UserId INNER JOIN [dbo].[ContactDetails] cd ON ucd.ContactDetailsId = cd.ContactDetailsId
                  INNER JOIN [dbo].[PersonalDetails] pd ON u.PersonalDetailsId = pd.PersonalDetailsId
                  LEFT OUTER JOIN (SELECT UA.UserId,MobilePrefix FROM UserAddresses UA INNER JOIN [Address] A  ON A.AddressId = UA.AddressId INNER JOIN Country C ON C.CountryId = A.CountryId) UA
                  ON  UA.UserId = U.UserId
                  WHERE cd.Email = @Email OR cd.Phone = @Phone or u.Username = @Email or (UA.MobilePrefix+cd.MobilePhone) = @Phone collate Latin1_General_CI_AS
	-- No user found with the username/email/phone 
	IF @UserId is null
	BEGIN
		-- Check if the username/email/phone has virtual device 
		select @DeviceID = DeviceId from Device where ExtraInfo = @Username
		-- No virtual device found
		IF @DeviceID is null
		BEGIN
			-- Get next available virtual device
			EXEC [dbo].[GetNextAvailableDevice]  @clientId, @profileType, @VirtualDeviceID output, @IsVirtual

			IF @VirtualDeviceID is not null
			BEGIN
				-- Assign the virtual device to the username
				Update Device set ExtraInfo = @Username where DeviceId = @VirtualDeviceID
				-- Audit assigned device
				EXEC Insert_Audit 'I', 140006, 1, 'Device', 'ExtraInfo',@VirtualDeviceID, @Username
			END
			ELSE
			BEGIN
				-- Audit error for no available device assigned 
				EXEC Insert_Audit 'I', 140006, 1, 'Device', 'ExtraInfo','Error, no availabe device to assign', @Username
			END
		END
	END
   
END
