CREATE TABLE [dbo].[DeviceNumberPool] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Version]      INT           CONSTRAINT [DF_DeviceNumberPool_Version] DEFAULT ((0)) NOT NULL,
    [DeviceNumber] NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TemplateId]   INT           NOT NULL,
    [CheckSum]     CHAR (2)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [CreatedDate]  DATETIME2 (7) CONSTRAINT [DF_DeviceNumber_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [StatusId]     INT           NOT NULL,
    [CreatedBy]    INT           NOT NULL,
    [UpdatedBy]    INT           NOT NULL,
    [UpdatedDate]  DATETIME2 (7) CONSTRAINT [DF_DeviceNumber_UpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LotId]        INT           NULL,
    [Reference]    NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_DeviceNumberGeneratorDevice] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceLot_DeviceNumberPool] FOREIGN KEY ([LotId]) REFERENCES [dbo].[DeviceLot] ([Id]),
    CONSTRAINT [FK_DeviceNumberGeneratorTemplate_DeviceNumberPool] FOREIGN KEY ([TemplateId]) REFERENCES [dbo].[DeviceNumberGeneratorTemplate] ([Id]),
    CONSTRAINT [FK_DeviceNumberStatus_DeviceNumberPool] FOREIGN KEY ([StatusId]) REFERENCES [dbo].[DeviceNumberStatus] ([Id]),
    CONSTRAINT [FK_UpdatedByUser_DeviceNumber] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_User_DeviceNumber] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [IX_UniqueDeviceNumber] UNIQUE NONCLUSTERED ([DeviceNumber] ASC) WITH (FILLFACTOR = 100)
);

