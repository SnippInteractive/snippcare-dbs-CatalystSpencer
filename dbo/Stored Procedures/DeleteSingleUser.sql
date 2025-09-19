
-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <05/07/2016>
-- Description:	<Deletes Single User>
-- =============================================
CREATE PROCEDURE [dbo].[DeleteSingleUser]
	(
		@MemberId int
	)
AS
BEGIN
	SET NOCOUNT ON;

		DECLARE @personalDetailsId int;
		DECLARE @userLoyaltyDataId int;
		DECLARE @contactDetailsId int;
		DECLARE @addressId int;
		DECLARE @deviceStatus int;
		DECLARE @accountStatus int;
		DECLARE @deviceId varchar(30);
		DECLARE @userSiteId int;
		DECLARE @trxTypeId int;
		DECLARE @trxStatusTypeId int;
		DECLARE @trxId int;
		DECLARE @points int;
		DECLARE @accountId int;
		DECLARE @ClientId int;
		
		select top 1 @ClientId = ClientId from Client where Name = 'baseline';
		select top 1 @personalDetailsId = PersonalDetailsId, @userLoyaltyDataId = UserLoyaltyDataId, @userSiteId = SiteId from [User] where UserId = @MemberId;
		select top 1 @contactDetailsId = ContactDetailsId from UserContactDetails where UserId = @MemberId;
		select top 1 @addressId = AddressId from [UserAddresses] where UserId = @MemberId;
		select top 1 @deviceStatus = DeviceStatusId from DeviceStatus where Name = 'Inactive' and ClientId = @ClientId;
		select top 1 @accountStatus = AccountStatusId from AccountStatus where Name = 'Disable' and ClientId = @ClientId;
		select top 1 @deviceId = DeviceId, @accountId = AccountId from Device where UserId = @MemberId and deviceid like 'TPC%';
		Select top 1 @trxTypeId = TrxTypeId from TrxType where ClientId = @ClientId and Name = 'PointsAdjustment';
		select top 1 @trxStatusTypeId = TrxStatusId from TrxStatus where Name = 'Completed';
		select top 1 @points = PointsBalance from Account where AccountId = @accountId;
		 

		print @addressId
		print @accountId
		print @deviceId
		
		update Address set LastUpdatedBy = NULL where LastUpdatedBy = @MemberId;
		update Address set LastUpdatedBy = NULL where AddressId = @addressId;
		update Address set ContactDetailsId = NULL where AddressId = @addressId;

		delete from audit where userid = @MemberId;
		delete from UserContactDetails  where UserId = @MemberId;
		delete from ContactDetails where ContactDetailsId = @contactDetailsId;
		
		delete from UserAddresses where UserId = @MemberId;
		delete from Address where AddressId = @addressId;
		delete from UserProfileExtraInfo where UserId = @MemberId;
		
		
		delete from MemberLink where MemberId1 = @MemberId;
		delete from MemberLink where MemberId2 = @MemberId;
		delete from community where userid = @MemberId;

		if NULLIF(@points, '')  is null
			SET @points = 0; 
			

		insert into TrxHeader (version, DeviceId, TrxTypeId, TrxDate, ClientId, SiteId, Reference, TrxStatusTypeId, CreateDate, CallContextId, AccountPointsBalance, LastUpdatedDate)
		values
		(0, @deviceId + '9', @trxTypeId, GETDATE(), @ClientId, @userSiteId, 'DB', @trxStatusTypeId, GETDATE(), NEWID(), -(@points), GETDATE())
		SELECT @trxId=SCOPE_IDENTITY();

		insert into TrxDetail (Version, TrxID, LineNumber, ItemCode, Description, Quantity, Value, Points, ConvertedNetValue)
		VALUES
		(0, @trxId, 1, NULL, 'Member deletion', 1, 0, -(@points), 0)

		
		UPDATE TrxHeader set DeviceId = @deviceId + '9' where DeviceId = @deviceId;
		UPDATE Device set UserId = NULL, DeviceStatusId = @deviceStatus, DeviceId =  DeviceId + '9' where UserId = @MemberId;
		UPDATE Account set UserId = NULL, AccountStatusTypeId = @accountStatus, PointsBalance = 0, MonetaryBalance = 0 where UserId = @MemberId;
		

		delete from dbo.CalculateLoyaltyOffer where CalculateLoyaltyInfoId in (select Id from CalculateLoyaltyInfo where MemberId = @MemberId);
		delete from CalculateLoyaltyInfo where MemberId = @MemberId;
		delete from ContactHistory where UserId = @MemberId;
		delete from [User] where UserId = @MemberId;
		delete from PersonalDetails where PersonalDetailsId = @personalDetailsId;
		delete from UserLoyaltyExtensionData where UserLoyaltyDataId = @userLoyaltyDataId;
		delete from UserLoyaltyData where UserLoyaltyDataId = @userLoyaltyDataId;
				

END
