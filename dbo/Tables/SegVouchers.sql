CREATE TABLE [dbo].[SegVouchers] (
    [SegmentVoucherId]      INT             IDENTITY (1, 1) NOT NULL,
    [SegmentId]             INT             NOT NULL,
    [Priority]              INT             NOT NULL,
    [Type]                  SMALLINT        NOT NULL,
    [MvId]                  INT             NULL,
    [PointsValue]           INT             NULL,
    [Value]                 DECIMAL (18, 2) NULL,
    [AdditionalPointsValue] INT             NULL,
    [AdditionalValue]       DECIMAL (18, 2) NULL,
    [MaximumRedeem]         INT             NULL,
    [ValidFrom]             DATETIME        NULL,
    [ValidTo]               DATETIME        NULL,
    [UseBirthday]           INT             NULL,
    [ShadowDelta]           INT             NULL,
    CONSTRAINT [PK_SegVouchers] PRIMARY KEY CLUSTERED ([SegmentVoucherId] ASC) WITH (FILLFACTOR = 100)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegVouchers', @level2type = N'COLUMN', @level2name = N'SegmentVoucherId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SegmentId from SegHeader table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegVouchers', @level2type = N'COLUMN', @level2name = N'SegmentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1.. n, with 1 = highest priority', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegVouchers', @level2type = N'COLUMN', @level2name = N'Priority';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Open Financial Voucher, 2 = Fixed Financial Voucher, 3 = Marketing Voucher', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegVouchers', @level2type = N'COLUMN', @level2name = N'Type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'If Type = 3, then this points to the MarketingVoucher Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegVouchers', @level2type = N'COLUMN', @level2name = N'MvId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Vouchers points value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegVouchers', @level2type = N'COLUMN', @level2name = N'PointsValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'vouchers value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegVouchers', @level2type = N'COLUMN', @level2name = N'Value';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This is only used in Open financial vouchers and is the additional redeem points quantities', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegVouchers', @level2type = N'COLUMN', @level2name = N'AdditionalPointsValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This is only used in the open financial vouchers and is the value of the additionl redeem points', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegVouchers', @level2type = N'COLUMN', @level2name = N'AdditionalValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'If Type = 1, This is a mximum points redeem allowed, if type = 2 or 3, this is the maximum no. vouchers', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegVouchers', @level2type = N'COLUMN', @level2name = N'MaximumRedeem';

