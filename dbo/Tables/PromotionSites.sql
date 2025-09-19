CREATE TABLE [dbo].[PromotionSites] (
    [Id]          INT IDENTITY (1, 1) NOT NULL,
    [Version]     INT CONSTRAINT [DF_PromotionSites_Version] DEFAULT ((0)) NOT NULL,
    [SiteId]      INT NOT NULL,
    [PromotionId] INT NOT NULL,
    CONSTRAINT [PK_Promotion] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PromotionSites_Promotion] FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotion] ([Id]),
    CONSTRAINT [FK_PromotionSites_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

