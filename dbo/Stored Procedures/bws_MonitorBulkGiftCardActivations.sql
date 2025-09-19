
-- =============================================
-- Author:		Neil McAuliffe
-- Create date: 27/06/2014
-- Description:	Monitors the bulk giftcard activation table and activates cards if required
-- NOTE: No logging is required for this procedure as it will reun at a high frequency, logging is pushed into the bulk activation procedure
-- =============================================
CREATE PROCEDURE [dbo].[bws_MonitorBulkGiftCardActivations]
	-- Add the parameters for the stored procedure here
	@ClientId INT,
	@Result INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
		
	DECLARE @Message VARCHAR(100)
	DECLARE @Level VARCHAR(100)
	DECLARE @Stacktrace VARCHAR(MAX)
	DECLARE @Identifier VARCHAR(40)
	
	SELECT @Identifier = cast(@ClientId as nvarchar(2)) + '_'+ cast(NEWID() as nvarchar(40)) 

	IF OBJECT_ID('tempdb..#BulkActivation') IS NOT NULL
	BEGIN
		DROP TABLE #BulkActivation
	END

	SELECT * INTO #BulkActivation FROM BulkGiftCardActivations WHERE [Status] IN (SELECT ID FROM BulkGiftCardActivationsStatus WHERE NAME IN ('Error', 'Created') AND ClientId = @ClientId) AND [Count] < 3 

	BEGIN TRANSACTION
		UPDATE BulkGiftCardActivations SET [Status] = (SELECT TOP 1 ID FROM BulkGiftCardActivationsStatus WHERE NAME IN ('Started') AND ClientId = @ClientId)
	COMMIT TRANSACTION
	
	IF((SELECT COUNT (*) FROM #BulkActivation) > 0)
	BEGIN
		BEGIN
			DECLARE @ID int
			DECLARE IDs CURSOR LOCAL FOR SELECT BulkActivationId FROM #BulkActivation

			OPEN IDs
			FETCH NEXT FROM IDs INTO @ID
			WHILE @@FETCH_STATUS = 0
			BEGIN
				--CHECK IF THE VALUES IN THE METADATA TABLE ARE CORRECT
				Print('Begin bulk activate: ' + CAST( @ID as varchar(6)))
				exec bws_BulkGiftCardActivations @ClientId, @ID, @Result
				--CALL BULK ACTIVATE HERE
				FETCH NEXT FROM IDs INTO @ID
			END

			CLOSE IDs
			DEALLOCATE IDs
		END
	END
	ELSE
	BEGIN
		SELECT @Result = 1
		SELECT @Message= 'No bulk gift card activations required: ' + cast(@ClientId as nvarchar(5))
		SELECT @Result As Result, @Message AS [Message]
	END

	IF OBJECT_ID('tempdb..#BulkActivation') IS NOT NULL
	BEGIN
		DROP TABLE #BulkActivation
	END

	SELECT @Result = 1
	SELECT @Message= 'Complete monitoring bulk activations for client: ' + cast(@ClientId as nvarchar(5))	
	Select @Result As Result, @Message AS [Message]

	END TRY
	BEGIN CATCH

		IF OBJECT_ID('tempdb..#BulkActivation') IS NOT NULL
		BEGIN
			DROP TABLE #BulkActivation
		END

		--------------------- Loggging----------------------
		SELECT @Message= 'Error monitoring bulk activations for client: ' + cast(@ClientId as nvarchar(5))
		SELECT @Level= 'Error'
		SELECT @Stacktrace= ERROR_MESSAGE();
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace);
		--------------------- Loggging----------------------
				
		SELECT @Result = -1

		Select @Result As Result, @Message AS [Message]
	END CATCH
END
