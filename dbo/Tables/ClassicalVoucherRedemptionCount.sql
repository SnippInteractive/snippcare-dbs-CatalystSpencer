CREATE TABLE [dbo].[ClassicalVoucherRedemptionCount] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [MemberId]           INT           NULL,
    [VoucherId]          VARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LastRedemptionDate] DATETIME      NULL,
    [TrxId]              INT           NULL,
    [DeviceId]           NVARCHAR (25) NULL,
    CONSTRAINT [PK_ClassicalVoucherRedemptionCount] PRIMARY KEY CLUSTERED ([Id] ASC)
);

