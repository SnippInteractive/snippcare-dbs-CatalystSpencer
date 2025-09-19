CREATE TABLE [dbo].[RewardItemsOptions] (
    [RewardItemOptionId]            INT            IDENTITY (1, 1) NOT NULL,
    [OptionId]                      INT            NULL,
    [RewardItemId]                  INT            NOT NULL,
    [RewardItemOptionName]          NVARCHAR (500) NULL,
    [SupplierRewardOptionReference] NVARCHAR (20)  NULL,
    [RewardCostPrice]               DECIMAL (18)   NULL,
    [RewardPointsValue]             INT            NULL,
    [RewardCurrency]                INT            NULL,
    [QuantityAvailable]             INT            NULL,
    [QuantityRedeemed]              INT            NULL,
    [Attributes]                    NVARCHAR (MAX) NULL,
    [Tags]                          NVARCHAR (MAX) NULL,
    [SmallImageURL]                 NVARCHAR (MAX) NULL,
    [MediumImageURL]                NVARCHAR (MAX) NULL,
    [LargeImageURL]                 NVARCHAR (MAX) NULL,
    [Enabled]                       BIT            NULL,
    [CreatedDate]                   DATETIME       NULL,
    [LastUpdatedDate]               DATETIME       NULL,
    CONSTRAINT [PK_RewardItemsOptions] PRIMARY KEY CLUSTERED ([RewardItemOptionId] ASC),
    CONSTRAINT [FK_RewardItemsOptions_RewardItems] FOREIGN KEY ([RewardItemId]) REFERENCES [dbo].[RewardItems] ([RewardItemId])
);

