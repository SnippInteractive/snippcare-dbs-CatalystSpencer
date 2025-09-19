-- =============================================
-- Author:		Ulisses Franca
-- Create date: 2014-02-06
-- Description:	Creates devices for a specif device profile template
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateDevicesForProfile]
	-- Add the parameters for the stored procedure here
	@DeviceProfileTemplateId INT, 
	@NumberOfDevices INT ,
	@UserID INT,
	@ClientId INT,
	@StartDate Datetime2,
	@InitialCashBalance INT,
	@InitialPointsBalance INT,
	@deviceStatus nvarchar(50),
	@deviceProfileStatus nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Name nvarchar(50);
	DECLARE @DeviceLotId int;
	DECLARE @DeviceNUmberGeneratorTemplate INT;
	DECLARE @HomeSiteId INT;
	DECLARE @NUmberDaysToAdd INT;
	DECLARE @DeviceExpirationPolicy INT;
	select @Name = 'LOTTEst'+ cast(@DeviceProfileTemplateId AS NVARCHAR(50)) + CAST(GETDATE() AS NVARCHAR(50));
	select @DeviceNUmberGeneratorTemplate = DeviceNumberGeneratorTemplateId,
		@HomeSiteId = SiteId,
		@DeviceExpirationPolicy = ExpirationPolicyId
	 from DeviceProfileTemplate where Id = @DeviceProfileTemplateId;
	 
	 SELECT @NUmberDaysToAdd = [NumberDaysUntilExpire] from DeviceExpirationPolicy where id = @DeviceExpirationPolicy;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[DeviceLot]
           ([Created]
           ,[Updated]
           ,[CreatedBy]
           ,[UpdatedBy]
           ,[StatusId]
           ,[NumberOfDevices]
           ,[StartDate]
           ,[InitialCashBalance]
           ,[Name]
           ,[Reference]
           ,[InitialPointsBalance])
     VALUES
           (GETDATE()
           ,GetDate()
           ,@UserID
           ,@UserId
           ,(select Id from DeviceLotStatus where ClientId = @ClientId and Name = 'Locked')
           ,@NumberOfDevices
           ,@StartDate
           ,@InitialCashBalance
           ,@nAME
           ,@name
           ,@InitialPointsBalance);
           
     select @DeviceLotId = SCOPE_IDENTITY();
           
     INSERT INTO [dbo].[DeviceLotDeviceProfile]
           ([DeviceLotId]
           ,[DeviceProfileId])
     VALUES
           (@DeviceLotId 
           ,@DeviceProfileTemplateId);
           
     -- lets create numbers
     EXEC [DBHelper].[sp_CreateNumbersForDeviceNumberGeneratorTemplate]
				-- Add the parameters for the stored procedure here
				@TemplateId = @DeviceNUmberGeneratorTemplate,
				@TotalNumbers = @NumberOfDevices,
				@ClientId = @ClientId,
				@Reference =@Name,
				@DeviceStatusName ='Used';
				
	-- LEts Create Devices
	 EXEC [DBHelper].[sp_CreateDevicesFromLot]
			@DeviceLotId = @DeviceLotId,
			@ClientId = @ClientId,
			@AccountStatusName = 'Enable',
			@CurrencyId = NULL,
			@DeviceNumberPoolReference = @Name,
			@DeviceStatus = @deviceStatus,
			@DeviceProfileStatus = @deviceProfileStatus,
			@HomeSIteId = @HomeSiteId,
			@DaysToAdd = @NUmberDaysToAdd;
END
