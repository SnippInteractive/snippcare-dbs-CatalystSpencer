
CREATE PROCEDURE [dbo].[API_UpdatePushNotificationStatus]
(
	@NotificationDetails		NVARCHAR(MAX) = '',
	@ClientId					INT = NULL,
	@Result						NVARCHAR(100) OUTPUT
)
AS
BEGIN
	IF LEN(ISNULL(@NotificationDetails,'')) = 0 OR ISJSON(@NotificationDetails) < 1
	BEGIN
		SET @Result = 'InvalidNotificationDetails' 
		RETURN
	END

	IF @ClientId IS NULL
	BEGIN
		SET @Result = 'InvalidClient' 
		RETURN
	END

	BEGIN TRY
		
		DROP TABLE IF EXISTS #tempUserNotifications

		CREATE  TABLE #tempUserNotifications(UserId INT, UserNotificationId INT)
		CREATE NONCLUSTERED INDEX IX_tempUserNotifications_UserId ON #tempUserNotifications(UserId)
		INCLUDE(UserNotificationId)

		DECLARE @PublishNotificationStatusId INT = 0,@SentNotificationStatusId INT = 0

		SELECT	@PublishNotificationStatusId = NotificationStatusId 
		FROM	NotificationStatus 
		WHERE	ClientId = @ClientId 
		AND		Name = 'publish'

		SELECT	@SentNotificationStatusId = NotificationStatusId 
		FROM	NotificationStatus 
		WHERE	ClientId = @ClientId 
		AND		Name = 'Sent'


		INSERT INTO #tempUserNotifications(UserId,UserNotificationId)
		SELECT  UserId,UserNotificationId
		FROM	OPENJSON(JSON_QUERY(@NotificationDetails)) 
		WITH
		(
				UserId				INT,
				UserNotificationId	INT
		)


		UPDATE		unHistory
		SET         unHistory.NotificationStatusId = @SentNotificationStatusId,
					unHistory.SentDateTime = GETDATE()
		FROM		UserNotificationHistory unHistory
		INNER JOIN	#tempUserNotifications t
		ON			unHistory.UserNotificationId = t.UserNotificationId
		WHERE		unHistory.UserId = t.UserId
		AND			unHistory.NotificationStatusId = @PublishNotificationStatusId


		UPDATE		un
		SET			un.NotificationStatusId = @SentNotificationStatusId
		FROM		UserNotifications un
		INNER JOIN	(SELECT DISTINCT UserNotificationId FROM #tempUserNotifications) t
		ON			un.UserNotificationId = t.UserNotificationId

		SET @Result = '1' 

	END TRY
	BEGIN CATCH
		SET @Result = '0'
	END CATCH

END
