
-- =============================================
-- Author:		Ulisses Franca
-- Create date: 2013-06-06
-- Description:	creates a Device number generator
-- =============================================
CREATE PROCEDURE [DBHelper].[sp_CreateDeviceNumberGenerator]
	-- Add the parameters for the stored procedure here
	@UserId int,
	@Prefix nvarchar(10),
	@Suffix nvarchar(10)=null,
	@TotalNumberLength int,
	@TemplateStatusName nvarchar(50),
	@ClientId int,
	@ChecksumAlgorithmName nvarchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @TemplateId INT;
	DECLARE @DeviceNUmberStatusId INT;
	select @DeviceNUmberStatusId = Id from DeviceNumberStatus where ClientId = @ClientId and Name = 'Used'; 
	
    -- Insert statements for procedure here
	INSERT INTO [dbo].[DeviceNumberGeneratorTemplate]
           ([CreatedBy]
           ,[CreatedDate]
           ,[Prefix]
           ,[Suffix]
           ,[TotalNumberLength]
           ,[StatusId] 
           ,[ClientId]
           ,[TotalNumbersUsed]
           ,[AvailableNumbersInPool]
           ,[MinimumThresholdForPool]
           ,[DefaultNumberOfDevicesToCreate]
           ,[UseExternal],[InitialDeviceNumberStatusId])
     VALUES
           (@UserId
           ,Getdate()
           ,@Prefix
           ,@suffix
           ,@TotalNumberLength
           ,(select id from DeviceNumberGeneratorTemplateStatus where Name=@TemplateStatusName and ClientId = @ClientId) 
           ,@ClientId
           ,0
             ,POWER(10.0, cast(@TotalNumberLength as decimal))
           ,10
           ,200
           ,0
           ,@DeviceNUmberStatusId);
select @TemplateId = SCOPE_IDENTITY();
return @TemplateId;
END
