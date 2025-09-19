CREATE TABLE [dbo].[PromotionSubFamilies] (
    [Id]                         INT IDENTITY (1, 1) NOT NULL,
    [Version]                    INT NULL,
    [PromotionFamiliesId]        INT NOT NULL,
    [PromotionFamililySubTypeId] INT NOT NULL,
    CONSTRAINT [PK_PromotionSubFamilies] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PromotionSubFamilies_PromotionFamilySubType] FOREIGN KEY ([PromotionFamililySubTypeId]) REFERENCES [dbo].[ProductFamilySubType] ([Id])
);

