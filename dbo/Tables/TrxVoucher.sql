CREATE TABLE [dbo].[TrxVoucher] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [TrxID]         INT            NOT NULL,
    [VoucherId]     NVARCHAR (25)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Version]       INT            CONSTRAINT [DF_TrxVoucher_Version] DEFAULT ((0)) NOT NULL,
    [VoucherAmount] DECIMAL (8, 2) NULL,
    [DeviceId]      INT            NULL,
    CONSTRAINT [PK_TrxVoucher_1] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_TrxVoucher_DeviceId] FOREIGN KEY ([DeviceId]) REFERENCES [dbo].[Device] ([Id]),
    CONSTRAINT [FK_TrxVoucher_TrxHeader] FOREIGN KEY ([TrxID]) REFERENCES [dbo].[TrxHeader] ([TrxId]),
    CONSTRAINT [uc_TrxId_VoucherId] UNIQUE NONCLUSTERED ([TrxID] ASC, [VoucherId] ASC) WITH (FILLFACTOR = 95)
);


GO
ALTER TABLE [dbo].[TrxVoucher] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

