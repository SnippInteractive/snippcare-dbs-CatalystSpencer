
CREATE PROCEDURE [dbo].[AddOrUpdateNotification]
(
	@NotificationAsJSONString	NVARCHAR(MAX) = ''
)
AS
BEGIN
	/*---------------------------------------------------------------------------------------------------------------------------
		Since, the Notification details are being passed as JSON String, extracting the values from the JSON string.
	---------------------------------------------------------------------------------------------------------------------------*/
	DECLARE 
		@Result				NVARCHAR(MAX)	= '',
		@NotificationId		INT				= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.Id') AS INT),
		@Version			INT				= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.Version') AS INT),
		@NotificationTypeId	INT				= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.NotificationTypeId') AS INT),
		@ClientId			INT				= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.ClientId') AS INT),
		@CreatedBy			INT				= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.CreatedBy') AS INT),
		@UpdatedBy			INT				= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.UpdatedBy') AS INT),
		@Deleted			BIT				= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.Deleted') AS BIT),
		@CreatedDate		DATETIME2		= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.CreatedDate') AS DATETIME2),
		@UpdatedDateTime	DATETIME2		= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.UpdatedDateTime') AS DATETIME2),
		@NotificationName	NVARCHAR(100)	= JSON_VALUE(@NotificationAsJSONString,'$.NotificationName'),
		@Subject			NVARCHAR(250)	= JSON_VALUE(@NotificationAsJSONString,'$.Subject'),
		@Description		NVARCHAR(500)	= JSON_VALUE(@NotificationAsJSONString,'$.Description'),
		@Content			NVARCHAR(MAX)	= JSON_VALUE(@NotificationAsJSONString,'$.Content'),
		@ExtraInfo			NVARCHAR(MAX)	= JSON_VALUE(@NotificationAsJSONString,'$.ExtraInfo'),
		@ImageUrl			NVARCHAR(500)	= JSON_VALUE(@NotificationAsJSONString,'$.ImageUrl'),
		@UserSegments		NVARCHAR(MAX)   = JSON_QUERY(@NotificationAsJSONString,'$.UserSegments'),
		@NotificationStatusId INT



	/*---------------------------------------------------------------------------------------------------------------------------
		validating the JSON string,ClientId and the subject.
	---------------------------------------------------------------------------------------------------------------------------*/

	IF ISJSON(ISNULL(@NotificationASJSONString,'')) = 0 OR ISJSON(@NotificationASJSONString) = 0
	BEGIN
		SELECT 'InvalidNotification' AS Result
		RETURN
	END
	IF @ClientId IS NULL OR @ClientId = 0
	BEGIN
		SELECT 'InvalidClient' AS Result
		RETURN		
	END
	IF LEN(ISNULL(@Subject,'')) = 0 
	BEGIN
		SELECT 'InvalidSubject' AS Result
		RETURN		
	END
	IF ISNULL(@UserSegments,'') = ''
	BEGIN
		SELECT 'InvalidSegment' AS Result
		RETURN	
	END

	BEGIN TRY
		/*----------------------------------------------------------------------------------------------
			Checking whether the @NotificationId > 0, then the old values are updated with the new ones.
			Else, new record is being inserted.
		----------------------------------------------------------------------------------------------*/
		IF @NotificationId > 0
		BEGIN
			UPDATE	Notifications
			SET		NotificationName	= @NotificationName,
					NotificationTypeId	= @NotificationTypeId,
					Subject				= @Subject,
					Description			= @Description,
					Content				= @Content,
					ClientId			= @ClientId,
					CreatedBy			= @CreatedBy,
					CreatedDate			= TRY_CAST(@CreatedDate AS DATETIME),
					UpdatedBy			= @UpdatedBy,
					UpdatedDateTime		= TRY_CAST(@UpdatedDateTime AS DATETIME),
					ExtraInfo			= @ExtraInfo,
					ImageUrl			= @ImageUrl,
					Deleted				= @Deleted,
					Version				= ISNULL(@Version,0) + 1
			WHERE	NotificationId		= @NotificationId
		END
		ELSE
		BEGIN

			INSERT	Notifications
			(
					NotificationName,NotificationTypeId,Subject,
					Description,Content,ClientId,
					CreatedBy,CreatedDate,UpdatedBy,
					UpdatedDateTime,ExtraInfo,ImageUrl,
					Deleted,Version								
			)
			VALUES
			(
					@NotificationName,@NotificationTypeId,@Subject,
					@Description,@Content,@ClientId,
					@CreatedBy,TRY_CAST(@CreatedDate AS DATETIME),@UpdatedBy,
					TRY_CAST(@UpdatedDateTime AS DATETIME),@ExtraInfo,@ImageUrl,
					@Deleted,0
			)

			SET		@NotificationId = SCOPE_IDENTITY()
		END
		/*---------------------------------------------------------------------------------------------
			Updating the UserNotifications by replacing  the old records with the new ones.
		---------------------------------------------------------------------------------------------*/
		IF @NotificationId > 0
		BEGIN
			DELETE	UserNotifications
			WHERE	NotificationId		= @NotificationId
			
			--marking it sent by default, as the actual notificaiton is happening directly from firebase - this is just to display in the app
			--!!remove the variable once the push notifications started sending from Catalyst!!
			SELECT @NotificationStatusId = NotificationStatusId FROM NotificationStatus WHERE ClientId=@ClientId AND [Name]='Sent'

			

			IF @Deleted = 0
			BEGIN
				INSERT	UserNotifications(Version,UserSegmentId,NotificationId,Publish,NotificationStatusId)
				SELECT	0,UserSegmentId,@NotificationId,Publish,@NotificationStatusId
				FROM	OPENJSON(JSON_QUERY(@UserSegments)) 
				WITH
				(
						UserSegmentId			INT,
						Publish					BIT						
				)
			END
		END

		SET @Result = '
		{
			"Success":true,
			"Message":"SaveNotificationSuccess",
			"Data":' + CAST(@NotificationId AS NVARCHAR(200)) + '
		}'

	END TRY
	BEGIN CATCH

		SET @Result =	'SaveNotificationFailed;
						 ErrorProcedure:'	+	ERROR_PROCEDURE() +
						'Error at Line:'	+	CAST(ERROR_LINE() AS NVARCHAR(100))	+
						'Exception Message:'+	ERROR_MESSAGE()	
	END CATCH

	SELECT @Result AS Result
END
