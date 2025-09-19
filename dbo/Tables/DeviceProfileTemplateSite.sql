CREATE TABLE [dbo].[DeviceProfileTemplateSite] (
    [Id]                      INT IDENTITY (1, 1) NOT NULL,
    [Version]                 INT CONSTRAINT [DF_DeviceProfileTemplateSite_Version] DEFAULT ((0)) NOT NULL,
    [SiteId]                  INT NOT NULL,
    [DeviceProfileTemplateId] INT NOT NULL,
    CONSTRAINT [PK_DeviceProfileTemplateSite] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_DeviceProfileTemplateSite_DeviceProfileTemplate] FOREIGN KEY ([DeviceProfileTemplateId]) REFERENCES [dbo].[DeviceProfileTemplate] ([Id]),
    CONSTRAINT [FK_DeviceProfileTemplateSite_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

