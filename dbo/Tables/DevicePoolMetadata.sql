CREATE TABLE [dbo].[DevicePoolMetadata] (
    [Id]                               INT           IDENTITY (1, 1) NOT NULL,
    [Version]                          INT           CONSTRAINT [DF_DevicePoolMetadata_Version] DEFAULT ((0)) NOT NULL,
    [CreatedBy]                        INT           NOT NULL,
    [CreatedDate]                      DATETIME2 (7) CONSTRAINT [DF_DevicePoolMetadata_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ClientId]                         INT           NOT NULL,
    [MinimumPoolThreshold]             DECIMAL (37)  NULL,
    [InitialDeviceStatusId]            INT           CONSTRAINT [DF_DevicePoolMetadata_InitialDeviceStatusId] DEFAULT ((0)) NULL,
    [InitialAssociatedAccountStatusId] INT           CONSTRAINT [DF_DevicePoolMetadata_InitialAssociatedAccountStatusId] DEFAULT ((0)) NULL,
    [InitialDeviceTypeId]              INT           CONSTRAINT [DF_DevicePoolMetadata_InitialDeviceTypeId] DEFAULT ((0)) NULL,
    [DeviceNumberGeneratorTemplateId]  INT           NULL,
    [TotalNumberOfDevicesUsed]         INT           NULL,
    [NumberOfAvailableDevices]         INT           NULL,
    CONSTRAINT [PK_DevicePoolMetadata] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DevicePoolMetadata_AccountStatus] FOREIGN KEY ([InitialAssociatedAccountStatusId]) REFERENCES [dbo].[AccountStatus] ([AccountStatusId]),
    CONSTRAINT [FK_DevicePoolMetadata_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_DevicePoolMetadata_DeviceStatus] FOREIGN KEY ([InitialDeviceStatusId]) REFERENCES [dbo].[DeviceStatus] ([DeviceStatusId]),
    CONSTRAINT [FK_DevicePoolMetadata_DeviceType] FOREIGN KEY ([InitialDeviceTypeId]) REFERENCES [dbo].[DeviceType] ([DeviceTypeId]),
    CONSTRAINT [FK_DevicePoolMetadata_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId])
);

