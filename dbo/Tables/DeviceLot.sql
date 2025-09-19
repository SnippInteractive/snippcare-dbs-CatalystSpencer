CREATE TABLE [dbo].[DeviceLot] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [Version]              INT             CONSTRAINT [DF_DeviceLot_Version] DEFAULT ((0)) NOT NULL,
    [Created]              DATETIME2 (7)   CONSTRAINT [DF_DeviceLot_Created] DEFAULT (getdate()) NOT NULL,
    [Updated]              DATETIME2 (7)   CONSTRAINT [DF_DeviceLot_Updated] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            INT             NOT NULL,
    [UpdatedBy]            INT             NOT NULL,
    [StatusId]             INT             NOT NULL,
    [NumberOfDevices]      INT             NOT NULL,
    [StartDate]            DATETIME2 (7)   NULL,
    [InitialCashBalance]   DECIMAL (18, 2) CONSTRAINT [DF_DeviceLot_InitialAmount] DEFAULT ((0)) NULL,
    [Name]                 NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Reference]            NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [InitialPointsBalance] DECIMAL (18)    CONSTRAINT [DF_DeviceLot_InitialPointsBalance] DEFAULT ((0)) NULL,
    [ExpiryDate]           DATETIME2 (7)   NULL,
    [DevicesAssigned]      BIT             CONSTRAINT [DF_DeviceLot_DevicesAssigned] DEFAULT ((0)) NULL,
    [DeviceStatusId]       INT             NULL,
    CONSTRAINT [PK_DeviceLot] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CK_NumberOfDevices] CHECK ([NumberOfDevices]>(0)),
    CONSTRAINT [FK_DeviceLot_DeviceLotStatus] FOREIGN KEY ([StatusId]) REFERENCES [dbo].[DeviceLotStatus] ([Id]),
    CONSTRAINT [FK_DeviceLot_DeviceStatus] FOREIGN KEY ([DeviceStatusId]) REFERENCES [dbo].[DeviceStatus] ([DeviceStatusId])
);

