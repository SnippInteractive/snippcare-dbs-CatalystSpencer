CREATE TABLE [CMS].[PageTemplate] (
    [Id]                            INT            IDENTITY (1, 1) NOT NULL,
    [PageTemplateTypeId]            INT            NOT NULL,
    [PortalSiteNavigationId]        INT            NULL,
    [HtmlPath]                      NVARCHAR (MAX) NULL,
    [HtmlContent]                   NVARCHAR (MAX) NULL,
    [Version]                       INT            NOT NULL,
    [ClientId]                      INT            NOT NULL,
    [CreatedBy]                     INT            NOT NULL,
    [CreationDate]                  DATETIME       NOT NULL,
    [LastModifiedBy]                INT            NULL,
    [LastModificationDate]          DATETIME       NULL,
    [PageTemplateTypePlaceHolderId] INT            NULL,
    CONSTRAINT [PK_PageTemplate] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Client_PageTemplate] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_PageTemplatePlaceHolder_PageTemplate] FOREIGN KEY ([PageTemplateTypePlaceHolderId]) REFERENCES [CMS].[PageTemplatePlaceHolder] ([Id]),
    CONSTRAINT [FK_PageTemplateType_PageTemplate] FOREIGN KEY ([PageTemplateTypeId]) REFERENCES [CMS].[PageTemplateType] ([Id]),
    CONSTRAINT [FK_PortalSiteNavigation_PageTemplate] FOREIGN KEY ([PortalSiteNavigationId]) REFERENCES [dbo].[PortalSiteNavigation] ([Id])
);


GO
CREATE TRIGGER [CMS].[PageTemplate_AspNet_SqlCacheNotification_Trigger] ON [CMS].[PageTemplate]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'PageTemplate'
                       END
