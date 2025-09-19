-- =============================================
-- Author:		Neil McAuliffe
-- Create date: 27/06/2014
-- Description:	Monitors all device lots for a client call assign devices to lot when required
-- Note: No logging due to the frequency this can run, logging is handled in the child procedure
-- =============================================
CREATE PROCEDURE [dbo].[bws_MonitorDeviceLots]
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
	
	
	BEGIN TRY

	SELECT @Identifier = cast(@ClientId as nvarchar(2)) + '_'+ cast(NEWID() as nvarchar(40)) 


	BEGIN
		DECLARE @ID int
		DECLARE IDs CURSOR LOCAL FOR  SELECT DL.Id FROM DeviceLot AS DL 
									  INNER JOIN DeviceLotDeviceProfile AS DLDP ON DL.Id = DLDP.DeviceLotId 
									  INNER JOIN DeviceProfileTemplate AS DPT ON DLDP.DeviceProfileId = DPT.ID 
									  WHERE 
									  DPT.SiteId IN (SELECT SiteId FROM [Site] WHERE ClientId = @ClientId) AND 
									  DL.DevicesAssigned = 0

		OPEN IDs
		FETCH NEXT FROM IDs INTO @ID
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC bws_AssignDevicesToLot @ClientId, @ID, @Result		

			FETCH NEXT FROM IDs INTO @ID
		END

		CLOSE IDs
		DEALLOCATE IDs
	END	

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		BEGIN TRANSACTION
		--------------------- Loggging----------------------
		SELECT @Message= 'Unable to monitor device lots for client: ' + cast(@ClientId as nvarchar(5))
		SELECT @Level= 'Error'
		SELECT @Stacktrace= ERROR_MESSAGE();
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace);
		--------------------- Loggging----------------------
		COMMIT TRANSACTION

		SELECT @Result = -1

		Select @Result As Result, @Message AS [Message]
	END CATCH
END
