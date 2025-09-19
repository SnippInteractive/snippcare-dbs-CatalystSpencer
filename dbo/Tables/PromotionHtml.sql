CREATE TABLE [dbo].[PromotionHtml] (
    [Id]          INT  IDENTITY (1, 1) NOT NULL,
    [Version]     INT  NOT NULL,
    [PromotionId] INT  NOT NULL,
    [HtmlContent] TEXT NULL,
    [ClientId]    INT  NOT NULL,
    CONSTRAINT [PK_PromotionHtml] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_PromotionHtml_Client2] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_PromotionHtml_Promotion] FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotion] ([Id])
);

