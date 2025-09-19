CREATE TABLE [dbo].[DeviceAction] (
    [DeviceActionId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]        INT           CONSTRAINT [DF_DeviceAction_Version] DEFAULT ((0)) NOT NULL,
    [Name]           NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Display]        BIT           NOT NULL,
    [ClientId]       INT           NOT NULL,
    CONSTRAINT [PK_DeviceAction] PRIMARY KEY CLUSTERED ([DeviceActionId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceAction_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [Unique_DeviceAction] UNIQUE NONCLUSTERED ([DeviceActionId] ASC) WITH (FILLFACTOR = 100)
);


GO
ALTER TABLE [dbo].[DeviceAction] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

