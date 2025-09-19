CREATE TABLE [dbo].[PromotionLoyaltyProfiles] (
    [Id]               INT IDENTITY (1, 1) NOT NULL,
    [Version]          INT CONSTRAINT [DF_PromotionLoyaltyProfiles_Version] DEFAULT ((0)) NOT NULL,
    [PromotionId]      INT NOT NULL,
    [LoyaltyProfileId] INT NOT NULL,
    CONSTRAINT [PK_PromotionLoyaltyProfiles] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_LoyaltyDeviceProfileTemplate_PromotionLoyaltyProfiles] FOREIGN KEY ([LoyaltyProfileId]) REFERENCES [dbo].[LoyaltyDeviceProfileTemplate] ([Id]),
    CONSTRAINT [FK_PromotionLoyaltyProfiles_Promotion] FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotion] ([Id]),
    CONSTRAINT [IX_Unique_Promotion_LoyaltyDeviceProfile] UNIQUE NONCLUSTERED ([PromotionId] ASC, [LoyaltyProfileId] ASC)
);

