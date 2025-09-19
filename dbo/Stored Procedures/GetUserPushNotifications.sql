
-- =============================================
-- Author:		Abdul Wahab
-- Create date: 2024-09-25
-- Description:	Get user push notifications
-- =============================================
/****
DECLARE @OutputJSON NVARCHAR(MAX)
EXEC GetUserPushNotifications '{
  "UserId": 1966892,
  "ClientId": 1,
  "PageNumber": 2,
  "PageSize": 50,
  "NotificationStatus" : "all",
  "DeviceDateTime" : "2024-11-23T13:44:00"
}',@OutputJSON OUTPUT
SELECT @OutputJSON
*/

CREATE PROCEDURE [dbo].[GetUserPushNotifications]
    @InputJSON NVARCHAR(MAX),
    @OutputJSON NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare local variables
    DECLARE @ScheduleDate DATETIME,
            @UserId INT,
            @ClientId INT,
            @PageNumber INT = 1,
            @RowsPerPage INT = 100,
            @NotificationTemplateTypeId INT,
            @NotificationStatusReadId INT,
            @NotificationStatusSentId INT,
            @NotificationStatusDeletedId INT,
			@NotificationStatus NVARCHAR(50),
            @TotalRecords INT;

    -- Parse JSON input into variables
    SELECT 
        @UserId = JSON_VALUE(@InputJSON, '$.UserId'),
        @ClientId = JSON_VALUE(@InputJSON, '$.ClientId'),
		@NotificationStatus = ISNULL(JSON_VALUE(@InputJSON, '$.NotificationStatus'), 'all'),
        @ScheduleDate = JSON_VALUE(@InputJSON, '$.DeviceDatetime'),
        @PageNumber = ISNULL(JSON_VALUE(@InputJSON, '$.PageIndex'), 1),
        @RowsPerPage = ISNULL(JSON_VALUE(@InputJSON, '$.PageSize'), 20);
		print @NotificationStatus
    -- Get NotificationTemplateTypeId
    SET @NotificationTemplateTypeId = (
        SELECT Id 
        FROM NotificationTemplateType 
        WHERE [Name] = 'Push' 
          AND ClientId = @ClientId
    );

    -- Get NotificationStatusIds for Read, Sent, and Deleted
    SET @NotificationStatusReadId = (
        SELECT NotificationStatusId 
        FROM NotificationStatus 
        WHERE [Name] = 'Read' 
          AND ClientId = @ClientId
    );
    SET @NotificationStatusSentId = (
        SELECT NotificationStatusId 
        FROM NotificationStatus 
        WHERE [Name] = 'Sent' 
          AND ClientId = @ClientId
    );
    SET @NotificationStatusDeletedId = (
        SELECT NotificationStatusId 
        FROM NotificationStatus 
        WHERE [Name] = 'Deleted' 
          AND ClientId = @ClientId
    );
	
    -- Calculate TotalRecords (before applying pagination)
    SELECT @TotalRecords = COUNT(*)
    FROM UserNotificationHistory UNH
    INNER JOIN NotificationTemplate NT ON UNH.NotificationTemplateId = NT.Id
    OUTER APPLY 
        OPENJSON(UNH.ExtraInfo, '$.Schedule')
        WITH (
            SendNotificationNow BIT '$.SendNotificationNow',
            ScheduledDate DATETIME '$.ScheduledDate',
            TimeZone NVARCHAR(50) '$.TimeZone'
        ) AS schedule
    WHERE 
        (JSON_VALUE(UNH.ExtraInfo,'$.Schedule') IS NULL OR schedule.SendNotificationNow = 1 OR schedule.ScheduledDate <= @ScheduleDate)
        AND NT.NotificationTemplateTypeId = @NotificationTemplateTypeId
        AND UNH.UserId = @UserId
        AND (
            @NotificationStatus= 'all' OR
            (@NotificationStatus = 'unread' AND UNH.NotificationStatusId = @NotificationStatusSentId) OR
            (@NotificationStatus = 'read' AND UNH.NotificationStatusId = @NotificationStatusReadId))
        AND UNH.NotificationStatusId <> @NotificationStatusDeletedId;

    -- Use Common Table Expression (CTE) for pagination
    WITH PaginatedResults AS (
        SELECT 
            UNH.UserNotificationHistoryId,
            JSON_VALUE(NT.Placeholders, '$.Subject') AS [Subject],
            JSON_VALUE(NT.Placeholders, '$.Body') AS [Body],
            UNH.UserId,
            ISNULL(schedule.SendNotificationNow, 0) AS SendNotificationNow,
             CASE
			WHEN schedule.ScheduledDate IS NULL OR schedule.ScheduledDate = '1900-01-01 00:00:00.000' 
			 THEN UNH.SentDateTime
			 ELSE schedule.ScheduledDate
			  END AS ScheduledDate,
            ISNULL(schedule.TimeZone, 'UTC') AS TimeZone,
            UNH.SentDateTime,
            CASE 
                WHEN UNH.NotificationStatusId = @NotificationStatusReadId 
                THEN 1 ELSE 0 
            END AS IsRead,
            ROW_NUMBER() OVER (ORDER BY UNH.SentDateTime DESC) AS RowNumber
        FROM 
            UserNotificationHistory UNH
        INNER JOIN 
            NotificationTemplate NT ON UNH.NotificationTemplateId = NT.Id
        OUTER APPLY 
            OPENJSON(UNH.ExtraInfo, '$.Schedule')
            WITH (
                SendNotificationNow BIT '$.SendNotificationNow',
                ScheduledDate DATETIME '$.ScheduledDate',
                TimeZone NVARCHAR(50) '$.TimeZone'
            ) AS schedule
        WHERE 
            ( ISJSON(UNH.ExtraInfo)=0 OR ISJSON(UNH.ExtraInfo) IS NULL OR schedule.SendNotificationNow = 1 OR schedule.ScheduledDate <= @ScheduleDate)
            AND NT.NotificationTemplateTypeId = @NotificationTemplateTypeId
            AND UNH.UserId = @UserId
            AND UNH.NotificationStatusId IN (@NotificationStatusReadId, @NotificationStatusSentId)
            AND UNH.NotificationStatusId <> @NotificationStatusDeletedId
			AND (
            @NotificationStatus= 'all' OR
            (@NotificationStatus = 'unread' AND UNH.NotificationStatusId = @NotificationStatusSentId) OR
            (@NotificationStatus = 'read' AND UNH.NotificationStatusId = @NotificationStatusReadId)
        )
    )

    -- Select paginated results
    SELECT 
        pr.UserNotificationHistoryId AS Id,
		pr.UserNotificationHistoryId as UserNotificationId,
        pr.Subject,
        pr.Body AS Content,
        pr.Body AS Description,
        pr.UserId,
        pr.IsRead,
        -- Construct JSON for SendNotificationNow, ScheduledDate, TimeZone and assign it to ExtraInfo
        (
            CASE
                WHEN pr.SendNotificationNow = 1 
                THEN JSON_QUERY('{"NotificationScheduleType":"Now","Schedule":{"SendNotificationNow":true,"ScheduledDate":null,"TimeZone":null}}')
                ELSE JSON_QUERY(
                    '{"NotificationScheduleType":"Scheduled","Schedule":{"SendNotificationNow":false,"ScheduledDate":"' + 
                    FORMAT(pr.ScheduledDate, 'MM/dd/yyyy HH:mm') + 
                    '","TimeZone":"' + pr.TimeZone + '"}}'
                )
            END
        ) AS ExtraInfo,
		(
            CASE
                WHEN pr.SendNotificationNow = 1 
                THEN pr.SentDateTime
                ELSE CONVERT(NVARCHAR(20), pr.ScheduledDate, 120)
            END
        ) AS SentDateTime
    INTO #PaginatedResults
    FROM PaginatedResults pr
    WHERE pr.RowNumber BETWEEN ((@PageNumber - 1) * @RowsPerPage + 1) AND (@PageNumber * @RowsPerPage)
    ORDER BY pr.SentDateTime;

    -- Prepare JSON output
    SELECT @OutputJSON = (
        SELECT            
            @TotalRecords AS TotalRecords,
            (SELECT * FROM #PaginatedResults order by SentDateTime DESC FOR JSON PATH) AS Notifications
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    -- Drop temporary table
    DROP TABLE #PaginatedResults;
END
