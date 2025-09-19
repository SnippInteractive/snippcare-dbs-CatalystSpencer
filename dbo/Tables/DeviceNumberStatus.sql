CREATE TABLE [dbo].[DeviceNumberStatus] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]  INT           CONSTRAINT [DF_DeviceNumberStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId] INT           NOT NULL,
    [Display]  BIT           NOT NULL,
    CONSTRAINT [PK_DeviceNumberGeneratorDeviceStatus] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Client_DeviceNumberStatus] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

