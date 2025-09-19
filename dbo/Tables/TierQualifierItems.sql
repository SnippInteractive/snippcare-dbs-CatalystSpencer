CREATE TABLE [dbo].[TierQualifierItems] (
    [Id]                 INT          IDENTITY (1, 1) NOT NULL,
    [Version]            INT          NOT NULL,
    [TierId]             INT          NOT NULL,
    [TrxTypeId]          INT          NULL,
    [ActivityCategoryId] INT          NULL,
    [GroupId]            INT          NULL,
    [MinimumPoints]      DECIMAL (18) NULL,
    CONSTRAINT [PK_TierQualifierItems] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_TierQualifierItems_ActivityCategory] FOREIGN KEY ([ActivityCategoryId]) REFERENCES [dbo].[ActivityCategory] ([Id]),
    CONSTRAINT [FK_TierQualifierItems_PromotionItemGroup] FOREIGN KEY ([GroupId]) REFERENCES [dbo].[PromotionItemGroup] ([Id]),
    CONSTRAINT [FK_TierQualifierItems_TierAdmin] FOREIGN KEY ([TierId]) REFERENCES [dbo].[TierAdmin] ([Id]),
    CONSTRAINT [FK_TierQualifierItems_TrxType] FOREIGN KEY ([TrxTypeId]) REFERENCES [dbo].[TrxType] ([TrxTypeId])
);

