CREATE TABLE [dbo].[TierLinkType] (
    [TierLinkTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]        INT           NOT NULL,
    [Name]           NVARCHAR (50) NULL,
    [ClientId]       INT           NOT NULL,
    [Display]        BIT           NOT NULL,
    CONSTRAINT [PK_TierLinkType] PRIMARY KEY CLUSTERED ([TierLinkTypeId] ASC),
    CONSTRAINT [FK_TierLinkType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

