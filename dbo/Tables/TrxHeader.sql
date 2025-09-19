CREATE TABLE [dbo].[TrxHeader] (
    [TrxId]                INT                IDENTITY (1, 1) NOT NULL,
    [Version]              INT                CONSTRAINT [DF_TrxHeader_Version] DEFAULT ((0)) NOT NULL,
    [DeviceId]             NVARCHAR (25)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TrxTypeId]            INT                NOT NULL,
    [TrxDate]              DATETIMEOFFSET (7) NOT NULL,
    [ClientId]             INT                NULL,
    [SiteId]               INT                NULL,
    [TerminalId]           NVARCHAR (25)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Reference]            NVARCHAR (50)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [OpId]                 NVARCHAR (100)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TrxStatusTypeId]      INT                NULL,
    [CreateDate]           DATETIME           CONSTRAINT [DF_TrxHeader_CreateDate] DEFAULT (getdate()) NOT NULL,
    [TerminalDescription]  NVARCHAR (100)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [BatchId]              NVARCHAR (100)     NULL,
    [Batch_Urn]            NVARCHAR (100)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TrxCommitDate]        DATETIMEOFFSET (7) NULL,
    [InitialTransaction]   INT                NULL,
    [DeviceIdentity]       INT                NULL,
    [CallContextId]        UNIQUEIDENTIFIER   NULL,
    [TerminalExtra]        NVARCHAR (100)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AccountCashBalance]   FLOAT (53)         NULL,
    [AccountPointsBalance] FLOAT (53)         NULL,
    [ImportUniqueId]       NVARCHAR (50)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EposTrxId]            BIGINT             NULL,
    [TerminalExtra2]       NVARCHAR (MAX)     NULL,
    [TerminalExtra3]       NVARCHAR (1000)    NULL,
    [MemberId]             INT                NULL,
    [TotalPoints]          FLOAT (53)         NULL,
    [OLD_TrxId]            INT                NULL,
    [LastUpdatedDate]      DATETIMEOFFSET (7) NULL,
    [IsAnonymous]          BIT                NULL,
    [ReservationId]        INT                NULL,
    [IsTransferred]        BIT                NULL,
    [ReceiptId]            INT                NULL,
    [Region]               NVARCHAR (100)     NULL,
    [Location]             NVARCHAR (100)     NULL,
    CONSTRAINT [PK_TrxHeader] PRIMARY KEY CLUSTERED ([TrxId] ASC) WITH (FILLFACTOR = 95),
    FOREIGN KEY ([ReceiptId]) REFERENCES [dbo].[Receipt] ([ReceiptId]),
    FOREIGN KEY ([ReservationId]) REFERENCES [dbo].[Reservation] ([ReservationId]),
    CONSTRAINT [FK_TrxHeader_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_TrxHeader_Device] FOREIGN KEY ([DeviceIdentity]) REFERENCES [dbo].[Device] ([Id]),
    CONSTRAINT [FK_TrxHeader_SiteId] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_TrxHeader_TrxHeader] FOREIGN KEY ([InitialTransaction]) REFERENCES [dbo].[TrxHeader] ([TrxId]),
    CONSTRAINT [FK_TrxHeader_TrxHeader_DeviceId] FOREIGN KEY ([DeviceId]) REFERENCES [dbo].[Device] ([DeviceId]),
    CONSTRAINT [FK_TrxHeader_TrxStatusType] FOREIGN KEY ([TrxStatusTypeId]) REFERENCES [dbo].[TrxStatus] ([TrxStatusId]),
    CONSTRAINT [FK_TrxHeader_TrxType] FOREIGN KEY ([TrxTypeId]) REFERENCES [dbo].[TrxType] ([TrxTypeId])
);


GO
ALTER TABLE [dbo].[TrxHeader] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [DeviceId]
    ON [dbo].[TrxHeader]([DeviceId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_TrxDate]
    ON [dbo].[TrxHeader]([TrxDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TrxType]
    ON [dbo].[TrxHeader]([TrxTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_Reference]
    ON [dbo].[TrxHeader]([Reference] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TrxStatus]
    ON [dbo].[TrxHeader]([TrxStatusTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SiteId]
    ON [dbo].[TrxHeader]([SiteId] ASC);

