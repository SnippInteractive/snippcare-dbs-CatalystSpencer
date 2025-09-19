CREATE TABLE [dbo].[DeviceStatusTransitionType] (
    [DeviceStatusTransitionTypeId] INT            IDENTITY (1, 1) NOT NULL,
    [Version]                      INT            CONSTRAINT [DF_DeviceStatusTransition_Version] DEFAULT ((0)) NOT NULL,
    [Name]                         NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]                     INT            NOT NULL,
    [Display]                      INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DeviceStatusTransition] PRIMARY KEY CLUSTERED ([DeviceStatusTransitionTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceStatusTransitionType_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[DeviceStatusTransitionType] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

