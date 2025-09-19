CREATE TABLE [dbo].[DeviceProfileChargeFee] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [Version]           INT             CONSTRAINT [DF_DeviceFeeCharge_Version] DEFAULT ((0)) NOT NULL,
    [FeeTypeId]         INT             NOT NULL,
    [FeeValue]          DECIMAL (18, 2) NOT NULL,
    [NumberDaysToCheck] INT             NOT NULL,
    CONSTRAINT [PK_DeviceFeeCharge] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceChargeFeeType_DeviceChargeFee] FOREIGN KEY ([FeeTypeId]) REFERENCES [dbo].[DeviceProfileChargeFeeType] ([Id])
);

