CREATE TABLE [dbo].[DeviceStatus] (
    [DeviceStatusId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]        INT           CONSTRAINT [DF_DeviceStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]           NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]       INT           NOT NULL,
    [Display]        BIT           CONSTRAINT [DF_DeviceStatus_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DeviceStatus] PRIMARY KEY CLUSTERED ([DeviceStatusId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceStatus_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[DeviceStatus] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

