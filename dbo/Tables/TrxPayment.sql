CREATE TABLE [dbo].[TrxPayment] (
    [TrxPaymentID]       INT            IDENTITY (1, 1) NOT NULL,
    [Version]            INT            CONSTRAINT [DF_TrxPayment_Version] DEFAULT ((0)) NOT NULL,
    [TrxID]              INT            NOT NULL,
    [TenderTypeId]       INT            NOT NULL,
    [TenderAmount]       FLOAT (53)     NULL,
    [Currency]           NVARCHAR (3)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TenderDeviceId]     NVARCHAR (30)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AuthNr]             NVARCHAR (30)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TenderProcessFlags] INT            NULL,
    [ExtraInfo]          NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_TrxPayment] PRIMARY KEY CLUSTERED ([TrxPaymentID] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TrxPayment_TenderType] FOREIGN KEY ([TenderTypeId]) REFERENCES [dbo].[TenderType] ([TenderTypeId]),
    CONSTRAINT [FK_TrxPayment_TrxHeader] FOREIGN KEY ([TrxID]) REFERENCES [dbo].[TrxHeader] ([TrxId])
);


GO
ALTER TABLE [dbo].[TrxPayment] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [IX_TrxPayment_TrxId]
    ON [dbo].[TrxPayment]([TrxID] ASC);

