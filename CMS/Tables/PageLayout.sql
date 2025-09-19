CREATE TABLE [CMS].[PageLayout] (
    [Id]                     INT      IDENTITY (1, 1) NOT NULL,
    [ClientId]               INT      NOT NULL,
    [PortalSiteNavigationId] INT      NULL,
    [PageTemplateId]         INT      NOT NULL,
    [CreatedBy]              INT      NOT NULL,
    [CreationDate]           DATETIME NOT NULL,
    [LastModifiedBy]         INT      NULL,
    [LastModificationDate]   DATETIME NULL,
    [SiteId]                 INT      DEFAULT ((2)) NULL,
    [IsDisplay]              BIT      DEFAULT ('1') NOT NULL,
    [ThemeId]                INT      DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_PageLayout] PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    FOREIGN KEY ([ThemeId]) REFERENCES [CMS].[Theme] ([Id]),
    FOREIGN KEY ([ThemeId]) REFERENCES [CMS].[Theme] ([Id]),
    CONSTRAINT [FK_Client_PageLayout] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_PageTemplate_PageLayout] FOREIGN KEY ([PageTemplateId]) REFERENCES [CMS].[PageTemplate] ([Id]),
    CONSTRAINT [FK_PortalSiteNavigation_PageLayout] FOREIGN KEY ([PortalSiteNavigationId]) REFERENCES [dbo].[PortalSiteNavigation] ([Id])
);


GO
CREATE TRIGGER [CMS].[PageLayout_AspNet_SqlCacheNotification_Trigger] ON [CMS].[PageLayout]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'PageLayout'
                       END
