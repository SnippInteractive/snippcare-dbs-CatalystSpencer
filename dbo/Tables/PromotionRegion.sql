CREATE TABLE [dbo].[PromotionRegion] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Version]     INT            NOT NULL,
    [PromotionId] INT            NULL,
    [RegionId]    INT            NULL,
    [Region]      NVARCHAR (100) NULL,
    CONSTRAINT [PK_PromotionRegion] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PromotionRegion_Promotion] FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotion] ([Id])
);

