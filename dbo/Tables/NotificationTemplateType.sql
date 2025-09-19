CREATE TABLE [dbo].[NotificationTemplateType] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [Version]  INT            NOT NULL,
    [Name]     NVARCHAR (500) NOT NULL,
    [ClientId] INT            NOT NULL,
    [Display]  BIT            NOT NULL,
    CONSTRAINT [PK__NotificationTemplateType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK__NotificationTemplateType__Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

