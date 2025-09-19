-- =============================================
-- Author:		Neil McAuliffe
-- Create date: 27/06/2014
-- Description:	Monitors all device pools for a client and generates devices as required
-- =============================================
CREATE PROCEDURE [dbo].[bws_MonitorDevicePools]
	-- Add the parameters for the stored procedure here
	@ClientId INT,
	@Result INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Message VARCHAR(100)
	DECLARE @Level VARCHAR(100)
	DECLARE @Stacktrace VARCHAR(MAX)
	DECLARE @Identifier VARCHAR(40)
		
	EXECUTE [bws_ValidateDevicePool] @ClientId, -1, @Result
	IF @Result = -1
	BEGIN
		DECLARE @Error VARCHAR(100) = 'Unable to validate devie pools for client: ' + cast(@ClientId as nvarchar(5))
		RAISERROR (@Error, 0, 1 )
	END
	
	DECLARE @TotalNumberOfDevicesRequired INT = 0;
	DECLARE @TotalNumberOfDevicesAvailable INT = 0;
	DECLARE @Required INT = 0;
	
	BEGIN TRY
	BEGIN TRANSACTION

	SELECT @Identifier = cast(@ClientId as nvarchar(2)) + '_'+ cast(NEWID() as nvarchar(40)) 

	--------------------- Loggging----------------------
	SELECT @Message= 'Begin monitor devie number pools for client: ' + cast(@ClientId as nvarchar(5))
	SELECT @Level= 'Info'
	SELECT @Stacktrace= ''
	INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
	--------------------- Loggging----------------------

	BEGIN
		DECLARE @ID int
		DECLARE IDs CURSOR LOCAL FOR SELECT Id FROM DevicePoolMetadata WHERE ClientId = @ClientId

		OPEN IDs
		FETCH NEXT FROM IDs INTO @ID
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @TotalNumberOfDevicesRequired = MinimumPoolThreshold FROM DevicePoolMetadata WHERE Id = @ID
			SELECT @TotalNumberOfDevicesAvailable = NumberOfAvailableDevices FROM DevicePoolMetadata WHERE Id = @ID 

			--CHECK IF THE VALUES IN THE METADATA TABLE ARE CORRECT
			PRINT('Pool: ' +cast(@ID as nvarchar(3)) + 'Available: ' + cast(@TotalNumberOfDevicesAvailable as nvarchar(10)) + 'Required: '+ cast(@TotalNumberOfDevicesRequired as nvarchar(10)))

			IF @TotalNumberOfDevicesAvailable < @TotalNumberOfDevicesRequired
			BEGIN
				Select @Required = @TotalNumberOfDevicesRequired - @TotalNumberOfDevicesAvailable					
				EXEC bws_CreateDevicesForDevicePoolMetadata @ClientId, @ID, @Required, NULL, @Result
			END

			FETCH NEXT FROM IDs INTO @ID
		END

		CLOSE IDs
		DEALLOCATE IDs
	END	

	SELECT @Result = 1

	--------------------- Loggging----------------------
	SELECT @Message= 'Complete monitor device pools for client: ' + cast(@ClientId as nvarchar(5))
	SELECT @Level= 'Info'
	SELECT @Stacktrace= ''
	INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
	--------------------- Loggging----------------------
	
	Select @Result As Result, @Message AS [Message]

	COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		--------------------- Loggging----------------------
		SELECT @Message= 'Unable to monitor device pools for client: ' + cast(@ClientId as nvarchar(5))
		SELECT @Level= 'Error'
		SELECT @Stacktrace= ERROR_MESSAGE();
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace);
		--------------------- Loggging----------------------
				
		SELECT @Result = -1

		Select @Result As Result, @Message AS [Message]
	END CATCH
END
