CREATE TABLE [dbo].[UserNotifications] (
    [UserNotificationId]   INT            IDENTITY (1, 1) NOT NULL,
    [Version]              INT            NULL,
    [UserSegmentId]        INT            NULL,
    [NotificationId]       INT            NULL,
    [Publish]              BIT            NULL,
    [ExtraInfo]            NVARCHAR (MAX) NULL,
    [NotificationStatusId] INT            NULL,
    [Deleted]              BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_UserNotifications_UserNotificationId] PRIMARY KEY CLUSTERED ([UserNotificationId] ASC),
    CONSTRAINT [FK_UserNotifications_NotificationId] FOREIGN KEY ([NotificationId]) REFERENCES [dbo].[Notifications] ([NotificationId])
);

