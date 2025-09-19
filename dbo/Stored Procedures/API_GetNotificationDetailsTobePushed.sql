CREATE PROCEDURE [dbo].[API_GetNotificationDetailsTobePushed]
(
	@ClientId		INT,
	@Page			INT = 0,
	@PageSize		INT = 100,
	@ScheduleType	NVARCHAR(100) = '' -- NOW/Scheduled
)
AS
BEGIN
	-------------------------------------------------------------------------------
	-- Clearing Temp table(s)
	-------------------------------------------------------------------------------
	DROP TABLE IF EXISTS #NotificationsDetails
	-------------------------------------------------------------------------------
	-- Creating Temp Table(s)
	-------------------------------------------------------------------------------
 
	CREATE TABLE #NotificationsDetails
	(
		Id						INT IDENTITY(1,1),
		UserId					INT,
		SegmentId				INT,
		NotificationId			INT,
		UserNotificationId		INT,
		NotificationName		NVARCHAR(250),
		[Subject]				NVARCHAR(500),
		Content					NVARCHAR(MAX),
		[Description]			NVARCHAR(500),
		ScheduledDate			NVARCHAR(100),
		TimeZone				NVARCHAR(250),
		ImageUrl				NVARCHAR(500),
		DeviceToken				NVARCHAR(MAX),
		TotalCount				INT
	)
 
	CREATE	NONCLUSTERED INDEX IDX_T_NotificationDetails_UserId 
	ON		#NotificationsDetails(UserId)
	INCLUDE	
	(
			NotificationId,
			UserNotificationId,
			SegmentId,
			NotificationName,
			ScheduledDate,
			TimeZone,
			ImageUrl,
			DeviceToken,
			TotalCount
	)
 
	------------------------------------------------------------------------------------
	-- Fetching the Publish NotificationStatusId to get data in publish status
	------------------------------------------------------------------------------------
 
	DECLARE @PublishNotificationStatusId INT = 0,@SentNotificationStatusId INT = 0
	SELECT	@PublishNotificationStatusId = NotificationStatusId 
	FROM	NotificationStatus 
	WHERE	ClientId = @ClientId 
	AND		Name = 'publish'
 
	SELECT	@SentNotificationStatusId = NotificationStatusId 
	FROM	NotificationStatus 
	WHERE	ClientId = @ClientId 
	AND		Name = 'Sent'
 
	DECLARE @Offset INT = (CASE WHEN @Page = 0 THEN 0 ELSE  @Page END)*@PageSize
	DECLARE @TotalCount INT =0
 
 
	------------------------------------------------------------------------------------
	-- Fetching the Count of records based on the search criteria
	------------------------------------------------------------------------------------
	SELECT @TotalCount = COUNT(1)		
	FROM		UserNotifications un
	INNER JOIN	Notifications n
	ON			un.NotificationId = n.NotificationId
	INNER JOIN  UserNotificationHistory users
	ON			users.UserNotificationId = un.UserNotificationId
	WHERE		users.NotificationStatusId = @PublishNotificationStatusId
	AND			((LEN(@ScheduleType) > 0 AND JSON_VALUE(n.ExtraInfo,'$.NotificationScheduleType') = @ScheduleType) OR @ScheduleType = '')
 
 
	------------------------------------------------------------------------------------
	-- Inserting the selected records upto 500 to the temp table
	------------------------------------------------------------------------------------
 
	INSERT INTO #NotificationsDetails(UserId,SegmentId,NotificationId,UserNotificationId)
 
	SELECT		DISTINCT users.UserId AS UserId,un.UserSegmentId AS SegmentId,n.NotificationId,un.UserNotificationId				
	FROM		UserNotifications un
	INNER JOIN	Notifications n
	ON			un.NotificationId = n.NotificationId
	INNER JOIN  UserNotificationHistory users
	ON			users.UserNotificationId = un.UserNotificationId
	WHERE		users.NotificationStatusId = @PublishNotificationStatusId 
	AND			((LEN(@ScheduleType) > 0 AND JSON_VALUE(n.ExtraInfo,'$.NotificationScheduleType') = @ScheduleType) OR @ScheduleType = '')
 
 
	ORDER BY	UserId
 
	OFFSET		@Offset ROWS
	FETCH		NEXT @PageSize ROWS ONLY
 
 
	---------------------------------------------------------------------------------------
	-- Updating the NotificationDetails from Notification table.
	---------------------------------------------------------------------------------------
 
	UPDATE		temp
	SET         temp.NotificationName = n.NotificationName,
				temp.Subject = n.Subject,
				temp.Description = n.Description,
				temp.Content = n.Content,
				temp.ImageUrl = n.ImageUrl,
				temp.ScheduledDate = CASE ISJSON(ISNULL(n.ExtraInfo,'')) 
										WHEN 1 
										THEN CASE JSON_VALUE(n.ExtraInfo,'$.NotificationScheduleType') 
														WHEN 'Now' 
														THEN 'Now'
														WHEN 'Scheduled' 
														THEN CONVERT(VARCHAR,TRY_CAST(JSON_VALUE(JSON_QUERY(n.ExtraInfo,'$.Schedule'),'$.ScheduledDate')AS DATETIME),126)
														ELSE NULL
											 END
										 ELSE  NULL
									  END ,
				temp.TimeZone =       CASE ISJSON(ISNULL(n.ExtraInfo,'')) 
											WHEN 1 
											THEN	CASE JSON_VALUE(n.ExtraInfo,'$.NotificationScheduleType') 
														WHEN 'Now' 
														THEN NULL
														WHEN 'Scheduled' 
														THEN JSON_VALUE(JSON_QUERY(n.ExtraInfo,'$.Schedule'),'$.TimeZone')
														ELSE NULL
													END
											ELSE  NULL
										END,
				temp.TotalCount = @TotalCount
 
	FROM		#NotificationsDetails temp
	INNER JOIN  Notifications n
	ON			temp.NotificationId = n.NotificationId
 
 
	---------------------------------------------------------------------------------------
	-- Fetching the DeviceToken from Extension table.
	---------------------------------------------------------------------------------------
 
	UPDATE      temp
	SET         temp.DeviceToken =	CASE  
										WHEN uled.PropertyValue IS NULL 
										THEN NULL 
										WHEN ISJSON(uled.PropertyValue) < 1 
										THEN NULL
										ELSE 
										JSON_QUERY((
											SELECT DeviceToken 
											FROM OPENJSON(JSON_QUERY(uled.PropertyValue)) 
											WITH(DeviceToken NVARCHAR(MAX),DeviceAvailable NVARCHAR(10))
											WHERE DeviceAvailable = 'true' 
											AND	DeviceToken IS NOT NULL
											FOR JSON PATH
										))
									END
	FROM		#NotificationsDetails temp
	INNER JOIN  [User] u
	ON			temp.UserId = u.UserId
	INNER JOIN  UserLoyaltyExtensionData uled
	ON			u.UserLoyaltyDataId = uled.UserLoyaltyDataId
	WHERE       uled.PropertyName = 'FCMDeviceTokens' 
	-----------------------------------------------------------------------------------------
	-- Fetching the results
	-----------------------------------------------------------------------------------------
 
	---------------------------------------------------------------------------------
	UPDATE		unHistory
	SET         unHistory.NotificationStatusId = @SentNotificationStatusId,
				unHistory.SentDateTime = GETDATE()
	FROM		UserNotificationHistory unHistory
	INNER JOIN	#NotificationsDetails t
	ON			unHistory.UserNotificationId = t.UserNotificationId
	WHERE		unHistory.UserId = t.UserId
	AND			unHistory.NotificationStatusId = @PublishNotificationStatusId
 
 
	UPDATE		un
	SET			un.NotificationStatusId = @SentNotificationStatusId
	FROM		UserNotifications un
	INNER JOIN	(SELECT DISTINCT UserNotificationId FROM #NotificationsDetails) t
	ON			un.UserNotificationId = t.UserNotificationId
	-----------------------------------------------------------
 
	SELECT * FROM #NotificationsDetails
END