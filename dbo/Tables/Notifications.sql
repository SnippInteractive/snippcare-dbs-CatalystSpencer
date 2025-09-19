CREATE TABLE [dbo].[Notifications] (
    [NotificationId]     INT            IDENTITY (1, 1) NOT NULL,
    [NotificationName]   NVARCHAR (100) NULL,
    [Version]            INT            NULL,
    [Subject]            NVARCHAR (250) NULL,
    [Description]        NVARCHAR (500) NULL,
    [Content]            NVARCHAR (MAX) NULL,
    [ExtraInfo]          NVARCHAR (MAX) NULL,
    [NotificationTypeId] INT            NULL,
    [ClientId]           INT            NULL,
    [Deleted]            BIT            NULL,
    [CreatedBy]          INT            NULL,
    [CreatedDate]        DATETIME       NULL,
    [UpdatedBy]          INT            NULL,
    [UpdatedDateTime]    DATETIME       NULL,
    [ImageUrl]           NVARCHAR (500) NULL,
    CONSTRAINT [PK_Notifications_NotificationId] PRIMARY KEY CLUSTERED ([NotificationId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Notifications_Id]
    ON [dbo].[Notifications]([NotificationId] ASC)
    INCLUDE([NotificationName], [Subject], [Description], [Content], [NotificationTypeId], [ExtraInfo], [ImageUrl]);

