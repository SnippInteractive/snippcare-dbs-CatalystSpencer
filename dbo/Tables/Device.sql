CREATE TABLE [dbo].[Device] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [DeviceId]             NVARCHAR (25)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Version]              INT            CONSTRAINT [DF_Device_Version] DEFAULT ((0)) NOT NULL,
    [DeviceStatusId]       INT            NOT NULL,
    [DeviceTypeId]         INT            NOT NULL,
    [UserId]               INT            NULL,
    [HomeSiteId]           INT            NOT NULL,
    [CreateDate]           DATETIME       NOT NULL,
    [Owner]                NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Reference]            NVARCHAR (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EmbossLine1]          NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EmbossLine2]          NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EmbossLine3]          NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EmbossLine4]          NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EmbossLine5]          NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Pin]                  NVARCHAR (4)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DeviceNumberPoolId]   INT            NULL,
    [ExpirationDate]       DATETIME2 (7)  NULL,
    [AccountId]            INT            NULL,
    [StartDate]            DATETIME2 (7)  NULL,
    [PinFailedAttempts]    INT            CONSTRAINT [DF_Device_PinFailedAttempts] DEFAULT ((0)) NOT NULL,
    [DeviceLotId]          INT            NULL,
    [ExtraInfo]            NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LotSequenceNo]        NVARCHAR (12)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [OLD_AccountID]        INT            NULL,
    [OLD_MemberID]         INT            NULL,
    [AssignedBy]           NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Deleted]              BIT            DEFAULT ((0)) NULL,
    [CVC]                  NVARCHAR (3)   NULL,
    [PINVerificationValue] NVARCHAR (5)   NULL,
    [ImageUrl]             NVARCHAR (500) NULL,
    CONSTRAINT [PK_Device_1] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_Account_Device] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccountId]),
    CONSTRAINT [FK_Device_DeviceLot] FOREIGN KEY ([DeviceLotId]) REFERENCES [dbo].[DeviceLot] ([Id]),
    CONSTRAINT [FK_Device_DeviceStatus] FOREIGN KEY ([DeviceStatusId]) REFERENCES [dbo].[DeviceStatus] ([DeviceStatusId]),
    CONSTRAINT [FK_Device_DeviceType] FOREIGN KEY ([DeviceTypeId]) REFERENCES [dbo].[DeviceType] ([DeviceTypeId]),
    CONSTRAINT [FK_Device_Site] FOREIGN KEY ([HomeSiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_Device_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_DeviceNumber_Device] FOREIGN KEY ([DeviceNumberPoolId]) REFERENCES [dbo].[DeviceNumberPool] ([Id])
);


GO
ALTER TABLE [dbo].[Device] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [IX_Device_Account]
    ON [dbo].[Device]([AccountId] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Device_DeviceId]
    ON [dbo].[Device]([DeviceId] ASC)
    INCLUDE([Id], [UserId]);


GO
CREATE NONCLUSTERED INDEX [IX_Device_UserId]
    ON [dbo].[Device]([UserId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Device_DeviceLotId]
    ON [dbo].[Device]([DeviceLotId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Device_DeviceStatusId]
    ON [dbo].[Device]([DeviceStatusId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Device_ExtraInfoIDUserStatusOwner]
    ON [dbo].[Device]([ExtraInfo] ASC, [UserId] ASC, [DeviceStatusId] ASC, [Owner] ASC) WITH (FILLFACTOR = 75);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DeviceId]
    ON [dbo].[Device]([DeviceId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Device_ExtraInfo]
    ON [dbo].[Device]([ExtraInfo] ASC);

