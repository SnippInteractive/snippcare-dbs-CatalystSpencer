CREATE TABLE [dbo].[PromotionCategory] (
    [Id]                      INT            IDENTITY (1, 1) NOT NULL,
    [Version]                 INT            NOT NULL,
    [Name]                    NVARCHAR (500) NOT NULL,
    [PromotionCategoryTypeId] INT            NOT NULL,
    [ClientId]                INT            NOT NULL,
    [Display]                 BIT            NOT NULL,
    CONSTRAINT [PK__PormotionCategory] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK__PromotionCategory__Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

