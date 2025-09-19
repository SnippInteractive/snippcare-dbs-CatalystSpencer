CREATE TABLE [dbo].[FinancialDeviceProfileTemplate] (
    [Id]                            INT             NOT NULL,
    [IsGiftCard]                    BIT             CONSTRAINT [DF_FinancialVoucherDeviceProfile_IsGiftCard] DEFAULT ((0)) NOT NULL,
    [AllowsAmountToBeReserved]      BIT             NOT NULL,
    [NumberHoursToReserveAmount]    INT             NULL,
    [MinBalance]                    DECIMAL (18, 2) NULL,
    [MaxBalance]                    DECIMAL (18, 2) NULL,
    [ReCalculateExpiryDateOnReload] BIT             DEFAULT ((0)) NOT NULL,
    [ApplyToAllBrands]              BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_FinancialVoucherDeviceProfile] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceProfileTemplate_FinancialDeviceProfile] FOREIGN KEY ([Id]) REFERENCES [dbo].[DeviceProfileTemplate] ([Id])
);

