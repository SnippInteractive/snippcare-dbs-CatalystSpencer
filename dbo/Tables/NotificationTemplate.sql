CREATE TABLE [dbo].[NotificationTemplate] (
    [Id]                         INT             IDENTITY (1, 1) NOT NULL,
    [Version]                    INT             NOT NULL,
    [NotificationTemplateTypeId] INT             NOT NULL,
    [Name]                       NVARCHAR (255)  NULL,
    [Display]                    BIT             NOT NULL,
    [NotificareTemplateId]       NVARCHAR (100)  NULL,
    [Placeholders]               NVARCHAR (1000) NULL,
    [NotificationTypeId]         INT             NULL,
    [CreatedBy]                  INT             NULL,
    [CreatedDate]                DATETIME        NULL,
    [UpdatedBy]                  INT             NULL,
    [UpdatedDateTime]            DATETIME        NULL,
    [NotificationStatusId]       INT             NULL,
    [ExtraInfo]                  NVARCHAR (MAX)  NULL,
    [WeekendVoucherInfo]         NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK__NotificationTemplate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_NotificationTemplate_NotificationStatusId] FOREIGN KEY ([NotificationStatusId]) REFERENCES [dbo].[NotificationStatus] ([NotificationStatusId]),
    CONSTRAINT [FK_NotificationTemplate_NotificationTemplateType] FOREIGN KEY ([NotificationTemplateTypeId]) REFERENCES [dbo].[NotificationTemplateType] ([Id]),
    CONSTRAINT [FK_NotificationTemplate_NotificationType] FOREIGN KEY ([NotificationTypeId]) REFERENCES [dbo].[NotificationType] ([Id])
);

