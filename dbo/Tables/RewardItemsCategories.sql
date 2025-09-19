CREATE TABLE [dbo].[RewardItemsCategories] (
    [RewardItemsCategoriesID] INT IDENTITY (1, 1) NOT NULL,
    [RewardCategoryId]        INT NOT NULL,
    [RewardItemId]            INT NOT NULL,
    CONSTRAINT [PK_RewardItemsCategories] PRIMARY KEY CLUSTERED ([RewardItemsCategoriesID] ASC),
    CONSTRAINT [FK_RewardItemsCategories_RewardCategory] FOREIGN KEY ([RewardCategoryId]) REFERENCES [dbo].[RewardCategory] ([RewardCategoryId]),
    CONSTRAINT [FK_RewardItemsCategories_RewardItems] FOREIGN KEY ([RewardItemId]) REFERENCES [dbo].[RewardItems] ([RewardItemId])
);

