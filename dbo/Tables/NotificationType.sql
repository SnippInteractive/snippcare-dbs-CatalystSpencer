CREATE TABLE [dbo].[NotificationType] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]  INT           DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (50) NOT NULL,
    [ClientId] INT           NOT NULL,
    [Display]  INT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_NotificationType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

