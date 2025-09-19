CREATE TABLE [dbo].[DeviceProfileTemplateOnlineSites] (
    [Id]                      INT IDENTITY (1, 1) NOT NULL,
    [Version]                 INT CONSTRAINT [DF_DeviceProfileTemplateOnlineSites_Version] DEFAULT ((0)) NOT NULL,
    [SiteId]                  INT NOT NULL,
    [DeviceProfileTemplateId] INT NOT NULL,
    CONSTRAINT [PK_DeviceProfileTemplateOnlineSites] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceProfileTemplate_DeviceProfileTemplateOnlineSites] FOREIGN KEY ([DeviceProfileTemplateId]) REFERENCES [dbo].[DeviceProfileTemplate] ([Id]),
    CONSTRAINT [FK_Site_DeviceProfileTemplateOnlineSites] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

