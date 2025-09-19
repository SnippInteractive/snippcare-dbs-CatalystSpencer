CREATE TABLE [dbo].[UserNotificationHistory] (
    [UserNotificationHistoryId] INT            IDENTITY (1, 1) NOT NULL,
    [UserNotificationId]        INT            NULL,
    [UserId]                    INT            NULL,
    [ReadDateTime]              DATETIME       NULL,
    [PublishDateTime]           DATETIME       NULL,
    [SentDateTime]              DATETIME       NULL,
    [NotificationStatusId]      INT            NULL,
    [NotificationTemplateId]    INT            NULL,
    [ExtraInfo]                 NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_UserNotificationHistory_UserNotificationHistoryId] PRIMARY KEY CLUSTERED ([UserNotificationHistoryId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_UserNotificationHistory_UserId]
    ON [dbo].[UserNotificationHistory]([NotificationTemplateId] ASC)
    INCLUDE([UserId]);

