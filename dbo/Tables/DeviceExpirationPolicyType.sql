CREATE TABLE [dbo].[DeviceExpirationPolicyType] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]  INT           CONSTRAINT [DF_DeviceExpirationType_Version] DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId] INT           NULL,
    [Display]  BIT           NULL,
    CONSTRAINT [PK_DeviceExpirationType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);

