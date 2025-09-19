-- =============================================
-- Author:		Neil McAuliffe
-- Create date: 27/06/2014
-- Description:	Creates a specified number of devices for a given device pool
-- =============================================
CREATE PROCEDURE [dbo].[bws_CreateDevicesForDevicePoolMetadata]
	-- Add the parameters for the stored procedure here
	@ClientId INT,
	@DevicePoolMetadataId INT,
	@TotalDevicesToCreate int,
	@Reference nvarchar(50)=null,	
	@Result INT OUTPUT
AS
BEGIN
	Print('Generate Devices For Device Pool : ' + CAST( @DevicePoolMetadataId as varchar(6)))
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Message VARCHAR(100)
	DECLARE @Level VARCHAR(100)
	DECLARE @Stacktrace VARCHAR(MAX)
	DECLARE @Identifier VARCHAR(40)
	
	DECLARE @ParentSiteId int ;
	DECLARE @InitialDeviceStatusId int ;
	DECLARE @InitialDeviceTypeId int ;
	DECLARE @InitialAccountStatusId int ;	
	
	DECLARE @TotalDevicesGenerated INT = 0;
	DECLARE @UserId INT;
	DECLARE @DeviceNumberGeneratorTemplateId INT;
	DECLARE @NewAccountId INT;
	DECLARE @NewDeviceId INT;
	DECLARE @SelectedDeviceNumber VARCHAR(25);
	DECLARE @SelectedDeviceNumberId INT;

	BEGIN TRY
	
	--Validate device number pool prior to execution	
	EXECUTE [bws_ValidateDeviceNumberPool] @ClientId, @DeviceNumberGeneratorTemplateId, @Result

	SELECT @Identifier = cast(@ClientId as nvarchar(2)) + '_'+ cast(NEWID() as nvarchar(40)) 

	--------------------- Loggging----------------------
	SELECT @Message= 'Begin generate devices for device pool: ' + cast(@DevicePoolMetadataId as nvarchar(5))
	SELECT @Level= 'Info'
	SELECT @Stacktrace= ''
	INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
	--------------------- Loggging----------------------

	SELECT @ParentSiteId = SiteId FROM [Site] WHERE ParentId = SiteId and ClientId = @ClientId
	SELECT 
		@DeviceNumberGeneratorTemplateId = DeviceNumberGeneratorTemplateId,
		@InitialDeviceStatusId= InitialDeviceStatusId,
		@InitialDeviceTypeId= InitialDeviceTypeId,
		@InitialAccountStatusId= InitialAssociatedAccountStatusId
		FROM DevicePoolMetadata WHERE Id = @DevicePoolMetadataId AND ClientId = @ClientId 


	-- If the number of devices to create is not specified top up the pool
	IF @TotalDevicesToCreate IS NULL
	BEGIN
		SELECT @TotalDevicesToCreate = MinimumPoolThreshold FROM DevicePoolMetadata WHERE Id = @DevicePoolMetadataId AND ClientId = @ClientId
		
		DECLARE @AvailableDevices INT;
		SELECT @AvailableDevices = NumberOfAvailableDevices FROM DevicePoolMetadata WHERE Id = @DevicePoolMetadataId AND ClientId = @ClientId
		SELECT @TotalDevicesToCreate = @TotalDevicesToCreate - @AvailableDevices				
	END

	IF @TotalDevicesToCreate <= 0
	BEGIN
		SELECT @TotalDevicesToCreate = 0

		--------------------- Loggging----------------------
		SELECT @Message= 'Sufficent devices available for device pool: ' + cast(@DevicePoolMetadataId as nvarchar(5))
		SELECT @Level= 'Info'
		SELECT @Stacktrace= ''
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
		--------------------- Loggging----------------------

	END

	--Check if there are enough numbers to create the required devices if not generate the required amount of numbers
	DECLARE @AvailableNumberInPool INT;
	SELECT @AvailableNumberInPool =AvailableNumbersInPool FROM DeviceNumberGeneratorTemplate WHERE ID = @DeviceNumberGeneratorTemplateId;
	
		PRINT(@AvailableNumberInPool)
		PRINT(@TotalDevicesToCreate)

	IF( @AvailableNumberInPool< @TotalDevicesToCreate)
	BEGIN
		PRINT('Insufficent numbers available')
		DECLARE @NumbersToCreate INT = @TotalDevicesToCreate - @AvailableNumberInPool		
		EXEC bws_CreateNumbersForDeviceNumberGeneratorTemplate @ClientId, @DeviceNumberGeneratorTemplateId, @NumbersToCreate, '', @Result
		IF @Result = -1
		BEGIN
			DECLARE @Error VARCHAR(100) = 'Unable to generate sufficent numbers for device pool: ' + cast(@DevicePoolMetadataId as nvarchar(5))
			RAISERROR (@Error, 0, 1 )
		END
	END

	-- Select the batch processor user for the client
	SELECT TOP 1  @UserId = UserId FROM [User] WHERE SiteId IN (SELECT SiteId FROM Site Where ClientId = @ClientId) AND Username = 'batchprocessadmin'

	BEGIN TRY
	BEGIN TRANSACTION

	--Select All required devices into temp table
	SELECT TOP (@TotalDevicesToCreate) Id, DeviceNumber INTO #DeviceNumbers FROM DeviceNumberPool WHERE TemplateId = @DeviceNumberGeneratorTemplateId 
			AND StatusId IN (SELECT Id FROM DeviceNumberStatus WHERE Name = 'Created' AND ClientId = @ClientId)

	UPDATE DeviceNumberPool SET StatusId = (SELECT TOP 1 Id FROM DeviceNumberStatus WHERE Name = 'Used' AND ClientId = @ClientId) WHERE Id IN
	(SELECT Id FROM #DeviceNumbers)
	
	PRINT('Begin Cursor')
	
	BEGIN
	DECLARE @ID int
	DECLARE IDs CURSOR LOCAL FOR 
	SELECT Id, DeviceNumber FROM #DeviceNumbers

	OPEN IDs
	FETCH NEXT FROM IDs INTO @SelectedDeviceNumberId, @SelectedDeviceNumber
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO Account (AccountStatusTypeId, MonetaryBalance, PointsBalance, CreateDate) VALUES (@InitialAccountStatusId, 0, 0, GETDATE())
		SELECT @NewAccountId = SCOPE_IDENTITY()

		INSERT INTO Device (DeviceId, DeviceStatusId, DeviceTypeId, UserId, HomeSiteId, CreateDate, DeviceNumberPoolId, AccountId, Pin)  
		VALUES (@SelectedDeviceNumber, @InitialDeviceStatusId, @InitialDeviceTypeId, null, @ParentSiteId, GETDATE(), @SelectedDeviceNumberId, @NewAccountId,FLOOR( 1000 + ( RAND(CAST( NEWID() AS varbinary )) *8999 ) ))
		
		FETCH NEXT FROM IDs INTO @SelectedDeviceNumberId, @SelectedDeviceNumber
	END

	CLOSE IDs
	DEALLOCATE IDs
	END	
	
	SELECT @TotalDevicesGenerated = COUNT (*) FROM #DeviceNumbers

	DROP TABLE #DeviceNumbers

	COMMIT TRANSACTION		
	END TRY
	BEGIN CATCH
			EXECUTE usp_GetErrorInfo;
	END CATCH

	EXECUTE [bws_ValidateDevicePool] @ClientId, @DevicePoolMetadataId, @Result
	EXECUTE [bws_ValidateDeviceNumberPool] @ClientId, @DeviceNumberGeneratorTemplateId, @Result


	--------------------- Loggging----------------------
	SELECT @Message= 'Succesfully generated ' + cast(@TotalDevicesGenerated as nvarchar(10)) + ' devices for device pool: ' + cast(@DevicePoolMetadataId as nvarchar(5))
	SELECT @Level= 'Info'
	SELECT @Stacktrace= ''
	INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
	--------------------- Loggging----------------------

	SELECT @Result = 1
	
	Select @Result As Result, @Message AS [Message]

	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION

		--------------------- Loggging----------------------
		SELECT @Message= 'Unable to generate devices'
		SELECT @Level= 'Error'
		SELECT @Stacktrace= ERROR_MESSAGE();
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace);
		--------------------- Loggging----------------------

		SELECT @Result = -1

		
		Select @Result As Result, @Message AS [Message]
	END CATCH
END
