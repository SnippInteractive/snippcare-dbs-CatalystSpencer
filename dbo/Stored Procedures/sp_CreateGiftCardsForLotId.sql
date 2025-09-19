-- =============================================
-- Author:		Ulisses franca
-- Create date: 2014-02-05
-- Description:	this SP will create vouchers for a lot and it will change teh lot status to Activating
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateGiftCardsForLotId]
	-- Add the parameters for the stored procedure here
	@LotId INT, 
	@DeviceStatusName nvarchar(50),
	@DeviceProfileStatusName nvarchar(50)
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
	DECLARE @DeviceNumberGeneratorTemplateId INT=0;

	DECLARE @ClientId INT;


	DECLARE @NUmberDaysUntilExpire INT;
	DECLARE @GiftCardProfileId INT ;
	DECLARE @TotalNumbersToCreate INT ;

	DECLARE @GiftCardReference NVARCHAR(50) = 'GiftCardReference_' + cast(@lotid as nvarchar(8));

	select @devicelotStatusId = Id from DeviceLotStatus where ClientId = @ClientId and Name = 'Activating';

	-- date
	SELECT @Date = GETDATE();

	-- Get the Voucher Template
	select top 1 
	@GiftCardProfileId = DeviceProfileId ,
	@NUmberDaysUntilExpire = de.NumberDaysUntilExpire, 
	@SiteId = dpt.SiteId ,
	@ClientId = s.ClientId,
	@DeviceNumberGeneratorTemplateId = dpt.DeviceNumberGeneratorTemplateId,
	@CurrencyId = dpt.CurrencyId
	from DeviceLotDeviceProfile dldp join DeviceProfileTemplate dpt on dldp.DeviceProfileId=dpt.Id
	join DeviceExpirationPolicy de on de.Id=dpt.ExpirationPolicyId
	join devicelot dl on dl.Id=dldp.DeviceLotId
	join site s on s.SiteId=dpt.SiteId
	where dl.id = @LotId;
	
	print ' Create Gift card, Number Generator '+ cast(@DeviceNumberGeneratorTemplateId as nvarchar(50));

	-- numbers to create
	SELECT top 1 @TotalNumbersToCreate=dl.NumberOfDevices 
	from DeviceLot dl join DeviceLotDeviceProfile dlp on dl.Id=dlp.DeviceLotId
		where dl.Id = @LotId;

	BEGIN TRY
	-- create Numbers
	DECLARE	@return_value int;

	EXEC	@return_value = [DBHelper].[sp_CreateNumbersForDeviceNumberGeneratorTemplate]
			@TemplateId = @DeviceNumberGeneratorTemplateId,
			@TotalNumbers = @TotalNumbersToCreate,
			@ClientId = @ClientId,
			@Reference = @GiftCardReference,
			@DeviceStatusName = N'Used';

	print	'Total Numbers Created: ' + cast( @return_value as nvarchar(100));
	print @LotId;

	print @TotalNumbersToCreate ;

	EXEC	@return_value = [DBHelper].[sp_CreateDevicesFromLot]
						@DeviceLotId = @LotId,
						@ClientId = @ClientID,
						@AccountStatusName = 'Enable',
						@CurrencyId = @CurrencyId,
						@DeviceNumberPoolReference = @GiftCardReference,
						@DeviceStatus = @DeviceStatusName,
						@DeviceProfileStatus  = @DeviceProfileStatusName,
						@HomeSIteId = @SiteId,
						@DaysToAdd = @NUmberDaysUntilExpire;
						
	print cast (@return_value as nvarchar(100)) + ' Devices  Created';

	print 'End Script'
	
	Update DeviceLot
	set StatusId = @devicelotStatusId
	where Id = @LotId;
	
	END TRY
	BEGIN CATCH
		 EXECUTE usp_GetErrorInfo;
	END CATCH
	
	RETURN @return_value;
END
