CREATE TABLE [dbo].[PaymentDeviceProfileTemplate] (
    [Id] INT NOT NULL,
    CONSTRAINT [PK_PaymentDeviceProfile] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceProfile_PaymentDeviceProfile] FOREIGN KEY ([Id]) REFERENCES [dbo].[DeviceProfileTemplate] ([Id])
);

