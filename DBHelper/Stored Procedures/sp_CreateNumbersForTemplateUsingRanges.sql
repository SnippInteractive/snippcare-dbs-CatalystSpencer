

-- =============================================
-- Author:		Ulisses Franca
-- Create date: 2013-06-09
-- Description:	Generates numbers using a sequencial algorithm and no checksum digit
-- =============================================
CREATE PROCEDURE [DBHelper].[sp_CreateNumbersForTemplateUsingRanges]
	-- Add the parameters for the stored procedure here
	@TemplateId int,
	@StartSequenceNumber decimal(18,0),
	@EndSequenceNumber decimal(18,0),
	@ClientId int,
	@DeviceStatusName nvarchar(50)='Used',
	@Reference nvarchar(50)=null
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @Prefix nvarchar(50);
	declare @NUmberLength int ;
	declare @Suffix nvarchar(50);
	DECLARE @CurrentNumber decimal = 0;
	DECLARE @message nvarchar(50);
	DECLARE @TotalNumbersUsed decimal(18,0);
	DECLARE @DeviceStatusId int;
	
	IF @EndSequenceNumber <= @StartSequenceNumber 
	BEGIN
		RAISERROR ('Invalid start and end sequence', 16, 1);
	END
	

	select 
		@Prefix = Prefix,
		@suffix = Suffix,
		@NumberLength = TotalNumberlength 
	from Devicenumbergeneratortemplate where id = @templateId;
	
	select @DeviceStatusId = Id from DeviceNumberStatus where ClientId = @ClientId and Name = @DeviceStatusName;

    -- Insert statements for procedure here
    DECLARE @TotalNumbersGenerated decimal;
	SET @TotalNumbersGenerated = 0;
	DECLARE @NumberSequencialRetries decimal;
	SET @NumberSequencialRetries = 0;
	DECLARE @Number nvarchar(50);
	DECLARE @checkSum int;
	
	set @CurrentNumber = @StartSequenceNumber;
	PRINT @CurrentNumber
	PRINT @EndSequenceNumber
	WHILE (@CurrentNumber <= @EndSequenceNumber and @NumberSequencialRetries < 100)
	BEGIN
		PRINT 'START NEW'
		PRINT @CurrentNumber
		set @number = cast(@Prefix as nvarchar(20)) + cast(@CurrentNumber as nvarchar(18));
		PRINT @number
		BEGIN TRY
			INSERT INTO [dbo].[DeviceNumberPool]
				   ([DeviceNumber]
				   ,[TemplateId]
				   ,[CheckSum]
				   ,[CreatedDate]
				   ,[StatusId]
				   ,[CreatedBy]
				   ,[UpdatedBy]
				   ,[UpdatedDate]
				   ,[LotId]
				   ,[Reference])
			 VALUES
				   (@number
				   ,@TemplateId
				   ,@checkSum
				   ,Getdate()
				   ,@DeviceStatusId
				   ,(select top 1 Userid from [User])
				   ,(select top 1 Userid from [User])
				   ,Getdate()
				   ,null
				   ,@Reference);
			Set @TotalNumbersGenerated= @TotalNumbersGenerated +1;
			set @NumberSequencialRetries = 0;
			set @message = 'Number Created ' + cast(@CurrentNumber as nvarchar(18));
			set @CurrentNumber = @CurrentNumber + 1;
			PRINT 'TEST'
		END TRY
		BEGIN CATCH
			 EXECUTE usp_GetErrorInfo;
			 PRINT 'ERROR'
			 set @NumberSequencialRetries=@NumberSequencialRetries+1;
		END CATCH
	END
	PRINT 'END'
    update Devicenumbergeneratortemplate 
    set  TotalNumbersUsed = TotalNumbersUsed + @TotalNumbersGenerated,
    AvailableNUmbersInPool = AvailableNUmbersInPool + @TotalNumbersGenerated
    where id = @templateId;
    COMMIT TRANSACTION
    
	return @TotalNumbersGenerated;
END
