CREATE PROCEDURE [dbo].[Campaigning_PlaceholderDataMapping] 
AS
BEGIN
    DECLARE @UserId INT, @NotificationTemplateId NVARCHAR(255) = '', @Placeholders NVARCHAR(MAX);
    DECLARE @PropertyKey NVARCHAR(255);
    DECLARE @TableName NVARCHAR(255), @SQLQuery NVARCHAR(MAX);
    DECLARE @Sql NVARCHAR(MAX), @Result NVARCHAR(MAX);
    DECLARE @PlaceholderValues NVARCHAR(MAX);
    DECLARE @Source NVARCHAR(MAX);
    DECLARE @NodeId INT = 0, @ActionId INT = 0, @CurrentId INT, @MaxId INT, @CommunicationJobId INT = 0, @CampaignJobId INT = 0;
    DECLARE @ScheduleConfig NVARCHAR(MAX), @TemplateType NVARCHAR(200);  -- New variable to store NodeId
	DECLARE @PlaceholderList TABLE (Placeholder NVARCHAR(MAX));
	DECLARE @CurrentPlaceholder NVARCHAR(MAX);
	DECLARE @Start INT, @End INT, @Placeholder NVARCHAR(MAX);
    DECLARE @TempResults TABLE (
        Id INT IDENTITY(1,1),
        UserId INT,
        NotificationTemplateId INT,
        [Source] NVARCHAR(MAX),
        ScheduleConfig NVARCHAR(MAX),
        NodeId INT
    );

    SELECT @CampaignJobId = JobId, @ScheduleConfig = [Configs] 
    FROM [CatalystMail_CampaignJobHeader] 
    WHERE [Status] = 5 AND ProcessedDate IS NULL;

    IF @CampaignJobId != 0
    BEGIN
        -- Declare cursor to iterate over NodeId and ActionId pairs
        DECLARE NodeActionCursor CURSOR FOR
        SELECT NodeId, ActionId  
        FROM CatalystMail_CampaignJobdetails 
        WHERE ActionType IN ('Email', 'SMS', 'Push') AND JobId = @CampaignJobId;

        -- Variables to hold the current NodeId and ActionId
        DECLARE @CurrentNodeId INT, @CurrentActionId INT;

        -- Open the cursor
        OPEN NodeActionCursor;

        -- Fetch the first row
        FETCH NEXT FROM NodeActionCursor INTO @CurrentNodeId, @CurrentActionId;

        -- Loop through each row
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Set the current NodeId and ActionId
            SET @NodeId = @CurrentNodeId;
            SET @ActionId = @CurrentActionId;
			print 'xxxxxxxxxxxxxxx'
			--Get Notification template Id 
			SELECT @NotificationTemplateId = JSON_VALUE(CAST(cmf.NamedValuesJSON AS NVARCHAR(MAX)), '$.Value') 
			FROM CatalystMail_Action cma 
			JOIN CatalystMail_ActionsFields cmaf ON cma.Id = cmaf.ActionId
			JOIN CatalystMail_Field cmf ON cmaf.FilterId = cmf.Id
			WHERE cma.id = @ActionId;

            -- Check if NodeId is not zero
            IF @NodeId != 0 and @ActionId != 0
            BEGIN
                DECLARE @BatchSize INT = 10000;
                DECLARE @RowCount INT;
                DECLARE @NewCommunicationJobId INT = 0;

                -- Insert into CommunicationJobStatus table if NodeId is not already processed
                IF NOT EXISTS (SELECT 1 FROM dbo.CommunicationJobStatus WHERE NodeId = @NodeId AND ActionId = @ActionId)
                BEGIN
                    EXEC dbo.[InsertCommunicationJobStatusSynonym]
                        @CampaignJobId = @CampaignJobId,
                        @NodeId = @NodeId,
						@ActionId = @ActionId,
                        @ScheduleConfig = @ScheduleConfig,
                        @NotificationTemplateId = @NotificationTemplateId,
                        @NewCommunicationJobId = @NewCommunicationJobId OUTPUT;
                END
                ELSE
                BEGIN
                    SELECT @NewCommunicationJobId = Id, @ScheduleConfig = ScheduleConfig, @NotificationTemplateId = NotificationTemplateId 
                    FROM dbo.CommunicationJobStatus 
                    WHERE NodeId = @NodeId AND ActionId = @ActionId;
                END

                -- Check if the data is already inserted by Job status Id
                IF NOT EXISTS (SELECT 1 FROM dbo.CommunicationToSend WHERE JobStatusId = @NewCommunicationJobId) AND @NewCommunicationJobId != 0
                BEGIN
                    -- Avoid duplicates
                    INSERT INTO CommunicationToSend (JobStatusId, UserId)
                    SELECT @NewCommunicationJobId, MemberId
                    FROM (
                        SELECT DISTINCT MemberId
                        FROM CatalystMail_SelMembersTemp
                        WHERE NodeId = @NodeId
                    ) AS DistinctMembers
                    WHERE NOT EXISTS (
                        SELECT 1 FROM CommunicationToSend 
                        WHERE JobStatusId = @NewCommunicationJobId 
                        AND UserId = DistinctMembers.MemberId
                    );
                END
               
            END
            
            -- Fetch the next row from the cursor
            FETCH NEXT FROM NodeActionCursor INTO @CurrentNodeId, @CurrentActionId;
        END

        -- Close and deallocate the cursor
        CLOSE NodeActionCursor;
        DEALLOCATE NodeActionCursor;

    END

	-- Next to check for Queued job
    IF EXISTS (SELECT 1 FROM dbo.CommunicationJobStatus WHERE [Status] = 'Queued')
		BEGIN
            SELECT TOP 1 @CommunicationJobId = Id, @ScheduleConfig = ScheduleConfig, @NotificationTemplateId = NotificationTemplateId, @NodeId = NodeId 
            FROM dbo.CommunicationJobStatus 
            WHERE [Status] = 'Queued' 
            ORDER BY Id ASC;
                    
            IF @CommunicationJobId != 0 AND ( @NotificationTemplateId != '' )
            BEGIN
                INSERT INTO @TempResults (UserId, [Source], NodeId)
                SELECT 
                    CTS.UserId, 
                    CTS.[Source],
                    @NodeId
                FROM 
                    dbo.CommunicationToSend CTS
                WHERE 
                    CTS.SentDate IS NULL;
                        
                -- Loop through each user (Its running in the background so timing is not an issue)
                DECLARE TempResultsCursor CURSOR FOR
                SELECT 
                    t.UserId,
                    [Source] = CASE 
                                WHEN ntt.[Name] COLLATE SQL_Latin1_General_CP1_CI_AS = 'Push' THEN uled.PropertyValue COLLATE SQL_Latin1_General_CP1_CI_AS
                                WHEN ntt.[Name] COLLATE SQL_Latin1_General_CP1_CI_AS = 'SMS' THEN 
                                    CASE 
                                        WHEN cd.Phone IS NULL OR cd.Phone = '' THEN cd.MobilePhone 
                                        ELSE cd.Phone 
                                    END COLLATE SQL_Latin1_General_CP1_CI_AS
                                WHEN ntt.[Name] COLLATE SQL_Latin1_General_CP1_CI_AS = 'Email' THEN cd.Email COLLATE SQL_Latin1_General_CP1_CI_AS
                            END,
                    t.NodeId
                FROM @TempResults t
                LEFT JOIN [User] u ON u.UserId = t.UserId
                JOIN NotificationTemplate nt ON nt.Id = @NotificationTemplateId
                JOIN NotificationTemplateType ntt ON ntt.id = nt.NotificationTemplateTypeId
                LEFT JOIN UserContactDetails ucd ON ucd.UserId = u.UserId
                LEFT JOIN ContactDetails cd ON cd.ContactDetailsId = ucd.ContactDetailsId
                LEFT JOIN UserLoyaltyExtensionData uled ON u.UserLoyaltyDataId = uled.UserLoyaltyDataId AND uled.PropertyName = 'FCMDeviceTokens';

                OPEN TempResultsCursor;

                FETCH NEXT FROM TempResultsCursor INTO @UserId, @Source, @NodeId;

                -- Note: This is for placeholder mapping for each user, not for the user to be returned to the taskscheduler job
                WHILE @@FETCH_STATUS = 0
                BEGIN
				print @Source
                    -- Placeholder mapping logic for each user
                    SELECT @TemplateType = ntt.[Name] 
                    FROM NotificationTemplate nt
                    JOIN NotificationTemplateType ntt ON ntt.id = nt.NotificationTemplateTypeId
                    WHERE nt.Id = @NotificationTemplateId;

                    SELECT @Placeholders = Placeholders
                    FROM NotificationTemplate
                    WHERE Id = @NotificationTemplateId;

                    SET @PlaceholderValues = '{}';

                    IF @TemplateType = 'Email'
                    BEGIN
                        -- Clear PlaceholderList table for each user
                        DELETE FROM @PlaceholderList;

                        INSERT INTO @PlaceholderList (Placeholder)
                        SELECT value FROM OPENJSON(@Placeholders, '$.Placeholder');

                        SET @CurrentPlaceholder = '';

                        DECLARE PlaceholderCursor CURSOR FOR
                        SELECT Placeholder FROM @PlaceholderList;

                        OPEN PlaceholderCursor;
                        FETCH NEXT FROM PlaceholderCursor INTO @CurrentPlaceholder;

                        -- using dynamic query to map placeholder value
                        WHILE @@FETCH_STATUS = 0
                        BEGIN
                            SET @CurrentPlaceholder = REPLACE(@CurrentPlaceholder, ' ', '');
                            SET @PropertyKey = NULL;
                            SET @TableName = NULL;
                            SET @SQLQuery = NULL;

                            SELECT TOP 1 
                                @PropertyKey = propertykey, 
                                @TableName = TableName,
                                @SQLQuery = SQLQuery
                            FROM CommunicationPlaceholderMapping
                            WHERE EXISTS (
                                SELECT 1 
                                FROM OPENJSON(propertyvalue) 
                                WHERE LOWER(value) = LOWER(@CurrentPlaceholder)
                            );

                            IF @PropertyKey IS NOT NULL AND @TableName IS NOT NULL
                            BEGIN
                                IF @SQLQuery IS NULL
                                BEGIN
                                    SET @Sql = N'SELECT @Result = ' + CONVERT(NVARCHAR(MAX), @PropertyKey) +
                                                ' FROM ' + CONVERT(NVARCHAR(MAX), @TableName) +
                                                ' WHERE UserId = @UserId';
                                END
                                ELSE
                                BEGIN
                                    SET @Sql = @SQLQuery;
                                END

                                PRINT 'For: ' + @CurrentPlaceholder;
                                PRINT @Sql;

                                EXEC sp_executesql @Sql, N'@UserId INT, @Result NVARCHAR(MAX) OUTPUT', @UserId = @UserId, @Result = @Result OUTPUT;

                                IF @Result IS NOT NULL
                                BEGIN
                                    SET @PlaceholderValues = JSON_MODIFY(@PlaceholderValues, '$.' + @PropertyKey, @Result);
                                    PRINT 'Updated PlaceholderValues: ' + @PlaceholderValues;
                                END
                            END

                            FETCH NEXT FROM PlaceholderCursor INTO @CurrentPlaceholder;
                        END

                        CLOSE PlaceholderCursor;
                        DEALLOCATE PlaceholderCursor;
                    END
                    ELSE IF @TemplateType = 'SMS'
                    BEGIN

                       	DECLARE @Content NVARCHAR(MAX);
						SET @Content = JSON_VALUE(@Placeholders, '$.Content');

						DELETE FROM @PlaceholderList;

						SET @Start = CHARINDEX('##', @Content);
						WHILE @Start > 0
						BEGIN
							SET @End = CHARINDEX('##', @Content, @Start + 2);
							IF @End > 0
							BEGIN
								SET @Placeholder = SUBSTRING(@Content, @Start + 2, @End - @Start - 2);
								PRINT 'Extracted Placeholder: ' + @Placeholder;

								INSERT INTO @PlaceholderList (Placeholder)
								VALUES (TRIM(@Placeholder));

								SET @Start = CHARINDEX('##', @Content, @End + 2);
							END
							ELSE
							BEGIN
								SET @Start = 0; -- End the loop if no closing ## is found
							END
						END

						SET @CurrentPlaceholder = '';

						DECLARE PlaceholderCursorSMS CURSOR FOR
						SELECT Placeholder FROM @PlaceholderList;

						OPEN PlaceholderCursorSMS;
						FETCH NEXT FROM PlaceholderCursorSMS INTO @CurrentPlaceholder;

						-- Using dynamic query to map placeholder values
						WHILE @@FETCH_STATUS = 0
						BEGIN
	
							SET @CurrentPlaceholder = REPLACE(@CurrentPlaceholder, ' ', '');
							SET @PropertyKey = NULL;
							SET @TableName = NULL;
							SET @SQLQuery = NULL;

							SELECT TOP 1 
								@PropertyKey = propertykey, 
								@TableName = TableName,
								@SQLQuery = SQLQuery
							FROM CommunicationPlaceholderMapping
							WHERE EXISTS (
								SELECT 1 
								FROM OPENJSON(propertyvalue) 
								WHERE LOWER(value) = LOWER(@CurrentPlaceholder)
							);

							IF @PropertyKey IS NOT NULL AND @TableName IS NOT NULL
							BEGIN
								IF @SQLQuery IS NULL
								BEGIN
									SET @Sql = N'SELECT @Result = ' + CONVERT(NVARCHAR(MAX), @PropertyKey) +
												' FROM ' + CONVERT(NVARCHAR(MAX), @TableName) +
												' WHERE UserId = @UserId';
								END
								ELSE
								BEGIN
									SET @Sql = @SQLQuery;
								END

								PRINT 'For: ' + @CurrentPlaceholder;
								PRINT @Sql;

								EXEC sp_executesql @Sql, N'@UserId INT, @Result NVARCHAR(MAX) OUTPUT', @UserId = @UserId, @Result = @Result OUTPUT;

								-- If @Result is NULL, replace the placeholder with an empty string
								IF @Result IS NULL
								BEGIN
									SET @Result = '';
								END

								-- Replace the placeholder in the @Content with the actual value
								SET @Content = REPLACE(@Content, '##' + @CurrentPlaceholder + '##', @Result);
								PRINT 'Updated Content: ' + @Content;
							END

							FETCH NEXT FROM PlaceholderCursorSMS INTO @CurrentPlaceholder;
						END

						CLOSE PlaceholderCursorSMS;
						DEALLOCATE PlaceholderCursorSMS;

						-- Store the final @Content in the @PlaceholderValues
						SET @PlaceholderValues = @Content;
						PRINT 'Final PlaceholderValues (Content): ' + @PlaceholderValues;

                    END
                    ELSE IF @TemplateType = 'Push'
                    BEGIN
                        SET @PlaceholderValues = JSON_VALUE(@Placeholders, '$.Body');
                    END

                    -- Here we store the placeholder value we found for each user
                    UPDATE CTS
                    SET CTS.Placeholders = @PlaceholderValues, Source = @Source
                    FROM dbo.CommunicationToSend CTS
                    WHERE CTS.UserId = @UserId AND CTS.JobStatusId = @CommunicationJobId;

                    FETCH NEXT FROM TempResultsCursor INTO @UserId, @Source, @NodeId;
                END

                CLOSE TempResultsCursor;
                DEALLOCATE TempResultsCursor;
            END                
        END
END;
