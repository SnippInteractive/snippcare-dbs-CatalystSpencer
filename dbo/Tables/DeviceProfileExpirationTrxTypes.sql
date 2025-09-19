CREATE TABLE [dbo].[DeviceProfileExpirationTrxTypes] (
    [Id]                       INT IDENTITY (1, 1) NOT NULL,
    [Version]                  INT CONSTRAINT [DF_DeviceProfileExpirationTrxTypeLookup_Version] DEFAULT ((0)) NOT NULL,
    [DeviceExpirationPolicyId] INT NOT NULL,
    [TrxTypeId]                INT NOT NULL,
    CONSTRAINT [PK_DeviceProfileExpirationTrxTypeLookup] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceExpirationPolicy_DeviceProfileExpirationTrxTypes] FOREIGN KEY ([DeviceExpirationPolicyId]) REFERENCES [dbo].[DeviceExpirationPolicy] ([Id]),
    CONSTRAINT [FK_TrxType_DeviceProfileExpirationTrxTypeLookup] FOREIGN KEY ([TrxTypeId]) REFERENCES [dbo].[TrxType] ([TrxTypeId])
);

