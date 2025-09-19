CREATE TABLE [dbo].[NotificationStatus] (
    [NotificationStatusId] INT            IDENTITY (1, 1) NOT NULL,
    [Version]              INT            NULL,
    [Name]                 NVARCHAR (100) NULL,
    [ClientId]             INT            NULL,
    [Display]              BIT            NULL,
    CONSTRAINT [PK_NotificationStatus_NotificationStatusId] PRIMARY KEY CLUSTERED ([NotificationStatusId] ASC)
);

