CREATE TABLE [dbo].[VoucherProductFamilies] (
    [Id]                     INT IDENTITY (1, 1) NOT NULL,
    [VoucherProfileId]       INT NOT NULL,
    [ProductFamilySubTypeId] INT NOT NULL,
    CONSTRAINT [PK_VoucherProductFamilies] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_VoucherProductFamilies_ProductFamilySubType] FOREIGN KEY ([ProductFamilySubTypeId]) REFERENCES [dbo].[ProductFamilySubType] ([Id]),
    CONSTRAINT [FK_VoucherProductFamilies_VoucherDeviceProfileTemplate] FOREIGN KEY ([VoucherProfileId]) REFERENCES [dbo].[VoucherDeviceProfileTemplate] ([Id])
);

