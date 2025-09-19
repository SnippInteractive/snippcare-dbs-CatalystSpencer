CREATE TABLE [dbo].[PromotionProductFamilies] (
    [Id]                     INT IDENTITY (1, 1) NOT NULL,
    [Version]                INT NOT NULL,
    [PromotionId]            INT NOT NULL,
    [ProductFamilySubTypeId] INT NOT NULL,
    CONSTRAINT [PK_PromotionTypes] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PromotionTypes_Promotion] FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotion] ([Id]),
    CONSTRAINT [FK_PromotionTypes_PromotionType] FOREIGN KEY ([ProductFamilySubTypeId]) REFERENCES [dbo].[ProductFamilySubType] ([Id])
);

