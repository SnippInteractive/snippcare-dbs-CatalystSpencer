
-- =============================================
-- Author:		Ulisses Franca
-- Create date: 2013-06-06
-- Description:	To Create a Financial Device Profile
-- =============================================
CREATE PROCEDURE [DBHelper].[sp_CreateFinancialProfile]
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
	@IsGiftCard bit,
	@NumberHoursReserveAmount decimal,
	@MinBalance decimal,
	@MaxBalance decimal,
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
          (select Id from DeviceProfileTemplateType where Name = 'Financial'));
          
select @ProfileId = SCOPE_IDENTITY();

INSERT INTO [dbo].[FinancialDeviceProfileTemplate]
           ([Id]
           ,[IsGiftCard]
           ,[AllowsAmountToBeReserved]
           ,[NumberHoursToReserveAmount]
           ,[MinBalance]
           ,[MaxBalance])
     VALUES
           (@ProfileId
           ,@IsGiftCard
           ,ISNULL(@NumberHoursReserveAmount,0)
           ,@NumberHoursReserveAmount
           ,@MinBalance
           ,@MaxBalance);
           SET IDENTITY_INSERT [dbo].DeviceProfileTemplate OFF;
           return @ProfileId;
	
END
