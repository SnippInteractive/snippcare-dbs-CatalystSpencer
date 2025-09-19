CREATE TABLE [dbo].[DeviceExpirationPolicy] (
    [Id]                     INT IDENTITY (1, 1) NOT NULL,
    [Version]                INT CONSTRAINT [DF_DeviceExpirationPolicy_Version] DEFAULT ((0)) NOT NULL,
    [ExpirationPolicyTypeId] INT NOT NULL,
    [NumberDaysUntilExpire]  INT NOT NULL,
    CONSTRAINT [PK_DeviceExpirationPolicy] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceExpirationType_DeviceExpirationPolicy] FOREIGN KEY ([ExpirationPolicyTypeId]) REFERENCES [dbo].[DeviceExpirationPolicyType] ([Id])
);

