-- =============================================
-- Author:		Ulisses franca
-- Create date: 2014-02-05
-- Description:	this SP will create vouchers for a lot and it will change teh lot status to Activating
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateVouchersForLotId]
	-- Add the parameters for the stored procedure here
	@LotId INT, 
	@DeviceNumberGeneratorTemplateId INT,
	@ClientName nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SiteId INT;
	DECLARE @ProfileStatusId INT;
	DECLARE @CurrencyId INT;
	DECLARE @Date DATETIME;
	DECLARE @UserId INT;
	Declare @devicelotStatusId int;

	DECLARE @ClientId INT;


	DECLARE @NUmberDaysUntilExpire INT;
	DECLARE @VoucherDeviceProfileTemplateId INT ;
	DECLARE @TotalNumbersToCreate INT ;

	DECLARE @VouchersReference NVARCHAR(50) = 'VoucherReference' + cast(@lotid as nvarchar(8));

	select @devicelotStatusId = Id from DeviceLotStatus where ClientId = @ClientId and Name = 'Activating';

	-- client
	SELECT @ClientId = ClientId FROM dbo.Client WHERE Name = @ClientName;

	-- date
	SELECT @Date = GETDATE();

	-- Get the Voucher Template
	select top 1 @VoucherDeviceProfileTemplateId = DeviceProfileId 
	from DeviceLotDeviceProfile dp where dp.DeviceLotId = @LotId;

	-- number Days to add
	select @NUmberDaysUntilExpire = de.NumberDaysUntilExpire, @SiteId = t.SiteId from DeviceExpirationPolicy de join DeviceProfileTemplate t on de.Id=t.ExpirationPolicyId
	where t.Id = @VoucherDeviceProfileTemplateId;

	-- numbers to create
	SELECT top 1 @TotalNumbersToCreate=dl.NumberOfDevices from DeviceLot dl join DeviceLotDeviceProfile dlp on dl.Id=dlp.DeviceLotId
		where dl.Id = @LotId;

	BEGIN TRANSACTION
	BEGIN TRY
	-- create Numbers
	DECLARE	@return_value int;

	EXEC	@return_value = [DBHelper].[sp_CreateNumbersForDeviceNumberGeneratorTemplate]
			@TemplateId = @DeviceNumberGeneratorTemplateId,
			@TotalNumbers = @TotalNumbersToCreate,
			@ClientId = @ClientId,
			@Reference = @VouchersReference,
			@DeviceStatusName = N'Used',
			@UseCheckSum = 0

	print	'Total Numbers Created: ' + cast( @return_value as nvarchar(100));
	print @LotId;

	print @TotalNumbersToCreate ;

	EXEC	@return_value = [DBHelper].[sp_CreateDevicesFromLot]
						@DeviceLotId = @LotId,
						@ClientId = @ClientID,
						@AccountStatusName = 'Enable',
						--@CurrencyId = @CurrencyId,
						@DeviceNumberPoolReference = @VouchersReference,
						@DeviceStatus = 'Active',
						@DeviceProfileStatus  = 'Active',
						@HomeSIteId = @SiteId,
						@DaysToAdd = @NUmberDaysUntilExpire;
						
	print cast (@return_value as nvarchar(100)) + ' Created';

	print 'End Script'
	
	Update DeviceLot
	set StatusId = @devicelotStatusId
	where Id = @LotId;

	COMMIT TRANSACTION
	
	END TRY
	BEGIN CATCH
		 EXECUTE usp_GetErrorInfo;
		 ROLLBACK TRANSACTION;
	END CATCH
	
	RETURN @return_value;
END
