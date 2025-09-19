CREATE TABLE [dbo].[GenerateOnTheFlyStampVoucher] (
    [Id]                  INT      IDENTITY (1, 1) NOT NULL,
    [ClientId]            INT      NULL,
    [ProfileTypeId]       INT      NULL,
    [Quantity]            INT      NULL,
    [MemberId]            INT      NULL,
    [DeviceIdentifier]    INT      NULL,
    [TrxId]               INT      NULL,
    [rewardPromoId]       INT      NULL,
    [DefaultVoucherCount] INT      NULL,
    [IsProcessed]         INT      NULL,
    [CreateData]          DATETIME NOT NULL,
    [UpdateData]          DATETIME NULL,
    CONSTRAINT [PK_GenerateOnTheFlyStampVoucher] PRIMARY KEY CLUSTERED ([Id] ASC)
);

