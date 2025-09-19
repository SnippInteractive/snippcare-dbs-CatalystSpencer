
-- =============================================
-- Author:		Neil McAuliffe
-- Create date: 27/06/2014
-- Description:	Assigns Devices to a specified lot
-- =============================================
CREATE PROCEDURE [dbo].[bws_AssignDevicesToLot]
	-- Add the parameters for the stored procedure here
	@ClientId INT,
	@LotId INT,
	@Result INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
				
	-- Logging Variables
	DECLARE @Message VARCHAR(100)
	DECLARE @Level VARCHAR(100)
	DECLARE @Stacktrace VARCHAR(MAX)
	DECLARE @Identifier VARCHAR(40)
	
	SELECT @Identifier = cast(@ClientId as nvarchar(2)) + '_'+ cast(NEWID() as nvarchar(40)) 

	--------------------- Loggging----------------------
	SELECT @Message= 'Begin assign devices to lot for LotId: ' + cast(@LotId as nvarchar(5)) + ' ClientId: '+ cast(@ClientId as nvarchar(5))
	SELECT @Level= 'Info'
	SELECT @Stacktrace= ''
	INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
	--------------------- Loggging----------------------
	
	-- Procedure Variables
	DECLARE @ProcessLot INT = 1

	DECLARE @NumberOfDevices INT
	DECLARE @StartDate DATETIME
	DECLARE @InitialCashBalance DECIMAL
	DECLARE @InitialPointsBalance DECIMAL
	DECLARE @ExpiryDate DATETIME
	DECLARE @DeviceStatusId INT
	DECLARE @DeviceReference NVARCHAR(500)

	DECLARE @DeviceProfileTemplateId INT
	DECLARE @DeviceProfileStatusId INT
	DECLARE @DeviceNumberGeneratorTemplateId INT
	DECLARE @CurrencyId INT
	DECLARE @DeviceProfileTemplateTypeId INT
	DECLARE @SiteId INT
	DECLARE @Description NVARCHAR(500)

	DECLARE @NumberOfAvailableDevices INT
	DECLARE @DevicePoolMetadataId INT

	--Read Lot details
	SELECT 	 
		@NumberOfDevices = NumberOfDevices,
		@StartDate = StartDate,
		@InitialCashBalance = InitialCashBalance,
		@InitialPointsBalance = InitialPointsBalance,
		@ExpiryDate = ExpiryDate,
		@DeviceStatusId = DeviceStatusId 
	FROM DeviceLot WHERE Id = @LotId

	PRINT('01 @NumberOfDevices: ' + CONVERT(NVARCHAR(50), @NumberOfDevices))
	PRINT('02 @StartDate: ' + CONVERT(NVARCHAR(50), @StartDate))
	PRINT('03 @InitialCashBalance: ' + CONVERT(NVARCHAR(50), @InitialCashBalance))
	PRINT('04 @InitialPointsBalance: ' + CONVERT(NVARCHAR(50), @InitialPointsBalance))
	PRINT('05 @ExpiryDate: ' + CONVERT(NVARCHAR(50), @ExpiryDate))
	PRINT('06 @DeviceStatusId: ' + CONVERT(NVARCHAR(50), @DeviceStatusId))

	--Read device lot profile template
	SELECT
		@DeviceProfileTemplateId = DPT.Id,
		@DeviceNumberGeneratorTemplateId = DeviceNumberGeneratorTemplateId,
		@CurrencyId = CurrencyId,
		@DeviceProfileTemplateTypeId = DeviceProfileTemplateTypeId,
		@SiteId = SiteId,
		@Description = [Description]
	FROM DeviceProfileTemplate AS DPT 
	INNER JOIN DeviceLotDeviceProfile AS DLDP ON DPT.Id = DLDP.DeviceProfileId
	WHERE DLDP.DeviceLotId = @LotId
	
	
	PRINT('07 @DeviceProfileTemplateId: ' + CONVERT(NVARCHAR(50), @DeviceProfileTemplateId))
	PRINT('08 @DeviceNumberGeneratorTemplateId: ' + CONVERT(NVARCHAR(50), @DeviceNumberGeneratorTemplateId))
	PRINT('09 @CurrencyId: ' + CONVERT(NVARCHAR(50), @CurrencyId))
	PRINT('10 @DeviceProfileTemplateTypeId: ' + CONVERT(NVARCHAR(50), @DeviceProfileTemplateTypeId))
	PRINT('11 @SiteId: ' + CONVERT(NVARCHAR(50), @SiteId))
	PRINT('12 @Description: ' + CONVERT(NVARCHAR(50), @Description))

	--Read device pool metadata
	SELECT
		@DevicePoolMetadataId = Id
	FROM DevicePoolMetadata 
	WHERE DeviceNumberGeneratorTemplateId = @DeviceNumberGeneratorTemplateId
		
	PRINT('13 @DevicePoolMetadataId: ' + CONVERT(NVARCHAR(50), @DevicePoolMetadataId))
		
	-- Validate the device pools to ensure that all values are up to date
	EXEC bws_ValidateDevicePool @ClientId, @DevicePoolMetaDataId, @Result

	SELECT
		@NumberOfAvailableDevices = NumberOfAvailableDevices
	FROM DevicePoolMetadata 
	WHERE DeviceNumberGeneratorTemplateId = @DeviceNumberGeneratorTemplateId
	PRINT('14 @NumberOfAvailableDevices: ' + CONVERT(NVARCHAR(50), @NumberOfAvailableDevices))
	
	--Check if there are devices assigned to the lot
	IF((SELECT COUNT(*) FROM Device WHERE DeviceLotId = @LotId) > 0)
	BEGIN
		--------------------- Loggging----------------------
		SELECT @Message= 'Error assign devices to lot for LotId: ' + cast(@LotId as nvarchar(5)) + ' ClientId: '+ cast(@ClientId as nvarchar(5)) + ' There are already devices assigned to the lot.'
		SELECT @Stacktrace= ERROR_MESSAGE();
		PRINT '90006'
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace);
		--------------------- Loggging----------------------
		
		SELECT @ProcessLot = 0
		
		RAISERROR (@Message, 0, 1 )
	END

	--Check if there are enough devices available in the pool for the lot if not generate the numbers

	IF(@NumberOfAvailableDevices < @NumberOfDevices)
	BEGIN
		DECLARE @NumberToCreate INT = @NumberOfDevices - @NumberOfAvailableDevices
		EXEC bws_CreateDevicesForDevicePoolMetadata @ClientId, @DevicePoolMetadataId, @NumberToCreate, NULL, @Result

		IF(@Result = 0)
		BEGIN
			--------------------- Loggging----------------------
			SELECT @Message= 'Error assign devices to lot for LotId: ' + cast(@LotId as nvarchar(5)) + ' ClientId: '+ cast(@ClientId as nvarchar(5)) + ' Unable to generate enough devices for the lot.'
			SELECT @Level= 'Error'
			SELECT @Stacktrace= ERROR_MESSAGE();
			PRINT '90007'
			INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace);
			--------------------- Loggging----------------------
		
			SELECT @ProcessLot = 0
		
			RAISERROR (@Message, 0, 1 )
		END
	END
	
	IF(@ProcessLot = 1)
	BEGIN
		--If the lot profile currency is null set if to USD
		IF(@CurrencyId IS NULL)
		BEGIN
			SELECT @CurrencyId = Id FROM Currency WHERE Code = 'USD' AND ClientId = @ClientId
		END
				
		--Read Lot Profile Type and set variables accordingly
		DECLARE @StatusName NVARCHAR(20)
		SELECT @StatusName = Name FROM DeviceStatus WHERE DeviceStatusId  = @DeviceStatusId  AND ClientId = @ClientId

		IF(@StatusName = 'Ready' OR @StatusName = 'Created')
		BEGIN
			SELECT @DeviceProfileStatusId = DeviceProfileStatusId FROM DeviceProfileStatus WHERE Name = 'Created' AND ClientId = @ClientId
		END

		IF(@StatusName = 'Active')
		BEGIN
			SELECT @DeviceProfileStatusId = DeviceProfileStatusId FROM DeviceProfileStatus WHERE Name = 'Active' AND ClientId = @ClientId
		END
		
		IF(@DeviceProfileTemplateTypeId IN (SELECT Id FROM DeviceProfileTemplateType WHERE Name = 'Voucher' AND ClientId = @ClientId))
		BEGIN
			SELECT @DeviceReference = @Description
		END
		
		IF OBJECT_ID('tempdb..#AssignDevicesToLot') IS NOT NULL
		BEGIN
			DROP TABLE #AssignDevicesToLot
		END
				
		SELECT * INTO #AssignDevicesToLot from Device where (1=0)
		SET IDENTITY_INSERT #AssignDevicesToLot ON
		INSERT INTO #AssignDevicesToLot ([Id],[DeviceId] ,[Version] ,[DeviceStatusId] ,[DeviceTypeId] ,[UserId] ,[HomeSiteId] ,[CreateDate] ,[Owner] ,[Reference] ,[EmbossLine1] ,[EmbossLine2] ,[EmbossLine3] ,[EmbossLine4] ,[EmbossLine5] ,[Pin] ,[DeviceNumberPoolId] ,[ExpirationDate] ,[AccountId] ,[StartDate] ,[PinFailedAttempts] ,[DeviceLotId] ,[ExtraInfo] ,[LotSequenceNo])
		SELECT TOP (@NumberOfDevices) D.* FROM Device AS D
		INNER JOIN DeviceNumberPool AS DN ON DN.Id = D.DeviceNumberPoolId
		WHERE DN.TemplateID = @DeviceNumberGeneratorTemplateId
		AND D.DeviceStatusId IN (SELECT DeviceStatusId FROM DeviceStatus AS DS WHERE Name = 'Created' AND ClientId = @ClientId)
		AND D.DeviceLotId IS NULL
		

		DECLARE @count_dev INT
		SELECT @count_dev = COUNT (*) FROM #AssignDevicesToLot

		IF(@count_dev < @NumberOfDevices)
		BEGIN
			--------------------- Loggging----------------------
			SELECT @Message= 'Error assign devices to lot for LotId: ' + cast(@LotId as nvarchar(5)) + ' ClientId: '+ cast(@ClientId as nvarchar(5)) + ' No devices selected for assign devices to lot.'
			SELECT @Level= 'Error'
			SELECT @Stacktrace= ERROR_MESSAGE();
			PRINT '90008'
			INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace);
			--------------------- Loggging----------------------
		
			RAISERROR (@Message, 0, 1 )
		END

		BEGIN TRANSACTION
			UPDATE Device SET
				DeviceLotId = @LotId,
				ExpirationDate = @ExpiryDate,
				HomeSiteId = @SiteId,
				StartDate = @StartDate,
				Reference = @LotId, --@DeviceReference, change by niall to allow the linking o the report for export of vouchers.
				DeviceStatusId = @DeviceStatusId
			WHERE Id IN (SELECT Id FROM #AssignDevicesToLot)

			UPDATE Account SET
				MonetaryBalance = @InitialCashBalance,
				PointsBalance = @InitialPointsBalance,
				CurrencyId = @CurrencyId
			WHERE AccountId IN (SELECT AccountId FROM #AssignDevicesToLot)

			INSERT INTO DeviceProfile (StatusId, DeviceId, DeviceProfileId)
			SELECT @DeviceProfileStatusId, Id, @DeviceProfileTemplateId 
			FROM #AssignDevicesToLot
						
			--If monetary balance or points balance > 0 create a transaction
			DECLARE @TrxTypeId INT
			SELECT TOP (1)  @TrxTypeId = TrxTypeId FROM TrxType WHERE Name = 'InitialCashBalanceSet' AND ClientId = @ClientId
	
			DECLARE @TrxStatusId INT
			SELECT TOP (1)  @TrxStatusId = TrxStatusId FROM TrxStatus WHERE Name = 'Completed' AND ClientId = @ClientId

			DECLARE @TrxDate DATETIME
			SELECT @TrxDate = GETDATE()
			
			DECLARE @CurrencyCode NVARCHAR(5)
			SELECT @CurrencyCode = Code  FROM Currency WHERE Id= @CurrencyId				

			IF(@InitialCashBalance > 0)
			BEGIN
				INSERT INTO  TrxHeader (DeviceId,TrxTypeId,TrxDate,ClientId,SiteId,Reference,TrxStatusTypeId,CreateDate,DeviceIdentity,TrxCommitDate,TerminalId,TerminalDescription,AccountCashBalance,AccountPointsBalance)
				SELECT DeviceId,@TrxTypeId,CAST(@TrxDate AS DATETIMEOFFSET),@ClientId,@SiteId,'Initial Cash Balance set',@TrxStatusId,@TrxDate,Id,@TrxDate,(SELECT @@SERVERNAME),'Internal',@InitialCashBalance,0 from #AssignDevicesToLot
		
				INSERT INTO TrxDetail(trxid,LineNumber,Description,Quantity,Value,Points, HomeCurrencyCode)
				SELECT th.TrxId,1,'Initial Cash Balance set',1,@InitialCashBalance,0, @CurrencyCode FROM TrxHeader AS th
				INNER JOIN #AssignDevicesToLot AS ADL on th.DeviceId=ADL.DeviceId
				WHERE  th.Reference = 'Initial Cash Balance set'
			END
			
			SELECT TOP (1)  @TrxTypeId = TrxTypeId FROM TrxType WHERE Name = 'InitialPointsBalanceSet' AND ClientId = @ClientId

			IF(@InitialPointsBalance > 0)
			BEGIN
				INSERT INTO  TrxHeader (DeviceId,TrxTypeId,TrxDate,ClientId,SiteId,Reference,TrxStatusTypeId,CreateDate,DeviceIdentity,TrxCommitDate,TerminalId,TerminalDescription,AccountCashBalance,AccountPointsBalance)
				SELECT DeviceId,@TrxTypeId,CAST(@TrxDate AS DATETIMEOFFSET),@ClientId,@SiteId,'Initial Points Balance set',@TrxStatusId,@TrxDate,Id,@TrxDate,(SELECT @@SERVERNAME),'Internal',0,@InitialPointsBalance from #AssignDevicesToLot
				
				
				INSERT INTO TrxDetail(trxid,LineNumber,Description,Quantity,Value,Points, HomeCurrencyCode)
				SELECT th.TrxId,1,'Initial Points Balance set',1,0,@InitialPointsBalance, @CurrencyCode FROM TrxHeader AS th
				INNER JOIN #AssignDevicesToLot AS ADL on th.DeviceId=ADL.DeviceId
				WHERE  th.Reference = 'Initial Points Balance set'
			END
			
			--Create sequence number for the lot
			DECLARE @LotSequenceNumber NVARCHAR(4)
			DECLARE @DeviceSequenceNumberCounter INT = 1
			DECLARE @DeviceSequenceNumber NVARCHAR(5)

			SELECT @LotSequenceNumber= REPLACE(STR(@LotId, 4), SPACE(1), '0')
						
			DECLARE @DevicesCounter INT
			SELECT @DevicesCounter = COUNT(*) FROM Device WHERE DeviceLotId = @LotId

			BEGIN
				DECLARE @ID int
				DECLARE IDs CURSOR LOCAL FOR  SELECT Id FROM Device WHERE DeviceLotId = @LotId
				OPEN IDs
				FETCH NEXT FROM IDs INTO @ID
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SELECT @DeviceSequenceNumber = REPLACE(STR(@DeviceSequenceNumberCounter, 5), SPACE(1), '0')
					UPDATE Device SET LotSequenceNo = @LotSequenceNumber+@DeviceSequenceNumber WHERE Id = @ID

					SELECT @DeviceSequenceNumberCounter = @DeviceSequenceNumberCounter + 1
					FETCH NEXT FROM IDs INTO @ID
				END

				CLOSE IDs
				DEALLOCATE IDs
			END	
			
			-- Update the status of the lot
			DECLARE @NewLotStatus INT
			SELECT @NewLotStatus = Id FROM DeviceLotStatus WHERE Name = 'NumbersAssigned' AND ClientId = @ClientId
			UPDATE DeviceLot SET DevicesAssigned = 1, StatusId = @NewLotStatus WHERE ID = @LotId

			-- Validate the device pools to ensure that all values are up to date
			EXEC bws_ValidateDevicePool @ClientId, @DevicePoolMetaDataId, @Result

		COMMIT TRANSACTION
	END
	
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END
		--------------------- Loggging----------------------
		SELECT @Message= ERROR_MESSAGE()
		SELECT @Level= 'Error'
		SELECT @Stacktrace= ERROR_MESSAGE();
		print @message
		PRINT '90009'
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace);
		--------------------- Loggging----------------------
				
		SELECT @Result = -1

		Select @Result As Result, @Message AS [Message]
		print '90010'
	END CATCH
END
