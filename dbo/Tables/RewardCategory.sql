CREATE TABLE [dbo].[RewardCategory] (
    [RewardCategoryId] INT            IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (200) NOT NULL,
    [SmallImageURL]    NVARCHAR (MAX) NULL,
    [MediumImageURL]   NVARCHAR (MAX) NULL,
    [Enabled]          BIT            NULL,
    [CreatedDate]      DATETIME       NULL,
    [LastUpdatedDate]  DATETIME       NULL,
    [ClientId]         INT            NOT NULL,
    CONSTRAINT [PK_RewardCategory] PRIMARY KEY CLUSTERED ([RewardCategoryId] ASC)
);

