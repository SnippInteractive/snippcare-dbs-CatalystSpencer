CREATE TABLE [dbo].[DeviceProfile] (
    [Id]              INT IDENTITY (1, 1) NOT NULL,
    [Version]         INT CONSTRAINT [DF_Device_DeviceProfile_Version] DEFAULT ((0)) NOT NULL,
    [StatusId]        INT NOT NULL,
    [DeviceId]        INT NOT NULL,
    [DeviceProfileId] INT NOT NULL,
    CONSTRAINT [PK_Device_DeviceProfile_1] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_Device_Device_DeviceProfile] FOREIGN KEY ([DeviceId]) REFERENCES [dbo].[Device] ([Id]),
    CONSTRAINT [FK_Device_DeviceProfileStatus_Device_DeviceProfile] FOREIGN KEY ([StatusId]) REFERENCES [dbo].[DeviceProfileStatus] ([DeviceProfileStatusId]),
    CONSTRAINT [FK_DeviceProfile_Device_DeviceProfileTemplate] FOREIGN KEY ([DeviceProfileId]) REFERENCES [dbo].[DeviceProfileTemplate] ([Id]),
    CONSTRAINT [IX_UniqueDevice_DeviceProfile] UNIQUE NONCLUSTERED ([DeviceId] ASC, [DeviceProfileId] ASC) WITH (FILLFACTOR = 95)
);


GO
ALTER TABLE [dbo].[DeviceProfile] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [IX_DeviceProfile_DeviceProfileId]
    ON [dbo].[DeviceProfile]([DeviceProfileId] ASC)
    INCLUDE([DeviceId], [StatusId]);

