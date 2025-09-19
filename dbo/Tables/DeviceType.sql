CREATE TABLE [dbo].[DeviceType] (
    [DeviceTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]      INT           CONSTRAINT [DF_DeviceType_Version] DEFAULT ((0)) NOT NULL,
    [Name]         NVARCHAR (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]     INT           NOT NULL,
    [Display]      BIT           CONSTRAINT [DF_DeviceType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DeviceType] PRIMARY KEY CLUSTERED ([DeviceTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceType_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

