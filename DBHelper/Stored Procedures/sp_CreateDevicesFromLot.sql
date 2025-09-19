-- =============================================
-- Author:		Ulisses Franca
-- Create date: 2013-11-07
-- Description:	This SP Created devices from a lot
-- =============================================
CREATE PROCEDURE [DBHelper].[sp_CreateDevicesFromLot]
	@DeviceLotId INT,
	@ClientId INT,
	@AccountStatusName NVARCHAR(50),
	@CurrencyId INT,
	@DeviceNumberPoolReference NVARCHAR(50),
	@DeviceStatus NVARCHAR(50),
	@DeviceProfileStatus NVARCHAR(50),
	@HomeSIteId INT,
	@DaysToAdd INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @AccountStatusId INT;
	DECLARE @CashBalance float;
	DECLARE @PointsBalance float;
	DECLARE @DeviceStatusId INT;
	DECLARE @DeviceProfileStatusId INT;
	DECLARE @deviceTypeId INT;
	
	Select @AccountStatusId = AccountStatusId from AccountStatus where ClientId = @ClientId and Name = @AccountStatusName;
	Select @CashBalance = InitialCashBalance,@PointsBalance=InitialPointsBalance from DeviceLot where id = @DeviceLotId;
	select @DeviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @ClientId AND Name = @DeviceStatus;
	select @DeviceProfileStatusId = DeviceProfileStatusId from DeviceProfileStatus where ClientId = @ClientId AND Name = @DeviceProfileStatus;
	SELECT @deviceTypeId = DeviceTypeId from DeviceType where Name = 'Card' and ClientId = @ClientId;

	INSERT INTO [dbo].[Account]
           ([AccountStatusTypeId]
           ,[Pin]
           ,[ProgramId]
           ,[PointsPending]
           ,[CreateDate]
           ,[Version_old]
           ,[MonetaryBalance]
           ,[PointsBalance]
           ,[CurrencyId]
           ,[ExtRef])
   select 
			@AccountStatusId,
			NULL,
			NULL,
			0,
			GETDATE(),
			NULL,
			@CashBalance,
			@PointsBalance,
			@CurrencyId,
			DeviceNumber
	from DeviceNumberPool where Reference = @DeviceNumberPoolReference;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[Device]
           ([DeviceId]
           ,[DeviceStatusId]
           ,[DeviceTypeId]
           ,[HomeSiteId]
           ,[CreateDate]
           ,[DeviceNumberPoolId]
           ,[ExpirationDate]
           ,[AccountId]
           ,[StartDate]
           ,[DevicelotId])
    select dp.DeviceNumber,
			@DeviceStatusId,
			@deviceTypeId,
			@HomeSIteId,
			GETDATE(),
			DP.Id,
			dateadd(day,@DaysToAdd,GETDATE()),
			A.AccountId,
			GETDATE(),
			@DeviceLotId
		from DeviceNumberPool  dp join Account a on dp.DeviceNumber = a.ExtRef
		where  Reference = @DeviceNumberPoolReference;
    
    INSERT INTO [dbo].[DeviceProfile]
           ([StatusId]
           ,[DeviceId]
           ,[DeviceProfileId])
     select
		Distinct
		@DeviceProfileStatusId,
		d.Id,
		dlp.DeviceProfileId
		from Device d join DeviceLot dl on d.DeviceLotId = dl.Id
			JOIN DeviceLotDeviceProfile dlp on dlp.DeviceLotId = dl.Id
			where dl.Id = @DeviceLotId;
END
