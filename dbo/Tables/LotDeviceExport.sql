CREATE TABLE [dbo].[LotDeviceExport] (
    [LotDeviceExportId] INT           IDENTITY (1, 1) NOT NULL,
    [LotId]             INT           NULL,
    [CreatedBy]         INT           NULL,
    [CreatedDate]       DATETIME      NULL,
    [EmailId]           VARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ExportJobStatusId] INT           NULL,
    [Link]              VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Version]           INT           CONSTRAINT [DF_LotDeviceExport_Version] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_LotDeviceExport] PRIMARY KEY CLUSTERED ([LotDeviceExportId] ASC)
);

