CREATE TABLE [dbo].[PromotionCategoryType] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [Version]  INT            NOT NULL,
    [Name]     NVARCHAR (250) NOT NULL,
    [ClientId] INT            NOT NULL,
    [Display]  BIT            NOT NULL,
    CONSTRAINT [PK__PormotionCategoryType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);

