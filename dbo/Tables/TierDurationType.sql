CREATE TABLE [dbo].[TierDurationType] (
    [TierDurationTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]            INT           NOT NULL,
    [Name]               NVARCHAR (50) NULL,
    [ClientId]           INT           NOT NULL,
    [Display]            BIT           NOT NULL,
    CONSTRAINT [PK_TierDurationType] PRIMARY KEY CLUSTERED ([TierDurationTypeId] ASC),
    CONSTRAINT [FK_TierDurationType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

