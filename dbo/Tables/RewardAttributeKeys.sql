CREATE TABLE [dbo].[RewardAttributeKeys] (
    [RewardAttributeKeysId] INT            IDENTITY (1, 1) NOT NULL,
    [Version]               INT            NOT NULL,
    [Name]                  NVARCHAR (100) NULL,
    [Display]               BIT            NOT NULL,
    [ClientId]              INT            NOT NULL,
    CONSTRAINT [PK_RewardAttributeKeys] PRIMARY KEY CLUSTERED ([RewardAttributeKeysId] ASC),
    CONSTRAINT [FK_RewardAttributeKeys_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

