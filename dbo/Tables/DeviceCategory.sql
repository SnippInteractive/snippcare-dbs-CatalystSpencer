CREATE TABLE [dbo].[DeviceCategory] (
    [DeviceCategoryId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]          INT          CONSTRAINT [DF_DeviceCategory_Version] DEFAULT ((0)) NOT NULL,
    [Name]             VARCHAR (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]         INT          NOT NULL,
    [Display]          INT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DeviceCategory] PRIMARY KEY CLUSTERED ([DeviceCategoryId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceCategory_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

