CREATE TABLE [dbo].[DeviceLotDeviceProfile] (
    [Id]              INT IDENTITY (1, 1) NOT NULL,
    [Version]         INT CONSTRAINT [DF_DeviceLot_DeviceProfile_Version] DEFAULT ((0)) NOT NULL,
    [DeviceLotId]     INT NOT NULL,
    [DeviceProfileId] INT NOT NULL,
    CONSTRAINT [PK_DeviceLot_DeviceProfile] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_DeviceLotDeviceProfile_DeviceLot] FOREIGN KEY ([DeviceLotId]) REFERENCES [dbo].[DeviceLot] ([Id]),
    CONSTRAINT [FK_DeviceLotDeviceProfile_DeviceProfileTemplate] FOREIGN KEY ([DeviceProfileId]) REFERENCES [dbo].[DeviceProfileTemplate] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_Unique_DeviceLot_DeviceProfile]
    ON [dbo].[DeviceLotDeviceProfile]([DeviceLotId] ASC, [DeviceProfileId] ASC) WITH (FILLFACTOR = 95);

