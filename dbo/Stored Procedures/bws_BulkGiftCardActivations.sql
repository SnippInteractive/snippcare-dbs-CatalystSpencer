-- =============================================
-- Author:		Neil McAuliffe
-- Create date: 27/06/2014
-- Description:	Bulk activates gift cards for the specified number of devices
-- =============================================
CREATE PROCEDURE [dbo].[bws_BulkGiftCardActivations]
	-- Add the parameters for the stored procedure here
	@ClientId INT,
	@BulkActivationId INT,
	@Result INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION
			
	-- Logging Variables
	DECLARE @Message VARCHAR(100)
	DECLARE @Level VARCHAR(100)
	DECLARE @Stacktrace VARCHAR(MAX)
	DECLARE @Identifier VARCHAR(40)
	
	SELECT @Identifier = cast(@ClientId as nvarchar(2)) + '_'+ cast(NEWID() as nvarchar(40)) 
	
	--------------------- Loggging----------------------
	SELECT @Message= 'Begin bulk activation of devices for activation job: ' + cast(@BulkActivationId as nvarchar(5)) + ' ClientId: '+ cast(@ClientId as nvarchar(5))
	SELECT @Level= 'Info'
	SELECT @Stacktrace= ''
	INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
	--------------------- Loggging----------------------
	
	-- Procedure Variables
	DECLARE @StartingDevice VARCHAR(50)
	DECLARE @EndDevice VARCHAR(50)
	DECLARE @ActivationDate DATETIME
	DECLARE @LoadAmount MONEY
	DECLARE @Currency VARCHAR(3)
	DECLARE @SiteId INT
	DECLARE @Count INT
	DECLARE @ReserveFlag UNIQUEIDENTIFIER
	DECLARE @StartDate DATETIME
	DECLARE @ExpiryDate DATETIME
	DECLARE @DeviceLotId INT
	DECLARE @SearchByCardNumber INT
	DECLARE @BatchLoadUser INT
	DECLARE @Reference VARCHAR(50)
	DECLARE @InitialCashBalanceId INT
	
	-- Select required fields from bulk activation table
	SELECT 
	@StartingDevice=StartingDevice,
	@EndDevice=EndDevice,
	@ActivationDate=ActivationDate,
	@LoadAmount=LoadAmount,
	@Currency=Currency,
	@SiteId=SiteId,
	@Count=[Count],
	@ReserveFlag=ReserveFlag,
	@StartDate=StartDate,
	@ExpiryDate=ExpiryDate,
	@SearchByCardNumber=SearchByCardNumber,
	@Reference=Reference,
	@BatchLoadUser = CreatedBy
	FROM BulkGiftCardActivations 
	WHERE 
	[Status] IN (SELECT Id FROM BulkGiftCardActivationsStatus WHERE Name = 'Created' And ClientId = @ClientId)
	AND BulkActivationId = @BulkActivationId

	SELECT @DeviceLotId = DeviceLotId FROM Device WHERE LotSequenceNo = @StartingDevice
	
	SELECT @InitialCashBalanceId = TrxTypeId FROM TrxType WHERE Name = 'InitialCashBalanceSet' AND ClientId = @ClientId
	
	-- Update status of the bulk activation job
	UPDATE BulkGiftCardActivations SET [Status] = (SELECT TOP 1 ID FROM BulkGiftCardActivationsStatus WHERE NAME IN ('Started') AND ClientId = @ClientId)
	WHERE BulkActivationId = @BulkActivationId
		
	-- Select a block of devices and perform basic validaition
	IF OBJECT_ID('tempdb..#BulkActivationDevices') IS NOT NULL
	BEGIN
		DROP TABLE #BulkActivationDevices
	END

	-- Check If the Lot Id for the start and end device are the same
	PRINT('01: Check if lot ids are the same for both devices')
	IF((SELECT DeviceLotId FROM Device WHERE Id = @StartingDevice) != (SELECT DeviceLotId FROM Device WHERE Id = @StartingDevice))
	BEGIN
		BEGIN TRANSACTION
		UPDATE BulkGiftCardActivations SET [Status] = (SELECT TOP 1 ID FROM BulkGiftCardActivationsStatus WHERE NAME IN ('Error') AND ClientId = @ClientId)
		WHERE BulkActivationId = @BulkActivationId
		--------------------- Loggging----------------------
		SELECT @Message= 'Bulk activation error activation job: ' + cast(@BulkActivationId as nvarchar(5)) + 'Device Lot Id is different for the start and end device' 
		SELECT @Level= 'Error'
		SELECT @Stacktrace= ''
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
		--------------------- Loggging----------------------
		COMMIT TRANSACTION
		RAISERROR (@Message, 0, 1 )
	END
	
	--Check if there is enough devices in the lot with a status of ready
	SELECT * INTO #BulkActivationDevices from Device where (1=0)
	SET IDENTITY_INSERT #BulkActivationDevices ON
	
	PRINT('02: Select the required devices based on the search criteria')
	IF(@SearchByCardNumber = 1)
	BEGIN
		INSERT INTO #BulkActivationDevices ([Id],[DeviceId] ,[Version] ,[DeviceStatusId] ,[DeviceTypeId] ,[UserId] ,[HomeSiteId] ,[CreateDate] ,[Owner] ,[Reference] ,[EmbossLine1] ,[EmbossLine2] ,[EmbossLine3] ,[EmbossLine4] ,[EmbossLine5] ,[Pin] ,[DeviceNumberPoolId] ,[ExpirationDate] ,[AccountId] ,[StartDate] ,[PinFailedAttempts] ,[DeviceLotId] ,[ExtraInfo] ,[LotSequenceNo])
		SELECT [Id],[DeviceId] ,[Version] ,[DeviceStatusId] ,[DeviceTypeId] ,[UserId] ,[HomeSiteId] ,[CreateDate] ,[Owner] ,[Reference] ,[EmbossLine1] ,[EmbossLine2] ,[EmbossLine3] ,[EmbossLine4] ,[EmbossLine5] ,[Pin] ,[DeviceNumberPoolId] ,[ExpirationDate] ,[AccountId] ,[StartDate] ,[PinFailedAttempts] ,[DeviceLotId] ,[ExtraInfo] ,[LotSequenceNo]  
		FROM Device 
		WHERE DeviceId >= @StartingDevice AND DeviceId <= @EndDevice 
		AND DeviceLotId = @DeviceLotId 
		AND DeviceStatusId = (SELECT TOP (1) DeviceStatusId FROM DeviceStatus WHERE Name = 'Ready' AND ClientId = @ClientId)
	END
	ELSE
	BEGIN
		INSERT INTO #BulkActivationDevices ([Id],[DeviceId] ,[Version] ,[DeviceStatusId] ,[DeviceTypeId] ,[UserId] ,[HomeSiteId] ,[CreateDate] ,[Owner] ,[Reference] ,[EmbossLine1] ,[EmbossLine2] ,[EmbossLine3] ,[EmbossLine4] ,[EmbossLine5] ,[Pin] ,[DeviceNumberPoolId] ,[ExpirationDate] ,[AccountId] ,[StartDate] ,[PinFailedAttempts] ,[DeviceLotId] ,[ExtraInfo] ,[LotSequenceNo])
		SELECT [Id],[DeviceId] ,[Version] ,[DeviceStatusId] ,[DeviceTypeId] ,[UserId] ,[HomeSiteId] ,[CreateDate] ,[Owner] ,[Reference] ,[EmbossLine1] ,[EmbossLine2] ,[EmbossLine3] ,[EmbossLine4] ,[EmbossLine5] ,[Pin] ,[DeviceNumberPoolId] ,[ExpirationDate] ,[AccountId] ,[StartDate] ,[PinFailedAttempts] ,[DeviceLotId] ,[ExtraInfo] ,[LotSequenceNo] 
		FROM Device 
		WHERE LotSequenceNo >= @StartingDevice  AND LotSequenceNo <= @EndDevice 
		AND DeviceLotId = @DeviceLotId 
		AND DeviceStatusId = (SELECT TOP (1) DeviceStatusId FROM DeviceStatus WHERE Name = 'Ready' AND ClientId = @ClientId)
	END
	
	PRINT('03: Validate the count for the devices')
	IF(@Count != (SELECT COUNT (*) FROM #BulkActivationDevices))
	BEGIN
		--------------------- Loggging----------------------
		SELECT @Message= 'Bulk activation error activation job: ' + cast(@BulkActivationId as nvarchar(5)) + 'The number of devices in a ready state for the lot between the 2 device Ids is not equal to the required amount' 
		SELECT @Level= 'Error'
		SELECT @Stacktrace= ''
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
		--------------------- Loggging----------------------
		RAISERROR (@Message, 1, 1 )
	END		
	
	-- Update the account balance of all devices
	UPDATE Account SET MonetaryBalance =MonetaryBalance+@LoadAmount WHERE AccountId IN (Select AccountId From #BulkActivationDevices)
		
	-- Update the device status
	UPDATE Device SET 
		DeviceStatusId = (SELECT TOP (1) DeviceStatusId FROM DeviceStatus WHERE Name = 'Active' AND ClientId = @ClientId),
		StartDate = @StartDate,
		ExpirationDate = @ExpiryDate,
		Reference = @Reference
	WHERE Id IN (Select Id From #BulkActivationDevices)

	-- Update the device profile link status to active
	UPDATE DeviceProfile SET StatusId = (SELECT TOP (1) DeviceProfileStatusId FROM DeviceProfileStatus WHERE Name = 'Active' AND ClientId = @ClientId) WHERE DeviceId IN (Select Id From #BulkActivationDevices)
	
	DECLARE @DeviceStatusId INT
	SELECT TOP (1) @DeviceStatusId = DeviceStatusId FROM DeviceStatus WHERE Name = 'Active' AND ClientId = @ClientId
	
	DECLARE @DeviceTransitionTypeId INT
	SELECT TOP (1) @DeviceTransitionTypeId = DeviceStatusTransitionTypeId FROM DeviceStatusTransitionType WHERE Name = 'Automatic' AND ClientId = @ClientId
	
	DECLARE @ActionId INT
	SELECT TOP (1)  @ActionId = DeviceActionId FROM DeviceAction WHERE Name = 'Activation' AND ClientId = @ClientId

	-- INSERT INTO DEVICE STATUS HISTORY
	INSERT INTO DeviceStatusHistory ([DeviceId] ,[DeviceStatusId] ,[ChangeDate] ,[Reason] ,[DeviceStatusTransitionType] ,[ExtraInfo] ,[UserId] ,[ActionId] ,[DeviceTypeResult] ,[ActionResult] ,[ActionDetail] ,[OldValue] ,[NewValue] ,[SiteId] ,[Processed] ,[DeviceIdentity] ,[OpId] ,[TerminalId])
	SELECT DeviceId, @DeviceStatusId, GETDATE(),'Bulk activation of giftcards',@DeviceTransitionTypeId,'',@BatchLoadUser,@ActionId,'MainCard',0,'Bulk Activate',0,@LoadAmount,@SiteId,1,Id,NULL,NULL
	FROM #BulkActivationDevices
		
	DECLARE @TrxTypeId INT
	SELECT TOP (1)  @TrxTypeId = TrxTypeId FROM TrxType WHERE Name = 'Activation' AND ClientId = @ClientId
	
	DECLARE @TrxStatusId INT
	SELECT TOP (1)  @TrxStatusId = TrxStatusId FROM TrxStatus WHERE Name = 'Completed' AND ClientId = @ClientId

	DECLARE @TrxDate DATETIME
	SELECT @TrxDate = GETDATE()
	
	PRINT('04: Validate no transactions exist for the selected devices')
	--IF( (SELECT COUNT(*) FROM TrxHeader WHERE TrxTypeId <> @InitialCashBalanceId and DeviceId IN (SELECT DeviceId FROM #BulkActivationDevices ) ) > 0)
	
	IF EXISTS(SELECT 1 FROM TrxHeader WHERE TrxTypeId <> @InitialCashBalanceId and DeviceId IN (SELECT DeviceId FROM #BulkActivationDevices ) )
	BEGIN	
		UPDATE BulkGiftCardActivations SET [Status] = (SELECT TOP 1 ID FROM BulkGiftCardActivationsStatus WHERE NAME IN ('Error') AND ClientId = @ClientId)
		WHERE BulkActivationId = @BulkActivationId
		--------------------- Loggging----------------------
		SELECT @Message= 'Bulk activation error activation job: ' + cast(@BulkActivationId as nvarchar(5)) + 'Transactions already exist for the selected devices' 
		SELECT @Level= 'Error'
		SELECT @Stacktrace= ''
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
		--------------------- Loggging----------------------
		RAISERROR (@Message, 0, 1 )
	END
	ELSE
	BEGIN	
	PRINT('05: Create the transactions for the devices')
	INSERT INTO  TrxHeader (DeviceId,TrxTypeId,TrxDate,ClientId,SiteId,Reference,TrxStatusTypeId,CreateDate,DeviceIdentity,TrxCommitDate,TerminalId,TerminalDescription,AccountCashBalance,AccountPointsBalance)
	SELECT DeviceId,@TrxTypeId,CAST(@TrxDate AS DATETIMEOFFSET),@ClientId,@SiteId,convert(nvarchar(MAX), @TrxDate, 127),@TrxStatusId,@TrxDate,Id,@TrxDate,'','Internal',@LoadAmount,0 from #BulkActivationDevices
		
	INSERT INTO TrxDetail(trxid,LineNumber,Description,Quantity,Value,Points,HomeCurrencyCode,[Version])
	SELECT th.TrxId,1,'Bulk Activation',1,@LoadAmount,0,@Currency,0 FROM TrxHeader AS th
    INNER JOIN #BulkActivationDevices AS bad on th.DeviceId=bad.DeviceId
	WHERE  th.Reference = convert(nvarchar(MAX), @TrxDate, 127)	

	UPDATE BulkGiftCardActivations SET [Status] = (SELECT TOP 1 ID FROM BulkGiftCardActivationsStatus WHERE NAME IN ('Completed') AND ClientId = @ClientId)
	WHERE BulkActivationId = @BulkActivationId		
	
	UPDATE TrxHeader SET Reference = '' WHERE Reference = convert(nvarchar(MAX), @TrxDate, 127)
	
	END
	
	IF OBJECT_ID('tempdb..#BulkActivationDevices') IS NOT NULL
	BEGIN
		DROP TABLE #BulkActivationDevices
	END
	COMMIT TRANSACTION

	SELECT @Result = 1
	SELECT @Message= 'Complete bulk activation of devices for activation job: ' + cast(@BulkActivationId as nvarchar(5)) + ' ClientId: '+ cast(@ClientId as nvarchar(5))
	Select @Result As Result, @Message AS [Message]

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		IF OBJECT_ID('tempdb..#BulkActivationDevices') IS NOT NULL
		BEGIN
			DROP TABLE #BulkActivationDevices
		END

		--------------------- Loggging----------------------
		SELECT @Message= 'Error bulk activation of devices for activation job: ' + cast(@BulkActivationId as nvarchar(10)) + ' ClientId: '+ cast(@ClientId as nvarchar(5))
		SELECT @Level= 'Error'
		SELECT @Stacktrace = ERROR_MESSAGE();
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace);
		--------------------- Loggging----------------------
				
		SELECT @Result = -1

		Select @Result As Result, @Message AS [Message]
	END CATCH
END
