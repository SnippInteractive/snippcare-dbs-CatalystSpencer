CREATE TABLE [dbo].[TierType] (
    [TierTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]    INT           NOT NULL,
    [Name]       NVARCHAR (50) NULL,
    [ClientId]   INT           NOT NULL,
    [Display]    BIT           NOT NULL,
    CONSTRAINT [PK_TierType] PRIMARY KEY CLUSTERED ([TierTypeId] ASC),
    CONSTRAINT [FK_TierType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

