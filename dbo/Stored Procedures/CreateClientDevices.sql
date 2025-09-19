-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <20/09/2016>
-- Description:	<Creates new devices>
-- =============================================
CREATE PROCEDURE [dbo].[CreateClientDevices](
		@DeviceProfileTemplateName nvarchar(30),
		@VoucherSubTypeName nvarchar(50),
		@SpendRequired decimal(18,2),
		@OfferValue decimal(18,2)		
	)
AS
BEGIN
	SET NOCOUNT ON;

		Declare @siteId int;
		Declare @siteTypeId int;
		Declare @deviceProfileTemplateStatus int;
		Declare @currencyId int;
		Declare @userId int;
		Declare @deviceProfileTemplateTypeId int;
		Declare @expirationpolicyId int;
		Declare @deviceProfileTemplateId int;
		Declare @deviceNumberGeneratorTemplateStatusId int;
		Declare @checkSumAlgorithm int;
		Declare @initialDeviceNumberStatusId int;
		Declare @deviceNumberStatus int;
		Declare @deviceStatus int;
		Declare @devicelotStatus int;
		Declare @availableDevices int;
		Declare @allDevices int;
		Declare @pointCalculationTypeId INT
		Declare @ClientId int = 1;
		Declare @deviceLotId INT 
		declare @deviceNumberGeneratorTemplateId int;
		
		select @deviceLotId = dl.Id, 
			@allDevices =  count(1), 
			@availableDevices = sum(case when d.UserId is null and dptt.Name = @DeviceProfileTemplateName  then 1 else 0 end) 
		from DeviceLot dl
		join DeviceLotDeviceProfile dldp on dl.Id =  dldp.DeviceLotId
		join DeviceProfile dp on dp.DeviceProfileId = dldp.DeviceProfileId
		join DeviceProfileTemplate dpt on dpt.Id = dp.DeviceProfileId
		join DeviceProfileTemplateType dptt on dpt.DeviceProfileTemplateTypeId = dptt.Id
		join Device d on dp.DeviceId = d.Id
		join Site s on d.HomeSiteId = s.SiteId
		join SiteType st on st.SiteTypeId = s.SiteTypeId
		join DeviceLotStatus dls on dls.Id = dl.StatusId
		where st.Name = 'HeadOffice'
		and (dls.Name <> 'Inactive' or dls.Name = 'Locked')
		and dptt.Name  = @DeviceProfileTemplateName
		group by dl.Id;

		print ' Device lot ' +  convert(varchar(30), @deviceLotId)

		if NULLIF(@deviceLotId, '')  is null
			begin
				select top 1 @checkSumAlgorithm = Id from CheckSumAlgorithm where ClientId = @ClientId;
				select @deviceNumberstatus = Id from DeviceNumberstatus where ClientId = @ClientId and Name = 'Created';
				select @deviceNumberGeneratorTemplateStatusId = Id from DeviceNumberGeneratorTemplateStatus where ClientId = @ClientId;
				select @siteTypeId = SiteTypeId from SiteType where Name = 'HeadOffice' and ClientId = @ClientId;
				select @siteId = SiteId from Site where ClientId = @ClientId and SiteTypeId = @siteTypeId;
				select @deviceProfileTemplateStatus = Id from DeviceProfileTemplateStatus where ClientId = @ClientId and Name = 'Active';
				select @currencyId = Id from Currency where Code = 'USD' and ClientId = @ClientId;
				select @userId = UserId from [User] where Username = 'superuser' and SiteId = @siteId;
				select @deviceStatus = DeviceStatusId from DeviceStatus where ClientId = @ClientId and Name = 'Active';
				select @devicelotStatus = Id from DeviceLotStatus where ClientId = @ClientId and Name = 'Ready';
				select @deviceProfileTemplateTypeId = id from DeviceProfileTemplateType where ClientId = @ClientId and Name = 'Loyalty';

				select top 1 @deviceNumberGeneratorTemplateId = id from DeviceNumberGeneratorTemplate;
				print @deviceNumberGeneratorTemplateId

				if @deviceNumberGeneratorTemplateId is null
					begin
						INSERT INTO DeviceNumberGeneratorTemplate 
						(Version, CreatedBy, CreatedDate, Prefix, Suffix, TotalNumberLength, StatusId, ClientId, TotalNumbersUsed, AvailableNumbersInPool, MinimumThresholdForPool, DefaultNumberOfDevicesToCreate, UseExternal, InitialDeviceNumberStatusId, CheckSumAlgorithmId, Name, Description, NumberCreated)
						VALUES (0, @userId, GETDATE(), '1', NULL, 10, @deviceNumberGeneratorTemplateStatusId, @ClientId, 0,	0, 100,	-1,	0, @deviceNumberstatus, @checkSumAlgorithm, 'Default initial load', 'Default initial load', 0 )
						SELECT @deviceNumberGeneratorTemplateId = Scope_Identity()
						print @deviceNumberGeneratorTemplateId;
					end

				INSERT INTO DeviceProfileTemplate
				 (Version,Name,Description,SiteId,StatusId,CurrencyId,Created,Updated,IsReusable,PinRequired,IsReloadable,IsRefundable,CreatedBy,UpdatedBy,DeviceNumberGeneratorTemplateId, DeviceProfileTemplateTypeId										,CanUserChangePin,Code,ExpirationPolicyId) 
				VALUES (0, 'Default Loyalty Profile', 'This is the Default ' + @DeviceProfileTemplateName + ' Profile', @siteId, @deviceProfileTemplateStatus, @currencyId, GETDATE(), GETDATE(), 1, 0, 1, 1, @userId, @userId, @deviceNumberGeneratorTemplateId, @deviceProfileTemplateTypeId, 0 ,'CODL1',@expirationpolicyId)
				SELECT @deviceProfileTemplateId = Scope_Identity()
				print @deviceProfileTemplateId;

				SELECT @pointCalculationTypeId = Id FROM [PointsCalculationRuleType] WHERE NAME = 'NoAction' And ClientId = @ClientId
				INSERT INTO  [LoyaltyDeviceProfileTemplate] ([Id],[PointsToCashThreshold],[InstantPointsRedemption],[SpendToPointsConversionUnit],[PaymentCardBonus],[PaymentToBonusConversionUnit],[PointsCalculationRuleTypeId],[NumberHoursReservePoints],[RedeemPointsThreshold])
				VALUES (@DeviceProfileTemplateId, 0.00, 0, 1.00 ,0,null,@pointCalculationTypeId,0,NULL)
				print @pointCalculationTypeId

				insert into DeviceLot (Version, Created, Updated, CreatedBy, UpdatedBy, StatusId, NumberOfDevices, StartDate, InitialCashBalance, Name, Reference, InitialPointsBalance, ExpiryDate, DevicesAssigned, DeviceStatusId)
				VALUES 	(0, GETDATE(), GETDATE(), @userId, @userId, @devicelotStatus, 10000, GETDATE(), 0, 'Default ' + @DeviceProfileTemplateName + ' Lot', 'Default ' + @DeviceProfileTemplateName + ' Lot', 0, DATEADD(YEAR, 10, GETDATE()), 1 , @deviceStatus)
				SELECT @deviceLotId = Scope_Identity();

				print @deviceLotId;

				insert into DeviceLotDeviceProfile
				VALUES (0, @deviceLotId, @deviceProfileTemplateId);

				--update device set XXXX = @DeviceProfileTemplateName where DeviceLotId = @deviceLotId;

				if (@DeviceProfileTemplateName = 'Voucher' or @DeviceProfileTemplateName = 'FinancialVoucher')
				begin
					declare @voucherSubTypeId int;
					select @voucherSubTypeId = VoucherSubTypeId from VoucherSubType where Name = @VoucherSubTypeName;

					insert into VoucherDeviceProfileTemplate 
						(id, ClassicalVoucher, SpendRequired, VoucherSubTypeId, OfferValue)
					values (@deviceLotId, 0, @SpendRequired, @voucherSubTypeId, @OfferValue)
				end 
			end

		if (@availableDevices <= (0.1 * @allDevices)) or ((NULLIF(@allDevices, '')  is null) or (NULLIF(@availableDevices, '')  is null)) -- 10%
			exec bws_CreateDevices @ClientId, @deviceLotId, 0;

END

