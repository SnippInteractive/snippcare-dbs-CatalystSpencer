CREATE TABLE [dbo].[PromotionMemberProfileItem] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [Version]             INT           NOT NULL,
    [PromotionId]         INT           NOT NULL,
    [PromotionCategoryId] INT           NOT NULL,
    [ItemId]              INT           NOT NULL,
    [ItemName]            NVARCHAR (50) NULL,
    [ClientId]            INT           NOT NULL,
    [ItemValue]           INT           NULL,
    CONSTRAINT [PK__PromotionMemberProfileItem] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK__PromotionMemberProfileItem__Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK__PromotionMemberProfileItem__PromotionCategoryId] FOREIGN KEY ([PromotionCategoryId]) REFERENCES [dbo].[PromotionCategory] ([Id]),
    CONSTRAINT [FK__PromotionMemberProfileItem__PromotionId] FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotion] ([Id])
);

