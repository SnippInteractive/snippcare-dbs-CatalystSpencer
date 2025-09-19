CREATE TABLE [dbo].[DeviceStatusHistory] (
    [DeviceStatusHistoryId]      INT            IDENTITY (1, 1) NOT NULL,
    [Version]                    INT            CONSTRAINT [DF_DeviceStatusHistory_Version] DEFAULT ((0)) NOT NULL,
    [DeviceId]                   NVARCHAR (25)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [DeviceStatusId]             INT            NOT NULL,
    [ChangeDate]                 DATETIME       NOT NULL,
    [Reason]                     NVARCHAR (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DeviceStatusTransitionType] INT            NULL,
    [ExtraInfo]                  NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [UserId]                     INT            NOT NULL,
    [ActionId]                   INT            NULL,
    [DeviceTypeResult]           NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ActionResult]               BIT            NULL,
    [ActionDetail]               NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [OldValue]                   NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [NewValue]                   NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [SiteId]                     INT            NOT NULL,
    [Processed]                  INT            DEFAULT ((0)) NOT NULL,
    [DeviceIdentity]             INT            NULL,
    [OpId]                       NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TerminalId]                 NVARCHAR (25)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_DeviceStatusHistory] PRIMARY KEY CLUSTERED ([DeviceStatusHistoryId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceStatusHistory_Device] FOREIGN KEY ([DeviceIdentity]) REFERENCES [dbo].[Device] ([Id]),
    CONSTRAINT [FK_DeviceStatusHistory_DeviceAction] FOREIGN KEY ([ActionId]) REFERENCES [dbo].[DeviceAction] ([DeviceActionId]),
    CONSTRAINT [FK_DeviceStatusHistory_DeviceStatusId] FOREIGN KEY ([DeviceStatusId]) REFERENCES [dbo].[DeviceStatus] ([DeviceStatusId]),
    CONSTRAINT [FK_Site_DeviceStatusHistory] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_User_DeviceStatusHistory] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[DeviceStatusHistory] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

