CREATE TABLE [dbo].[PromotionItem] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [Version]              INT            CONSTRAINT [DF__PromotionItem_Version] DEFAULT ((0)) NOT NULL,
    [PromotionId]          INT            NOT NULL,
    [PromotionItemTypeId]  INT            NOT NULL,
    [Code]                 NVARCHAR (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [FilterType]           INT            NULL,
    [Quantity]             INT            NULL,
    [ItemIncludeExclude]   NVARCHAR (25)  NULL,
    [PromotionItemGroupId] INT            NULL,
    [LogicalAnd]           BIT            NULL,
    [Mode]                 NVARCHAR (20)  DEFAULT ('') NULL,
    CONSTRAINT [PK__PromotionItem] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK__PromotionItem_Client] FOREIGN KEY ([PromotionItemTypeId]) REFERENCES [dbo].[PromotionItemType] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_PromotionItemTypeId]
    ON [dbo].[PromotionItem]([PromotionItemTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ItemCode]
    ON [dbo].[PromotionItem]([Code] ASC) WITH (FILLFACTOR = 100);

