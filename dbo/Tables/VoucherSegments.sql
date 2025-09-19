CREATE TABLE [dbo].[VoucherSegments] (
    [Id]        INT IDENTITY (1, 1) NOT NULL,
    [Version]   INT NOT NULL,
    [VoucherId] INT NOT NULL,
    [SegmentId] INT NOT NULL,
    CONSTRAINT [PK_VoucherSegments] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_VoucherSegments_SegmentAdmin] FOREIGN KEY ([SegmentId]) REFERENCES [dbo].[SegmentAdmin] ([SegmentId]),
    CONSTRAINT [FK_VoucherSegments_VoucherDeviceProfileTemplate] FOREIGN KEY ([VoucherId]) REFERENCES [dbo].[VoucherDeviceProfileTemplate] ([Id])
);

