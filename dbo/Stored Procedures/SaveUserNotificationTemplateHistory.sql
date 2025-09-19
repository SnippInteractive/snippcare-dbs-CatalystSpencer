-- =============================================
-- Modified by:	Binu Jacob Scaria
-- Date: 2025-06-01
-- Description:	SaveUserNotificationTemplateHistory
-- Modified Date: 2025-06-01
-- =============================================
CREATE PROCEDURE [dbo].[SaveUserNotificationTemplateHistory]
(
	@NotificationTemplateId	INT,
	@ClientId				INT
)
AS
BEGIN

DECLARE @NotificationStatus NVARCHAR(100),  
        @NotificationType NVARCHAR(100),  
        @NotificationStatusId INT,  
        @NotificationTypeId INT,
		@ExtraInfo NVARCHAR(max),
		@NotificationStatusIdSent INT
		--@CurrentDateTime DATETIME = GETDATE()

-- Retrieve Notification Template Details
SELECT @NotificationStatusId = nt.NotificationStatusId,  
       @NotificationTypeId = nt.NotificationTypeId,  
       @NotificationStatus = ns.Name,  
       @NotificationType = ntp.Name,
	   @ExtraInfo = nt.ExtraInfo
FROM NotificationTemplate nt  
INNER JOIN NotificationStatus ns ON nt.NotificationStatusId = ns.NotificationStatusId AND ns.ClientId = @ClientId  
INNER JOIN NotificationType ntp ON nt.NotificationTypeId = ntp.Id AND ntp.ClientId = @ClientId  
WHERE nt.Id = @NotificationTemplateId 

--marking it sent by default, as the actual notificaiton is happening directly from firebase - this is just to display in the app
--!!remove the variable once the push notifications started sending from Catalyst!!
--SELECT @NotificationStatusIdSent = NotificationStatusId FROM NotificationStatus WHERE ClientId=@ClientId AND [Name]='Sent'
SELECT @NotificationStatusIdSent = NotificationStatusId FROM NotificationStatus WHERE ClientId=@ClientId AND [Name]='Sent'

BEGIN TRY 
IF ISNULL(@NotificationTemplateId,0) > 0 AND @NotificationStatus = 'Publish'
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM UserNotificationHistory WHERE NotificationTemplateId = @NotificationTemplateId)
	BEGIN
		PRINT 'UserNotificationHistory'
		IF ISNULL(@NotificationType,'') = 'Campaign'
		BEGIN
			PRINT 'Campaign'
			--Task scheduler
			
		END
		ELSE
		BEGIN
			
			UPDATE NotificationTemplate SET NotificationStatusId = @NotificationStatusIdSent WHERE Id = @NotificationTemplateId 

			PRINT @NotificationType
			IF EXISTS (SELECT 1 FROM NotificationTemplateSegment where NotificationTemplateId = @NotificationTemplateId AND SegmentId = -1)
			BEGIN
				PRINT 'ALL SEGMENTS'
				INSERT INTO UserNotificationHistory(UserId,NotificationTemplateId,PublishDateTime,NotificationStatusId,SentDateTime,ExtraInfo)
				SELECT		u.UserId,@NotificationTemplateId,GETDATE() AS PublishDateTime,@NotificationStatusIdSent NotificationStatus,GETDATE() SentDateTime,@ExtraInfo
				FROM		[User] u
				INNER JOIN  UserStatus us ON u.UserStatusId = us.UserStatusId
				INNER JOIN  UserType ut ON u.UserTypeId = ut.UserTypeId
				WHERE		us.ClientId = @ClientId
				--AND			ut.ClientId = @ClientId
				AND			us.Name = 'Active'
				AND			ut.Name = 'LoyaltyMember'
			END
			ELSE
			BEGIN
				PRINT 'SELECTED SEGMENTS'
				INSERT INTO UserNotificationHistory(UserId,NotificationTemplateId,PublishDateTime,NotificationStatusId,SentDateTime,ExtraInfo)
				SELECT DISTINCT su.UserId,@NotificationTemplateId,GETDATE() AS PublishDateTime,@NotificationStatusIdSent NotificationStatus,GETDATE() SentDateTime,@ExtraInfo
				FROM NotificationTemplateSegment nts 
				INNER JOIN SegmentUsers su on nts.SegmentId = su.SegmentId
				where NotificationTemplateId = @NotificationTemplateId
			END
		END
	END
	ELSE
	BEGIN
		PRINT 'Already IN UserNotificationHistory'
	END
END
ELSE
BEGIN
	PRINT 'NA'
END

	SELECT '1' AS Result

END TRY
BEGIN CATCH
	SELECT '0' AS Result
END CATCH


/*
	DECLARE @NotificationStatus NVARCHAR(100) = ''

	SELECT @NotificationStatus = Name 
	FROM NotificationStatus 
	WHERE NotificationStatusId = @NotificationStatusId

	--marking it sent by default, as the actual notificaiton is happening directly from firebase - this is just to display in the app
	--!!remove the variable once the push notifications started sending from Catalyst!!
	SELECT @NotificationStatusId = NotificationStatusId FROM NotificationStatus WHERE ClientId=@ClientId AND [Name]='Sent'

	BEGIN TRY
		IF ISNULL(@NotificationId,0) > 0 AND ISNULL(@NotificationStatusId,0) > 0 AND @NotificationStatus = 'Publish'
		BEGIN
			INSERT INTO UserNotificationHistory(UserId,UserNotificationId,PublishDateTime,NotificationStatusId,SentDateTime)

			SELECT		su.UserId,un.UserNotificationId, GETDATE() AS PublishDateTime,@NotificationStatusId,GETDATE()
			FROM		UserNotifications un
			INNER JOIN	SegmentUsers su
			ON			un.UserSegmentId = su.SegmentId
			WHERE		un.NotificationId = @NotificationId 

			UNION ALL

			SELECT		u.UserId,unot.UserNotificationId,GETDATE() AS PublishDateTime,@NotificationStatusId,GETDATE()
			FROM
			(
				SELECT		DISTINCT un.UserNotificationId 
				FROM		UserNotifications un
				WHERE		un.NotificationId = @NotificationId
				AND			un.UserSegmentId = -1
			) unot

			CROSS JOIN
			(
				SELECT		u.UserId
				FROM		[User] u
				INNER JOIN  UserStatus us
				ON			u.UserStatusId = us.UserStatusId
				INNER JOIN  UserType ut
				ON			u.UserTypeId = ut.UserTypeId
				WHERE		us.ClientId = @ClientId
				AND			ut.ClientId = @ClientId
				AND			us.Name = 'Active'
				AND			ut.Name = 'LoyaltyMember'

			)u

		END
		SELECT '1' AS Result
	END TRY
	BEGIN CATCH
		SELECT '0' AS Result
	END CATCH
	*/
END
