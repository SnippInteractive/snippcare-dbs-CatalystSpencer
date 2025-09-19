CREATE TABLE [dbo].[LoyaltyDeviceProfileTemplate] (
    [Id]                                   INT             NOT NULL,
    [PointsToCashThreshold]                DECIMAL (18, 2) NULL,
    [InstantPointsRedemption]              BIT             CONSTRAINT [DF_LoyaltyDeviceProfile_InstantRedemption] DEFAULT ((0)) NOT NULL,
    [SpendToPointsConversionUnit]          DECIMAL (18, 3) NULL,
    [PaymentCardBonus]                     BIT             CONSTRAINT [DF_LoyaltyDeviceProfileTemplate_PaymentCardBonus] DEFAULT ((0)) NOT NULL,
    [PaymentToBonusConversionUnit]         DECIMAL (18, 2) NULL,
    [PointsCalculationRuleTypeId]          INT             NOT NULL,
    [NumberHoursReservePoints]             INT             NULL,
    [RedeemPointsThreshold]                DECIMAL (18, 2) NULL,
    [DeviceMustBeRegisteredToRedeemPoints] BIT             NOT NULL,
    [LineItemsMaxPointsValue]              DECIMAL (18, 2) NULL,
    [IsTier]                               BIT             CONSTRAINT [DF_LoyaltyDeviceProfileTemplate_IsTier] DEFAULT ((0)) NULL,
    [BasketMaxPointsValue]                 DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_LoyaltyDeviceProfile] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CK_LoyaltyDeviceProfileTemplate_SpendToPointsConversionUnit] CHECK ([SpendToPointsConversionUnit]>(-1)),
    CONSTRAINT [FK_DeviceProfile_LoyaltyDeviceProfile] FOREIGN KEY ([Id]) REFERENCES [dbo].[DeviceProfileTemplate] ([Id]),
    CONSTRAINT [FK_LoyaltyDeviceProfileTemplate_PointsCalculationRuleType] FOREIGN KEY ([PointsCalculationRuleTypeId]) REFERENCES [dbo].[PointsCalculationRuleType] ([Id])
);

