-- =============================================
-- Author:		Neil McAuliffe
-- Create date: 27/06/2014
-- Description:	Validates the device pools, if no device pool Id is passed in then all pools are validated
-- =============================================
CREATE PROCEDURE [dbo].[bws_ValidateDevicePool]
	-- Add the parameters for the stored procedure here
	@ClientId INT,
	@DevicePoolMetadataId INT = -1,
	@Result INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
	DECLARE @TotalNumberOfDevicesUsed INT
	DECLARE @TotalNumberOfDevicesAvailable INT
	DECLARE @MinimumPoolThreshold INT
	
	BEGIN TRY
	BEGIN TRANSACTION
	IF @DevicePoolMetadataId < 0 
		BEGIN
			DECLARE @ID int
			DECLARE IDs CURSOR LOCAL FOR SELECT Id FROM DevicePoolMetadata WHERE ClientId = @ClientId

			OPEN IDs
			FETCH NEXT FROM IDs INTO @ID
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @TotalNumberOfDevicesUsed = COUNT(*) FROM Device AS D INNER JOIN DeviceNumberPool AS DN ON D.DeviceNumberPoolId = DN.Id WHERE DN.TemplateId IN (SELECT DeviceNumberGeneratorTemplateId FROM  DevicePoolMetadata WHERE Id = @ID)
				SELECT @TotalNumberOfDevicesAvailable = COUNT(*) FROM Device AS D INNER JOIN DeviceNumberPool AS DN ON D.DeviceNumberPoolId = DN.Id WHERE DN.TemplateId  IN (SELECT DeviceNumberGeneratorTemplateId FROM  DevicePoolMetadata WHERE Id = @ID)
					   AND D.DeviceStatusId IN (SELECT DeviceStatusId FROM DeviceStatus WHERE ClientId = @ClientId AND Name = 'Created') AND D.DeviceLotId IS NULL
				SELECT @MinimumPoolThreshold = MinimumPoolThreshold FROM DevicePoolMetadata WHERE Id = @ID

				Print('DevicePoolMetadataId: ' + CAST( @ID as varchar(6)) + '  Total Devices Used (All Status): ' + CAST( @TotalNumberOfDevicesUsed as varchar(6)) +'  Total Devices Available: ' + CAST( @TotalNumberOfDevicesAvailable as varchar(6))+'  Minimum Pool Threshold: ' + CAST( @MinimumPoolThreshold as varchar(6)))
				--CHECK IF THE VALUES IN THE METADATA TABLE ARE CORRECT
				IF (SELECT TotalNumberOfDevicesUsed FROM DevicePoolMetadata WHERE ID = @ID) != @TotalNumberOfDevicesUsed
				BEGIN
					UPDATE DevicePoolMetadata SET TotalNumberOfDevicesUsed = @TotalNumberOfDevicesUsed WHERE ID = @ID
				END

				IF (SELECT NumberOfAvailableDevices FROM DevicePoolMetadata WHERE ID = @ID) != @TotalNumberOfDevicesAvailable
				BEGIN
					UPDATE DevicePoolMetadata SET NumberOfAvailableDevices = @TotalNumberOfDevicesAvailable WHERE ID = @ID
				END

				FETCH NEXT FROM IDs INTO @ID
			END

			CLOSE IDs
			DEALLOCATE IDs
		END
	ELSE
		BEGIN
			SELECT @TotalNumberOfDevicesUsed = COUNT(*) FROM Device AS D INNER JOIN DeviceNumberPool AS DN ON D.DeviceNumberPoolId = DN.Id WHERE DN.TemplateId IN (SELECT DeviceNumberGeneratorTemplateId FROM  DevicePoolMetadata WHERE Id = @DevicePoolMetadataId)
			SELECT @TotalNumberOfDevicesAvailable = COUNT(*) FROM Device AS D INNER JOIN DeviceNumberPool AS DN ON D.DeviceNumberPoolId = DN.Id WHERE DN.TemplateId  IN (SELECT DeviceNumberGeneratorTemplateId FROM  DevicePoolMetadata WHERE Id = @DevicePoolMetadataId)
					AND D.DeviceStatusId IN (SELECT DeviceStatusId FROM DeviceStatus WHERE ClientId = @ClientId AND Name = 'Created') AND D.DeviceLotId IS NULL

			Print('DevicePoolMetadataId: ' + CAST( @DevicePoolMetadataId as varchar(6)) + '  Total Devices Used (All Status): ' + CAST( @TotalNumberOfDevicesUsed as varchar(6)) +'  Total Devices Available: ' + CAST( @TotalNumberOfDevicesAvailable as varchar(6)))
			--CHECK IF THE VALUES IN THE METADATA TABLE ARE CORRECT
			IF (SELECT TotalNumberOfDevicesUsed FROM DevicePoolMetadata WHERE ID = @DevicePoolMetadataId) != @TotalNumberOfDevicesUsed
			BEGIN
				UPDATE DevicePoolMetadata SET TotalNumberOfDevicesUsed = @TotalNumberOfDevicesUsed WHERE ID = @DevicePoolMetadataId
			END

			IF (SELECT NumberOfAvailableDevices FROM DevicePoolMetadata WHERE ID = @DevicePoolMetadataId) != @TotalNumberOfDevicesAvailable
			BEGIN
				UPDATE DevicePoolMetadata SET NumberOfAvailableDevices = @TotalNumberOfDevicesAvailable WHERE ID = @DevicePoolMetadataId
			END
		END
	COMMIT TRANSACTION
		SELECT @Result = 1
	END TRY
	BEGIN CATCH
		PRINT ('Unable to validate device pool')
		PRINT ERROR_MESSAGE();
		ROLLBACK TRANSACTION
		
		SELECT @Result = -1
	END CATCH
END
