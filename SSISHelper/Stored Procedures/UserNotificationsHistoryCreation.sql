CREATE PROCEDURE [SSISHelper].[UserNotificationsHistoryCreation] (@UserJson NVARCHAR(MAX))
AS
BEGIN
    --DECLARE @NotificationId INT
    --SELECT @NotificationId = NotificationId FROM Notifications WHERE NotificationName = 'System'

    CREATE TABLE #TempUserTable
    (
        RowNumber INT IDENTITY(1,1),
		JobId INT,
        UserId INT,
		NotificationTemplateId INT,
        Data NVARCHAR(MAX)
    )

    INSERT INTO #TempUserTable (UserId, NotificationTemplateId, Data)
    SELECT UserId, NotificationTemplateId, Data
    FROM OPENJSON(@UserJson)
    WITH (
		JobId INT '$.JobId',
        UserId INT '$.UserId',
		NotificationTemplateId INT '$.NotificationTemplateId',
        Data NVARCHAR(MAX) '$.Data'
    )

	--NotificationTemplate
	DECLARE @NotificationStatusId INT = 3
	--SELECT @NotificationStatusId = NotificationStatusId FROM NotificationStatus WHERE ClientId=@ClientId AND [Name]='Sent'

	UPDATE NotificationTemplate SET NotificationStatusId = @NotificationStatusId WHERE Id IN (SELECT DISTINCT NotificationTemplateId FROM #TempUserTable)
	--NotificationTemplate

    DECLARE @UserId INT, @JobId INT, @NotificationTemplateId INT, @Json NVARCHAR(MAX), @Index INT
    SET @Index = 1

    DECLARE @RowCount INT
    SELECT @RowCount = COUNT(*) FROM #TempUserTable

    WHILE @Index <= @RowCount
    BEGIN

        SELECT @UserId = UserId, @Json = [Data], @NotificationTemplateId = NotificationTemplateId, @JobId = JobId
        FROM #TempUserTable
        WHERE RowNumber = @Index


        INSERT INTO usernotificationhistory (UserNotificationId, UserId, ReadDateTime, PublishDateTime, SentDateTime, NotificationStatusId, NotificationTemplateId,ExtraInfo)
        VALUES (@JobId, @UserId, null, GETDATE(), GETDATE(), @NotificationStatusId, @NotificationTemplateId,@Json)

        SET @Index = @Index + 1
    END

    DROP TABLE #TempUserTable
END
