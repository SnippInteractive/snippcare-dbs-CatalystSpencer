-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2025-06-01
-- Description:	SaveUserNotificationTemplateHistory
-- Modified Date: 2025-06-01
-- =============================================
CREATE PROCEDURE [dbo].[AddOrUpdateNotificationTemplate]
(
	@NotificationAsJSONString	NVARCHAR(MAX) = ''
)
AS
BEGIN
BEGIN TRAN
	/*---------------------------------------------------------------------------------------------------------------------------
		Since, the Notification details are being passed as JSON String, extracting the values from the JSON string.
	---------------------------------------------------------------------------------------------------------------------------*/
	DECLARE 
		@Result				NVARCHAR(MAX)	= '',
		@NotificationTemplateId		INT		= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.Id') AS INT),
		@NotificationTemplateTypeId	INT		= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.NotificationTemplateTypeId') AS INT),
		@ClientId			INT				= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.ClientId') AS INT),
		@NotificationName	NVARCHAR(100)	= JSON_VALUE(@NotificationAsJSONString,'$.Name'),		
		@Subject	NVARCHAR(100)			= JSON_VALUE(@NotificationAsJSONString,'$.Subject'),		
		@Placeholders		NVARCHAR(500)	= JSON_VALUE(@NotificationAsJSONString,'$.Placeholders'),
		@IsCampaign bit						= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.IsCampaign') AS bit),
		@UserSegments	NVARCHAR(MAX)		= JSON_QUERY(@NotificationAsJSONString,'$.UserSegments'),
		@CreatedBy INT						= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.CreatedBy') AS INT),
		@CreatedDate DATETIME				= getdate(),
		@UpdatedBy INT						= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.UpdatedBy') AS INT),
		@UpdatedDateTime DATETIME			=  getdate(),
		@ExtraInfo			NVARCHAR(MAX)	= JSON_VALUE(@NotificationAsJSONString,'$.ExtraInfo'),
		@NotificationStatusId INT			= JSON_VALUE(@NotificationAsJSONString,'$.NotificationStatusId'),
		@WeekendVoucherInfo			NVARCHAR(MAX)	= JSON_VALUE(@NotificationAsJSONString,'$.WeekendVoucherInfo')
		/*
		PRINT '--------'
		PRINT TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.Id') AS INT)
		PRINT TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.NotificationTemplateTypeId') AS INT)
		PRINT TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.ClientId') AS INT)
		PRINT JSON_VALUE(@NotificationAsJSONString,'$.Name')
		PRINT JSON_VALUE(@NotificationAsJSONString,'$.Subject')		
		PRINT JSON_VALUE(@NotificationAsJSONString,'$.Placeholders')
		PRINT TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.IsCampaign') AS bit)
		PRINT JSON_QUERY(@NotificationAsJSONString,'$.UserSegments')
		PRINT TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.CreatedBy') AS INT)
		PRINT getdate()
		PRINT TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.UpdatedBy') AS INT)
		PRINT getdate()
		PRINT JSON_VALUE(@NotificationAsJSONString,'$.ExtraInfo')
		PRINT JSON_VALUE(@NotificationAsJSONString,'$.NotificationStatusId')
		PRINT '--------'
		*/
	DECLARE @NotificationTemplateTypeIdPush INT,
			@NotificationTemplateTypeIdSMS INT,
			@NotificationTypeId INT,
			@Display bit = 1,
			@NotificareTemplateId NVARCHAR(100)	= NEWID(), 
			@DeviceProfileTemplateId INT = 1058,
			@ClassicalVoucherId NVARCHAR(50) = '231219',
			@DeviceStatusIdActive INT

	select @DeviceStatusIdActive = DeviceStatusId from DeviceStatus where clientid = @ClientId AND Name = 'Active'

	select @NotificationTemplateTypeIdPush = Id from NotificationTemplateType where clientid = @ClientId AND Name = 'Push'
	select @NotificationTemplateTypeIdSMS = Id from NotificationTemplateType where clientid = @ClientId AND Name = 'SMS'
	
	DECLARE		@NotificationTemplateType_NEW NVARCHAR(100),
				@NotificationType_NEW NVARCHAR(500),
				@NotificationStatus_NEW  NVARCHAR(100)

	SELECT @NotificationStatus_NEW = Name FROM NotificationStatus WHERE ClientId=@ClientId AND NotificationStatusId = @NotificationStatusId

	if isnull(@IsCampaign,0) = 1
	BEGIN
		select @NotificationTypeId = Id,@NotificationType_NEW = Name from NotificationType where clientid = @ClientId AND Name = 'Campaign'
	END
	ELSE
	BEGIN
		select @NotificationTypeId = Id,@NotificationType_NEW = Name from NotificationType where clientid = @ClientId AND Name = 'System'
		--IF EXISTS (SELECT 1 FROM NotificationStatus WHERE clientid = @ClientId AND Name = 'Publish' AND NotificationStatusId = @NotificationStatusId)
		--BEGIN
		--	--marking it sent by default, as the actual notificaiton is happening directly from firebase - this is just to display in the app
		--	--!!remove the variable once the push notifications started sending from Catalyst!!
		--	--DECLARE @NotificationStatusId INT
		--	SELECT @NotificationStatusId = NotificationStatusId,@NotificationStatus_NEW = Name FROM NotificationStatus WHERE ClientId=@ClientId AND [Name]='Sent'
		--END
	END

	IF(@NotificationTemplateTypeId = @NotificationTemplateTypeIdPush)
	BEGIN
		SET @NotificationTemplateType_NEW = 'Push'
		SET @Placeholders = '{ "Subject": "'+@Subject+'", "Body": "'+@Placeholders+'" }'
		SET @NotificareTemplateId = 'p-'+ LOWER(REPLACE(@NotificareTemplateId,'-',''))
	END
	IF(@NotificationTemplateTypeId = @NotificationTemplateTypeIdSMS)
	BEGIN
		SET @NotificationTemplateType_NEW = 'SMS'
		SET @Placeholders = '{ "Content": "'+@Placeholders+'" }'
		SET @NotificareTemplateId = 's-'+ LOWER(REPLACE(@NotificareTemplateId,'-',''))
	END

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
	IF LEN(ISNULL(@NotificationName,'')) = 0 
	BEGIN
		SELECT 'InvalidName' AS Result
		RETURN		
	END
	IF ISNULL(@Placeholders,'') = ''
	BEGIN
		SELECT 'InvalidPlaceholders' AS Result
		RETURN	
	END
	IF ISNULL(@NotificationStatusId,0) = 0
	BEGIN
		PRINT @NotificationStatusId
		SELECT 'InvalidNotificationStatus' AS Result
		RETURN	
	END

	IF ISNULL(@WeekendVoucherInfo,'') <> ''
	BEGIN
		--SELECT * FROM Device Where DeviceStatusId = 2 AND DeviceId = '231219' AND GETDATE() between StartDate AND ExpirationDate
		--UPDATE Device SET DeviceStatusId = 1 WHERE DeviceId = '231219'
		--PRINT 'Voucher'
		IF EXISTS (SELECT 1 FROM Device Where DeviceStatusId = @DeviceStatusIdActive AND DeviceId = @ClassicalVoucherId AND GETDATE() between StartDate AND ExpirationDate)
		BEGIN
			SELECT 'InvalidWeekendVoucher' AS Result
			RETURN	
		END
	END

	IF ISNULL(@NotificationTemplateId,0) <> 0 AND NOT EXISTS (SELECT 1 FROM NotificationTemplate n 
				inner join NotificationStatus ns on n.NotificationStatusId = ns.NotificationStatusId 
				Where n.Id = @NotificationTemplateId AND LOWER(ns.Name) = 'draft')-- IN('Publish','Sent'))
	BEGIN
		PRINT @NotificationTemplateId
		SELECT 'InvalidNotification' AS Result
		RETURN	
	END

	--AUDIT
	IF @NotificationTemplateId > 0
		BEGIN
		DECLARE @NotificationTemplateType_OLD NVARCHAR(100),
				@NotificationName_OLD NVARCHAR(500),
				@Placeholders_OLD NVARCHAR(500),
				@NotificationType_OLD NVARCHAR(500),
				@UpdatedBy_OLD INT,
				--@UpdatedDateTime_OLD datetime,
				@ExtraInfo_OLD NVARCHAR(MAX),
				@NotificationStatus_OLD  NVARCHAR(100),
				@SysUser INT = -1,
				@WeekendVoucherInfo_OLD NVARCHAR(MAX)

		SELECT 	@NotificationTemplateType_OLD = ntt.Name,
				@NotificationName_OLD = n.Name,
				@Placeholders_OLD = n.Placeholders,
				@NotificationType_OLD = nt.Name,
				@UpdatedBy_OLD = n.UpdatedBy,
				--@UpdatedDateTime_OLD = n.UpdatedDateTime,
				@ExtraInfo_OLD = n.ExtraInfo,
				@NotificationStatus_OLD = ns.Name,
				@WeekendVoucherInfo_OLD = n.WeekendVoucherInfo
		 FROM  NotificationTemplate n
		 INNER JOIN NotificationTemplateType ntt on n.NotificationTemplateTypeId = ntt.Id
		 INNER JOIN NotificationType nt on n.NotificationTypeId = nt.Id
		 INNER JOIN NotificationStatus ns on n.NotificationStatusId = ns.NotificationStatusId
		 WHERE  n.id = @NotificationTemplateId

		 IF TRIM(ISNULL(@NotificationTemplateType_OLD,'')) <> TRIM(ISNULL(@NotificationTemplateType_NEW,''))
		 BEGIN
			INSERT INTO [AUDIT] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,
			ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser)
			VALUES (1,@UpdatedBy,'NotificationTemplateType', @NotificationTemplateType_NEW,@NotificationTemplateType_OLD, GETDATE(),
			@UpdatedBy,'Saving NotificationTemplateType-'+ CONVERT(NVARCHAR(10), @NotificationTemplateId),@NotificationTemplateId,@UpdatedBy,null,'NotificationTemplate',@SysUser)
		 END
		 IF TRIM(ISNULL(@NotificationName_OLD,'')) <> TRIM(ISNULL(@NotificationName,''))
		 BEGIN
			INSERT INTO [AUDIT] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,
			ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser)
			VALUES (1,@UpdatedBy,'NotificationName', @NotificationName,@NotificationName_OLD, GETDATE(),
			@UpdatedBy,'Saving NotificationTemplateType-'+ CONVERT(NVARCHAR(10), @NotificationTemplateId),@NotificationTemplateId,@UpdatedBy,null,'NotificationTemplate',@SysUser)
		 END
		 IF TRIM(ISNULL(@Placeholders_OLD,'')) <> TRIM(ISNULL(@Placeholders,''))
		 BEGIN
			INSERT INTO [AUDIT] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,
			ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser)
			VALUES (1,@UpdatedBy,'Placeholders', @Placeholders,@Placeholders_OLD, GETDATE(),
			@UpdatedBy,'Saving NotificationTemplateType-'+ CONVERT(NVARCHAR(10), @NotificationTemplateId),@NotificationTemplateId,@UpdatedBy,null,'NotificationTemplate',@SysUser)
		 END
		 IF TRIM(ISNULL(@NotificationType_OLD,'')) <> TRIM(ISNULL(@NotificationType_NEW,''))
		 BEGIN
			INSERT INTO [AUDIT] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,
			ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser)
			VALUES (1,@UpdatedBy,'NotificationType', @NotificationType_NEW,@NotificationType_OLD, GETDATE(),
			@UpdatedBy,'Saving NotificationTemplateType-'+ CONVERT(NVARCHAR(10), @NotificationTemplateId),@NotificationTemplateId,@UpdatedBy,null,'NotificationTemplate',@SysUser)
		 END
		 IF ISNULL(@UpdatedBy_OLD,0) <> ISNULL(@UpdatedBy,0)
		 BEGIN
			INSERT INTO [AUDIT] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,
			ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser)
			VALUES (1,@UpdatedBy,'UpdatedBy', @UpdatedBy,@UpdatedBy_OLD, GETDATE(),
			@UpdatedBy,'Saving NotificationTemplateType-'+ CONVERT(NVARCHAR(10), @NotificationTemplateId),@NotificationTemplateId,@UpdatedBy,null,'NotificationTemplate',@SysUser)
		 END
		 IF TRIM(ISNULL(@ExtraInfo_OLD,'')) <> TRIM(ISNULL(@ExtraInfo,''))
		 BEGIN
			INSERT INTO [AUDIT] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,
			ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser)
			VALUES (1,@UpdatedBy,'ExtraInfo', @ExtraInfo,@ExtraInfo_OLD, GETDATE(),
			@UpdatedBy,'Saving NotificationTemplateType-'+ CONVERT(NVARCHAR(10), @NotificationTemplateId),@NotificationTemplateId,@UpdatedBy,null,'NotificationTemplate',@SysUser)
		 END
		 IF TRIM(ISNULL(@NotificationStatus_OLD,'')) <> TRIM(ISNULL(@NotificationStatus_NEW,''))
		 BEGIN
			INSERT INTO [AUDIT] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,
			ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser)
			VALUES (1,@UpdatedBy,'NotificationStatus', @NotificationStatus_NEW,@NotificationStatus_OLD, GETDATE(),
			@UpdatedBy,'Saving NotificationTemplateType-'+CONVERT(NVARCHAR(10), @NotificationTemplateId),@NotificationTemplateId,@UpdatedBy,null,'NotificationTemplate',@SysUser)
		 END
		 IF TRIM(ISNULL(@WeekendVoucherInfo_OLD,'')) <> TRIM(ISNULL(@WeekendVoucherInfo,''))
		 BEGIN
			INSERT INTO [AUDIT] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,
			ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser)
			VALUES (1,@UpdatedBy,'WeekendVoucherInfo', @WeekendVoucherInfo,@WeekendVoucherInfo_OLD, GETDATE(),
			@UpdatedBy,'Saving NotificationTemplateType-'+ CONVERT(NVARCHAR(10), @NotificationTemplateId),@NotificationTemplateId,@UpdatedBy,null,'NotificationTemplate',@SysUser)
		 END
		 	END
	--AUDIT

	BEGIN TRY
		/*----------------------------------------------------------------------------------------------
			Checking whether the @NotificationId > 0, then the old values are updated with the new ones.
			Else, new record is being inserted.
		----------------------------------------------------------------------------------------------*/
		IF @NotificationTemplateId > 0
		BEGIN
			PRINT 'UPDATE'
			UPDATE [dbo].[NotificationTemplate]
			   SET [Version] = [Version]+1
				  ,[NotificationTemplateTypeId] = @NotificationTemplateTypeId
				  ,[Name] = @NotificationName
				  ,[Placeholders] = @Placeholders
				  ,[NotificationTypeId] = @NotificationTypeId
				  --,[CreatedBy] = @CreatedBy
				  --,[CreatedDate] =@CreatedDate
				  ,[UpdatedBy]=	@UpdatedBy
				  ,[UpdatedDateTime] =	@UpdatedDateTime
				  ,[ExtraInfo] = @ExtraInfo
				  ,[NotificationStatusId] = @NotificationStatusId
				  ,[WeekendVoucherInfo] = @WeekendVoucherInfo
			 WHERE Id = @NotificationTemplateId
		END
		ELSE
		BEGIN
			PRINT 'INSERT'
			INSERT INTO [dbo].[NotificationTemplate]([Version],[NotificationTemplateTypeId],[Name],[Display],[NotificareTemplateId],[Placeholders],[NotificationTypeId]
			,[CreatedBy],[CreatedDate],[UpdatedBy],[UpdatedDateTime],[ExtraInfo],[NotificationStatusId],[WeekendVoucherInfo])
			
			VALUES(0,@NotificationTemplateTypeId,@NotificationName,@Display,@NotificareTemplateId,@Placeholders,@NotificationTypeId
			,@CreatedBy,@CreatedDate,@UpdatedBy,@UpdatedDateTime,@ExtraInfo,@NotificationStatusId,@WeekendVoucherInfo)

			SET @NotificationTemplateId = SCOPE_IDENTITY()
		END

		IF @NotificationTemplateId > 0
		BEGIN
			
			DECLARE @UserSegments_OLD NVARCHAR(MAX) = ''
			DECLARE @UserSegments_NEW NVARCHAR(MAX) = ''

			select @UserSegments_OLD = @UserSegments_OLD + convert(nvarchar(10),SegmentId) + ', ' from NotificationTemplateSegment WHERE NotificationTemplateId = @NotificationTemplateId
			SET @UserSegments_OLD  = SUBSTRING(@UserSegments_OLD, 0, LEN(@UserSegments_OLD))

			--select  @tmp

			DELETE	NotificationTemplateSegment
			WHERE	NotificationTemplateId	= @NotificationTemplateId
			
			--marking it sent by default, as the actual notificaiton is happening directly from firebase - this is just to display in the app
			--!!remove the variable once the push notifications started sending from Catalyst!!
			--DECLARE @NotificationStatusId INT
			--SELECT @NotificationStatusId = NotificationStatusId FROM NotificationStatus WHERE ClientId=@ClientId AND [Name]='Sent'

			
			INSERT	NotificationTemplateSegment(Version,SegmentId,NotificationTemplateId)
			SELECT	0,UserSegmentId,@NotificationTemplateId
			FROM	OPENJSON(JSON_QUERY(@UserSegments)) 
			WITH
			(
					UserSegmentId			INT--,
					--Publish					BIT						
			)

			select @UserSegments_NEW = @UserSegments_NEW + convert(nvarchar(10),SegmentId) + ', ' from NotificationTemplateSegment WHERE NotificationTemplateId = @NotificationTemplateId
			SET @UserSegments_NEW  = SUBSTRING(@UserSegments_NEW, 0, LEN(@UserSegments_NEW))

			IF TRIM(ISNULL(@UserSegments_NEW,'')) <> TRIM(ISNULL(@UserSegments_OLD,''))
			BEGIN
				INSERT INTO [AUDIT] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,
				ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser)
				VALUES (1,@UpdatedBy,'NotificationTemplateSegment', @UserSegments_NEW,@UserSegments_OLD, GETDATE(),
				@UpdatedBy,'Saving NotificationTemplateType-'+CONVERT(NVARCHAR(10), @NotificationTemplateId),@NotificationTemplateId,@UpdatedBy,null,'NotificationTemplate',@SysUser)
			END

		END

		/*---------------------------------------------------------------------------------------------
			Updating the UserNotifications by replacing  the old records with the new ones.
		---------------------------------------------------------------------------------------------*/
		IF @NotificationTemplateId > 0 AND ISNULL(@WeekendVoucherInfo,'') <> ''
		BEGIN
			--PRINT @WeekendVoucherInfo
			DECLARE @StartDate DATETIME,
					@EndDate DATETIME,
					@Title1 NVARCHAR(1000),
					@Title2 NVARCHAR(1000),
					@ImageUrl NVARCHAR(MAX),
					@SegmentId INT

			--SELECT DATEADD(day, DATEDIFF(day, 0, GETDATE()), '23:59:59')

			SET @StartDate	= TRY_CAST(JSON_VALUE(@WeekendVoucherInfo,'$.StartDate') AS DATETIME)
			SET @EndDate	= TRY_CAST(JSON_VALUE(@WeekendVoucherInfo,'$.EndDate') AS DATETIME)
			SET @Title1	= TRY_CAST(JSON_VALUE(@WeekendVoucherInfo,'$.Title1') AS nvarchar(1000))
			SET @Title2	= TRY_CAST(JSON_VALUE(@WeekendVoucherInfo,'$.Title2') AS nvarchar(1000))
			SET @ImageUrl	= TRY_CAST(JSON_VALUE(@WeekendVoucherInfo,'$.ImageUrl') AS nvarchar(MAX))
			SET @SegmentId	= TRY_CAST(JSON_VALUE(@WeekendVoucherInfo,'$.SegmentId') AS INT)

			SET @StartDate = DATEADD(day, DATEDIFF(day, 0, @StartDate), '00:00:00')
			SET @EndDate = DATEADD(day, DATEDIFF(day, 0, @EndDate), '23:59:59')

			IF ISNULL(@SegmentId,-1) < 1
			BEGIN	
				SET @SegmentId = null;
			END

			IF EXISTS (SELECT 1 FROM Device Where DeviceId = @ClassicalVoucherId)
			BEGIN
				

				update Device set StartDate=@StartDate,
					  ExpirationDate=@EndDate,
					  ExtraInfo=@SegmentId,
					  DeviceStatusId=@DeviceStatusIdActive,
					  ImageUrl=@ImageUrl
				where deviceid= @ClassicalVoucherId
				/*
					SELECT * FROM Device where deviceid='231219'
					SELECT * FROM DeviceProfileTemplate where Id = 1058 
					SELECT  * FROM VoucherSegments where VoucherId = 1058 
				*/
				--Title1 goes to code & Title2 goes to Name
				update DeviceProfileTemplate set code= @Title1 , [Name]= @Title2 where Id = @DeviceProfileTemplateId 

				DELETE VoucherSegments WHERE VoucherId = @DeviceProfileTemplateId

				IF ISNULL(@SegmentId,-1) > 0
				BEGIN
					INSERT INTO VoucherSegments values(1,@DeviceProfileTemplateId,@SegmentId)
				END
				--insert to VoucherSegment values(1,1058,1008)
			END
		END

		SET @Result = '
		{
			"Success":true,
			"Message":"SaveNotificationSuccess",
			"Data":' + CAST(@NotificationTemplateId AS NVARCHAR(200)) + '
		}'


		

	COMMIT TRAN
	END TRY
	BEGIN CATCH
	ROLLBACK TRAN
		SET @Result =	'SaveNotificationFailed;
						 ErrorProcedure:'	+	ERROR_PROCEDURE() +
						'Error at Line:'	+	CAST(ERROR_LINE() AS NVARCHAR(100))	+
						'Exception Message:'+	ERROR_MESSAGE()	
	END CATCH

	SELECT @Result AS Result
END
