CREATE TABLE [dbo].[PromotionRedemptionCount] (
    [Id]                 INT            IDENTITY (1, 1) NOT NULL,
    [MemberId]           INT            NULL,
    [PromotionId]        INT            NULL,
    [LastRedemptionDate] DATETIME       NULL,
    [TrxId]              INT            NULL,
    [ItemCode]           NVARCHAR (150) NULL,
    CONSTRAINT [PK_PromotionRedemptionCount] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_TrxId]
    ON [dbo].[PromotionRedemptionCount]([TrxId] ASC);

