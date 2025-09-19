CREATE TABLE [dbo].[DeviceProfileTemplateType] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]  INT           CONSTRAINT [DF_DeviceProfileTemplateType_Version] DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId] INT           NOT NULL,
    [Display]  BIT           NOT NULL,
    CONSTRAINT [PK_DeviceProfileTemplateType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ClientId_DeviceProfileTemplateType] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

