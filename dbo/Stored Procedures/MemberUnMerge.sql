
-- =============================================
-- Author:		Kamil Wozniak
-- Create date: 05/07/2017
-- Description:	Quick Unmerge
-- =============================================
CREATE PROCEDURE [dbo].[MemberUnMerge]
	(
		@MemberId int	
	)
AS
BEGIN
	SET NOCOUNT ON;

		DECLARE @AccountStatusId int;
		DECLARE @ClientId int;
		DECLARE @CurrencyId int;
		DECLARE @UserStatusId int;

		SELECT @ClientId = ClientId FROM dbo.Client c WHERE Name = 'baseline';
		SELECT @UserStatusId = us.UserStatusId FROM UserStatus us WHERE us.ClientId = @ClientId AND us.Name = 'Active';
		SELECT @AccountStatusId = [as].AccountStatusId from dbo.AccountStatus [as] WHERE [as].ClientId = @ClientId AND [as].Name = 'Enable';
		SELECT @CurrencyId = c.Id FROM dbo.Currency c WHERE c.ClientId = @ClientId AND c.Code = 'CHF';
	


		SELECT mmh.MergedDeviceId, mmh.MergedUserId, sum(td.Points) Points
		INTO #Unmerge
		FROM dbo.MemberMergeHistory mmh 
		JOIN dbo.TrxHeader th ON th.DeviceId = mmh.MergedDeviceId
		JOIN dbo.TrxDetail td ON th.TrxId = td.TrxID
		WHERE mmh.MergedUserId = @MemberId
		GROUP BY mmh.MergedDeviceId, mmh.MergedUserId

		SELECT u.* FROM #Unmerge u

		--DELETE FROM dbo.MemberMergeHistory where MergedUserId = 1448961;

		--INSERT INTO dbo.Account
		--( Version, UserId, ExtRef, AccountStatusTypeId, Pin, ProgramId, PointsPending, CreateDate, Version_old, MonetaryBalance, PointsBalance,CurrencyId,OLD_MemberID)
		--SELECT 0, u.MergedUserId, u.MergedDeviceId, @AccountStatusId, NULL, NULL, 0, getdate(), null, 0, u.Points, @CurrencyId, null
		--FROM #Unmerge u
		

		

		UPDATE a 
		SET a.AccountStatusTypeId = @AccountStatusId, a.PointsBalance = u.Points
		from Account a
		JOIN #Unmerge u ON u.MergedUserId = a.UserId

		UPDATE d
			SET d.UserId = u.MergedUserId, d.AccountId = a.AccountId
		from dbo.Device d 
			JOIN #Unmerge u ON u.MergedDeviceId = d.DeviceId
			JOIN dbo.Account a ON a.UserId = u.MergedUserId

		UPDATE usr
			SET usr.UserStatusId = @UserStatusId, usr.LastUpdatedDate = getdate()
		from dbo.[User] usr 
			JOIN #Unmerge u ON u.MergedUserId = usr.UserId

		DELETE FROM dbo.MemberLink WHERE MemberId2 = @MemberId;
		DELETE FROM MemberMergeHistory WHERE MergedUserId = @MemberId;
		
END

