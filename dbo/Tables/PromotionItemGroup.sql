CREATE TABLE [dbo].[PromotionItemGroup] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]  INT           CONSTRAINT [DF__PromotionItemGroup_Version] DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (50) NOT NULL,
    [ClientId] INT           NOT NULL,
    [Display]  BIT           CONSTRAINT [DF_PromotionItemGroup_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK__PromotionItemGroup] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK__PromotionItemGroup__Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

