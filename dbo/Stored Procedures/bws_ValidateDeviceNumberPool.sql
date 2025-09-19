-- =============================================
-- Author:		Neil McAuliffe
-- Create date: 27/06/2014
-- Description:	Validates the device number pools, if no device number generator Id is passed in then all pools are validated
-- =============================================
CREATE PROCEDURE [dbo].[bws_ValidateDeviceNumberPool]
	-- Add the parameters for the stored procedure here
	@ClientId INT,
	@DeviceNumberGeneratorTemplateId INT = -1,
	@Result INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
	DECLARE @TotalNumberOfDeviceNumbersUsed INT
	DECLARE @TotalNumberOfDeviceNumbersAvailable INT
	DECLARE @MinimumPoolThreshold INT
	
	BEGIN TRY
	BEGIN TRANSACTION
	IF @DeviceNumberGeneratorTemplateId < 0 
		BEGIN
			DECLARE @ID int
			DECLARE IDs CURSOR LOCAL FOR SELECT Id FROM DeviceNumberGeneratorTemplate WHERE ClientId = @ClientId

			OPEN IDs
			FETCH NEXT FROM IDs INTO @ID
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @TotalNumberOfDeviceNumbersUsed = COUNT(*) FROM DeviceNumberPool WHERE TemplateId = @ID
				SELECT @TotalNumberOfDeviceNumbersAvailable = COUNT(*) FROM DeviceNumberPool WHERE TemplateId = @ID AND StatusId IN (SELECT ID FROM DeviceNumberStatus WHERE ClientId = @ClientId AND Name = 'Created')
				SELECT @MinimumPoolThreshold = MinimumThresholdForPool FROM DeviceNumberGeneratorTemplate WHERE Id = @ID

				--CHECK IF THE VALUES IN THE METADATA TABLE ARE CORRECT
				Print('DeviceNumberGeneratorId: ' + CAST( @DeviceNumberGeneratorTemplateId as varchar(6)) + '  Total Numbers Used (All Status): ' + CAST( @TotalNumberOfDeviceNumbersUsed as varchar(6)) +'  Total Numbers Available: ' + CAST( @TotalNumberOfDeviceNumbersAvailable as varchar(6))+'  Minimum Pool Threshold: ' + CAST( @MinimumPoolThreshold as varchar(6)))

				IF (SELECT TotalNumbersUsed FROM DeviceNumberGeneratorTemplate WHERE ID = @ID) != @TotalNumberOfDeviceNumbersUsed
				BEGIN
					UPDATE DeviceNumberGeneratorTemplate SET TotalNumbersUsed = @TotalNumberOfDeviceNumbersUsed WHERE ID = @ID
				END

				IF (SELECT AvailableNumbersInPool FROM DeviceNumberGeneratorTemplate WHERE ID = @ID) != @TotalNumberOfDeviceNumbersAvailable
				BEGIN
					UPDATE DeviceNumberGeneratorTemplate SET AvailableNumbersInPool = @TotalNumberOfDeviceNumbersAvailable WHERE ID = @ID
				END

				FETCH NEXT FROM IDs INTO @ID
			END

			CLOSE IDs
			DEALLOCATE IDs
		END
	ELSE
		BEGIN
			SELECT @TotalNumberOfDeviceNumbersUsed = COUNT(*) FROM DeviceNumberPool WHERE TemplateId = @DeviceNumberGeneratorTemplateId
			SELECT @TotalNumberOfDeviceNumbersAvailable = COUNT(*) FROM DeviceNumberPool WHERE TemplateId = @DeviceNumberGeneratorTemplateId AND StatusId IN (SELECT ID FROM DeviceNumberStatus WHERE ClientId = @ClientId AND Name = 'Created')
			
		    --Print('DeviceNumberGeneratorId: ' + CAST( @DeviceNumberGeneratorTemplateId as varchar(6)) + '  Total Numbers Used (All Status): ' + CAST( @TotalNumberOfDeviceNumbersUsed as varchar(6)) +'  Total Numbers Available: ' + CAST( @TotalNumberOfDeviceNumbersAvailable as varchar(6)))
			--CHECK IF THE VALUES IN THE METADATA TABLE ARE CORRECT
			IF (SELECT TotalNumbersUsed FROM DeviceNumberGeneratorTemplate WHERE ID = @DeviceNumberGeneratorTemplateId) != @TotalNumberOfDeviceNumbersUsed
			BEGIN
				UPDATE DeviceNumberGeneratorTemplate SET TotalNumbersUsed = @TotalNumberOfDeviceNumbersUsed WHERE ID = @DeviceNumberGeneratorTemplateId
			END

			IF (SELECT AvailableNumbersInPool FROM DeviceNumberGeneratorTemplate WHERE ID = @DeviceNumberGeneratorTemplateId) != @TotalNumberOfDeviceNumbersAvailable
			BEGIN
				UPDATE DeviceNumberGeneratorTemplate SET AvailableNumbersInPool = @TotalNumberOfDeviceNumbersAvailable WHERE ID = @DeviceNumberGeneratorTemplateId
			END
		END

		SELECT @Result = 1
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION		
		SELECT @Result = -1
	END CATCH
END
