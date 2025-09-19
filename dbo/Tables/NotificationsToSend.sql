CREATE TABLE [dbo].[NotificationsToSend] (
    [NotificationID]         INT            IDENTITY (1, 1) NOT NULL,
    [Version]                INT            NULL,
    [ClientID]               INT            NULL,
    [UserId]                 INT            NULL,
    [Recipient]              NVARCHAR (MAX) NULL,
    [NotificationType]       NVARCHAR (50)  NULL,
    [NotificareTemplateId]   NVARCHAR (150) NULL,
    [NotificareTemplateName] NVARCHAR (150) NULL,
    [PlaceHolders]           NVARCHAR (MAX) NULL,
    [AuditID]                INT            NULL,
    [TrxID]                  INT            NULL,
    [SentDate]               DATETIME       NULL,
    [ContactPreferences]     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_NotificationsToSend] PRIMARY KEY CLUSTERED ([NotificationID] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [IDX_NotificationsToSend_TemplateName]
    ON [dbo].[NotificationsToSend]([NotificareTemplateName] ASC)
    INCLUDE([TrxID]);


GO
CREATE NONCLUSTERED INDEX [IDX_NotificationToSend_SentDate]
    ON [dbo].[NotificationsToSend]([SentDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_UserId]
    ON [dbo].[NotificationsToSend]([UserId] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_NotificareTemplateId]
    ON [dbo].[NotificationsToSend]([NotificareTemplateId] ASC);

