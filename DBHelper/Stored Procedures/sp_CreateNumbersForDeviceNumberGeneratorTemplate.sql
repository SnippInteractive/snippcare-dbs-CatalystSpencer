

-- =============================================
-- Author:		Ulisses Franca
-- Create date: 2013-06-09
-- Description:	Generates numbers for 
-- =============================================
CREATE PROCEDURE [DBHelper].[sp_CreateNumbersForDeviceNumberGeneratorTemplate]
	-- Add the parameters for the stored procedure here
	@TemplateId int,
	@TotalNumbers decimal,
	@ClientId int,
	@Reference nvarchar(50)=null,
	@DeviceStatusName nvarchar(50)='Used'
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @Prefix nvarchar(50);
	declare @NUmberLength int ;
	declare @Suffix nvarchar(50);
	DECLARE @DeviceNumberStatusId nvarchar(50);

	select 
		@Prefix=Prefix,
		@suffix=Suffix,
		@NumberLength=TotalNumberlength 
	from Devicenumbergeneratortemplate where id = @templateId;
	
	select @DeviceNumberStatusId = Id from DeviceNumberStatus where ClientId = @ClientId and Name = @DeviceStatusName;

    -- Insert statements for procedure here
    DECLARE @TotalNumbersGenerated decimal;
	SET @TotalNumbersGenerated = 0;
	DECLARE @NumberSequencialRetries decimal;
	SET @NumberSequencialRetries = 0;
	DECLARE @Number nvarchar(50);
	DECLARE @checkSum int;
	WHILE (@TotalNumbersGenerated < @TotalNumbers and @NumberSequencialRetries < 100)
	BEGIN
		 WAITFOR DELAY '00:00:00:010';
		BEGIN TRY
			SELECT @number= [dbo].[GenerateRandomNumber] (@Prefix,@Numberlength,@Suffix);
			select @checkSum= [dbo].[Modulo10](@number);
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
				   (
				   (@number) + cast(@checkSum as nvarchar(1))
				   ,@TemplateId
				   ,@checkSum
				   ,Getdate()
				   ,@DeviceNumberStatusId
				   ,(select top 1 Userid from [User])
				   ,(select top 1 Userid from [User])
				   ,Getdate()
				   ,null
				   ,@Reference);
			Set @TotalNumbersGenerated= @TotalNumbersGenerated +1;
			set @NumberSequencialRetries = 0;
		END TRY
		BEGIN CATCH
			 EXECUTE usp_GetErrorInfo;
			 set @NumberSequencialRetries=@NumberSequencialRetries+1;
		END CATCH
	END
    update Devicenumbergeneratortemplate 
    set     TotalNUmbersused = TotalNUmbersused + @TotalNumbersGenerated,
    AvailableNUmbersInPool = AvailableNUmbersInPool + @TotalNumbersGenerated
    where id = @templateId;
    COMMIT TRANSACTION
    
	return @TotalNumbersGenerated;
END
