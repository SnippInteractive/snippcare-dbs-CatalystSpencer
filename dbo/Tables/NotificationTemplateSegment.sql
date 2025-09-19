CREATE TABLE [dbo].[NotificationTemplateSegment] (
    [Id]                     INT IDENTITY (1, 1) NOT NULL,
    [Version]                INT NULL,
    [SegmentId]              INT NOT NULL,
    [NotificationTemplateId] INT NOT NULL,
    CONSTRAINT [PK_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_NotificationTemplateSegment_NotificationTemplateId] FOREIGN KEY ([NotificationTemplateId]) REFERENCES [dbo].[NotificationTemplate] ([Id])
);

