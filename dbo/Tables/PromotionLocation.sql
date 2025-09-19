CREATE TABLE [dbo].[PromotionLocation] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Version]     INT            NOT NULL,
    [PromotionId] INT            NOT NULL,
    [LocationId]  INT            NULL,
    [Location]    NVARCHAR (100) NULL,
    [Description] NVARCHAR (200) CONSTRAINT [Default_PromotionLocation_Descripton] DEFAULT ('') NULL,
    CONSTRAINT [PK_PromotionLocation] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PromotionLocation_Promotion] FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotion] ([Id])
);

