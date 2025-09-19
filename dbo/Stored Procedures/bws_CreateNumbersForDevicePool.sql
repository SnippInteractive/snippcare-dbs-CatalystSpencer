
-- =============================================
-- Author:		Niall / Anish
-- Create date: 23/03/2015
-- Description:	The exist SP is slow , very slow. This is a speed up...!
--replaces [bws_CreateNumbersForDeviceNumberGeneratorTemplate]
-- =============================================
CREATE PROCEDURE [dbo].[bws_CreateNumbersForDevicePool]
	-- Add the parameters for the stored procedure here
	@ClientId INT,
	@DeviceNumberGeneratorTemplateId INT,
	@TotalNumbersToCreate int,
	@Reference nvarchar(50)=null,	
	@Result INT OUTPUT
AS
BEGIN
	Print('Generate Device Numbers For DNGT: ' + CAST( @DeviceNumberGeneratorTemplateId as varchar(6)))
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Message VARCHAR(100)
	DECLARE @Level VARCHAR(100)
	DECLARE @Stacktrace VARCHAR(MAX)
	DECLARE @Identifier VARCHAR(40)
	
	DECLARE @Prefix nvarchar(50);
	DECLARE @NumberLength int ;
	DECLARE @Suffix nvarchar(50);
	DECLARE @DeviceNumberStatusId int;
	DECLARE @CheckSumAlgorithmId int;
	DECLARE @BigString varchar(100)	

	BEGIN TRY
	BEGIN TRANSACTION

	SELECT @Identifier = cast(@ClientId as nvarchar(2)) + '_'+ cast(NEWID() as nvarchar(40)) 

	--------------------- Loggging----------------------
	SELECT @Message= 'Begin generate device numbers for device number generator template: ' + cast(@DeviceNumberGeneratorTemplateId as nvarchar(5))
	SELECT @Level= 'Info'
	SELECT @Stacktrace= ''
	INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
	--------------------- Loggging----------------------
		
	SELECT 
	@Prefix=Prefix,
	@Suffix=Suffix,
	@NumberLength=TotalNumberlength,
	@DeviceNumberStatusId = InitialDeviceNumberStatusId,
	@CheckSumAlgorithmId = CheckSumAlgorithmId
	FROM Devicenumbergeneratortemplate WHERE Id = @DeviceNumberGeneratorTemplateId AND ClientId = @ClientId

	DECLARE @TotalNumbersGenerated INT = 0;
	DECLARE @NumberSequencialRetries INT = 0;
	DECLARE @Number NVARCHAR(50);
	DECLARE @FullNumber NVARCHAR(50);
	DECLARE @CheckSum INT;
	DECLARE @UserId INT;
	-- If the number of devices to create is not specified top up the pool
	IF @TotalNumbersToCreate IS NULL
	BEGIN
		SELECT @TotalNumbersToCreate = MinimumThresholdForPool FROM Devicenumbergeneratortemplate WHERE Id = @DeviceNumberGeneratorTemplateId AND ClientId = @ClientId
		
		DECLARE @AvailableNumbers INT;
		SELECT @AvailableNumbers = AvailableNumbersInPool FROM Devicenumbergeneratortemplate WHERE Id = @DeviceNumberGeneratorTemplateId AND ClientId = @ClientId
		SELECT @TotalNumbersToCreate = @TotalNumbersToCreate - @AvailableNumbers				
	END

	IF @TotalNumbersToCreate <= 0
	BEGIN
		SELECT @TotalNumbersToCreate = 0

		--------------------- Loggging----------------------
		SELECT @Message= 'Sufficent device numbers available for device number generator template: ' + cast(@DeviceNumberGeneratorTemplateId as nvarchar(5))
		SELECT @Level= 'Info'
		SELECT @Stacktrace= ''
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
		--------------------- Loggging----------------------

	END
	
	-- Select the batch processor user for the client
	SELECT TOP 1  @UserId = UserId FROM [User] WHERE SiteId IN (SELECT SiteId FROM Site Where ClientId = @ClientId) AND Username = 'batchprocessadmin'

	-- Get length of number to create depending on length of suffix, prefix 
	-- and if a checksum is required
	IF(@CheckSumAlgorithmId IS NOT NULL)
	BEGIN
	SELECT @NumberLength = @NumberLength - 1
	END

	IF(@Prefix IS NOT NULL)
	BEGIN
	SELECT @NumberLength = @NumberLength - LEN(@Prefix)
	END

	IF(@Suffix IS NOT NULL)
	BEGIN
	SELECT @NumberLength = @NumberLength - LEN(@Suffix)
	END

	--Validate data
	IF @NumberLength <=0 
	BEGIN
		RAISERROR ('Total number lenght must be greater than 0', 0, 1 )
	END

	WHILE (@TotalNumbersGenerated < @TotalNumbersToCreate and @NumberSequencialRetries < 100)
	BEGIN
		--WAITFOR DELAY '00:00:00:010';
		BEGIN TRY
			-- Generate random number
			--SELECT @number= [dbo].[GenerateRandomNumber] (@Prefix,@Numberlength,@Suffix);
			
			
			select @BigString  = convert(varchar(20),@Prefix) + right(convert(varchar(6),rand() * 1000000) + '' +  convert(varchar(6),rand() * 1000000) + '' +  convert(varchar(6),rand() * 1000000) + '' +  convert(varchar(6),rand() * 1000000) ,@Numberlength) + convert(varchar(20),@Suffix)
			--create checksum if required 
			IF(@CheckSumAlgorithmId IS NOT NULL)
			BEGIN
				SELECT @CheckSum= [dbo].[Modulo10](@number);
				SELECT @FullNumber = ((@number) + cast(@checkSum as nvarchar(1)))
			END
			ELSE
			BEGIN
				SELECT @FullNumber = @number
			END
			
			-- Check if the number already exists in the device number pool before inserting
			IF((SELECT COUNT(*) FROM DeviceNumberPool WHERE DeviceNumber = @FullNumber) = 0)
			BEGIN			
			INSERT INTO [dbo].[DeviceNumberPool]
				   ([DeviceNumber],[TemplateId],[CheckSum],[CreatedDate],[StatusId]
				   ,[CreatedBy],[UpdatedBy],[UpdatedDate],[LotId],[Reference])
			 VALUES
				   (@FullNumber,@DeviceNumberGeneratorTemplateId,@CheckSum,Getdate(),@DeviceNumberStatusId,
				   @UserId,@UserId,Getdate(),null,@Reference);
			
			Set @TotalNumbersGenerated= @TotalNumbersGenerated +1;
			set @NumberSequencialRetries = 0;
			END
			ELSE
			BEGIN			
				SET @NumberSequencialRetries=@NumberSequencialRetries+1;
			END
		END TRY
		BEGIN CATCH
			 EXECUTE usp_GetErrorInfo;
			 SET @NumberSequencialRetries=@NumberSequencialRetries+1;
		END CATCH
	END

	EXECUTE [bws_ValidateDeviceNumberPool] @ClientId, @DeviceNumberGeneratorTemplateId, @Result

	--------------------- Loggging----------------------
	SELECT @Message= 'Succesfully generated ' + cast(@TotalNumbersToCreate as nvarchar(10)) + ' device numbers for device number generator template: ' + cast(@DeviceNumberGeneratorTemplateId as nvarchar(5))
	SELECT @Level= 'Info'
	SELECT @Stacktrace= ''
	INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)				
	--------------------- Loggging----------------------

	SELECT @Result = 1
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION

		--------------------- Loggging----------------------
		SELECT @Message= 'Unable to generate device numbers'
		SELECT @Level= 'Error'
		SELECT @Stacktrace= ERROR_MESSAGE();
		INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace);
		--------------------- Loggging----------------------

		SELECT @Result = -1
	END CATCH
END
