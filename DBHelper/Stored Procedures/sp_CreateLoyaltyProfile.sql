

-- =============================================
-- Author:		Ulisses Franca
-- Create date: 2013-06-06
-- Description:	To Create a Voucher Device Profile
-- =============================================
CREATE PROCEDURE [DBHelper].[sp_CreateLoyaltyProfile]
	-- Add the parameters for the stored procedure here
	@Name nvarchar(50), 
	@Description nvarchar(MAX),
	@ClientId int,
	@SiteId int,
	@CurrencyId int,
	@UserId int,
	@StatusId nvarchar(10),
	@NumberDaysToExpire int,
	@DeviceNumberGeneratorTemplateId int,
	@SpendToPointsConversionUnit decimal(18,2),
	@PointsCalculationRuleTypeName nvarchar(50),
	@PointsToCashThreshold decimal(18,2),
	@RedeemPointsThreshold decimal(18,2),
	@NumberHoursReservePoints decimal(18,2),
	@InstantPointsRedeemption decimal(18,2),
	@Code nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ExpirationPolicyTypeId INT;
	DECLARE @ExpirationPolicyId INT;
	DECLARE @ProfileId INT ;
	
	select @ExpirationPolicyTypeId = Id from DeviceExpirationPolicyType where ClientId = @ClientId and Name = 'Fixed';
	
	-- insert expiration policy
	INSERT INTO [dbo].[DeviceExpirationPolicy]
           ([ExpirationPolicyTypeId]
           ,[NumberDaysUntilExpire])
     VALUES
           (@ExpirationPolicyTypeId
           ,@NumberDaysToExpire);
           
     select @ExpirationPolicyId = SCOPE_IDENTITY();
	

    -- Insert statements for procedure here
	INSERT INTO [dbo].[DeviceProfileTemplate]
           ([Name]
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
           ,[DeviceProfileTemplateTypeId]
           ,Code)
     VALUES
           (@Name,
           @description,
           @SiteId,
           (select Id from DeviceProfileTemplateStatus where Name = @StatusId and ClientId = @ClientId),
           @CurrencyId,
           GETDATE(),
           GETDATE(),
           0,
           0,
           0,
           0,
           Null,
          @UserId,
            @UserId,
           NULL,
           @DeviceNumberGeneratorTemplateId,
           NUll,
           NUll,
          NUll,
          @ExpirationPolicyId,
          (select Id from DeviceProfileTemplateType where Name = 'Loyalty' and ClientId = @ClientId),
          @Code);
          
select @ProfileId = SCOPE_IDENTITY();

INSERT INTO [dbo].[LoyaltyDeviceProfileTemplate]
           ([Id]
           ,[PointsToCashThreshold]
           ,[InstantPointsRedemption]
           ,[SpendToPointsConversionUnit]
           ,[PaymentCardBonus]
           ,[PaymentToBonusConversionUnit]
           ,[PointsCalculationRuleTypeId]
           ,[NumberHoursReservePoints]
           ,[RedeemPointsThreshold])
     VALUES
           (@ProfileId
           ,@PointsToCashThreshold
           ,@InstantPointsRedeemption
           ,@SpendToPointsConversionUnit
           ,0
           ,null
           ,(select Id from PointsCalculationRuleType where ClientId = @ClientId and Name = @PointsCalculationRuleTypeName)
           ,@NumberHoursReservePoints
           ,@RedeemPointsThreshold);
           
           return @ProfileId;
	
END
