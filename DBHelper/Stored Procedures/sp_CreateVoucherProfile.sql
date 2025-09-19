

-- =============================================
-- Author:		Ulisses Franca
-- Create date: 2013-06-06
-- Description:	To Create a Voucher Device Profile
-- =============================================
CREATE PROCEDURE [DBHelper].[sp_CreateVoucherProfile]
	-- Add the parameters for the stored procedure here
	@Name nvarchar(50), 
	@Description nvarchar(MAX),
	@SiteId int,
	@CurrencyId int,
	@UserId int,
	@StatusId nvarchar(10),
	@Reusable bit,
	@PinRequired bit,
	@Reloadable bit,
	@Refundable bit,
	@ChargeFeeId int,
	@ExpirationPolicyId int,
	@DeviceNumberGeneratorTemplateId int,
	@PinRegex nvarchar(10),
	@ProfileId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET IDENTITY_INSERT [dbo].DeviceProfileTemplate ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[DeviceProfileTemplate]
           (Id,[Name]
           ,[Description]
           ,[SiteId]
           ,[StatusId]
           ,[CurrencyId]
           ,[Created]
           ,[Updated]
           ,[IsReusable]
           ,[PinRequired]
           ,[IsReloadable]
           ,[IsRefundable]
           ,[ChargeFeeId]
           ,[CreatedBy]
           ,[UpdatedBy]
           ,[ParentId]
           ,[DeviceNumberGeneratorTemplateId]
           ,[ExternalDeviceNumberGeneratorReference]
           ,[DeviceLotDefaultsId]
           ,[PinValidationRegularEx]
           ,[ExpirationPolicyId]
           ,[DeviceProfileTemplateTypeId])
     VALUES
           (@ProfileId,@Name,
           @description,
           @SiteId,
           (select Id from DeviceProfileTemplateStatus where Name = @StatusId),
           @CurrencyId,
           GETDATE(),
           GETDATE(),
           @Reusable,
           @PinRequired,
           @Reloadable,
           @Refundable,
           @ChargeFeeId,
          @UserId,
            @UserId,
           NULL,
           @DeviceNumberGeneratorTemplateId,
           NUll,
           NUll,
          @PinRegex,
          @ExpirationPolicyId,
          (select Id from DeviceProfileTemplateType where Name = 'Voucher'));
          
select @ProfileId = SCOPE_IDENTITY();

INSERT INTO [dbo].[VoucherDeviceProfileTemplate]
           ([Id]
           ,[OfferValue]
           ,[ClassicalVoucher]
           ,[SpendRequired]
           ,[UseWithOthers]
           ,[StartTime]
           ,[EndTime]
           ,[UseSameType]
           ,[UseSameSubType]
           ,[DaysEnabled]
           ,[MisCode]
           ,[VoucherSubTypeId])
     VALUES
           (@ProfileId
           ,10
           ,1
           ,100
           ,123
           ,NULL
           ,NULL
           ,1
           ,1
           ,NULL
           ,NULL
           ,(select top 1 VoucherSubTypeId from VoucherSubType));
           
           SET IDENTITY_INSERT [dbo].DeviceProfileTemplate OFF;
           return @ProfileId;
	
END
