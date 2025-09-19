CREATE TABLE [CMS].[PageTemplateHistory] (
    [Id]                        INT            IDENTITY (1, 1) NOT NULL,
    [PageTemplateTypeId]        INT            NOT NULL,
    [PageTemplatePlaceHolderId] INT            NULL,
    [Version]                   INT            NOT NULL,
    [ClientId]                  INT            NOT NULL,
    [IsPublished]               BIT            NOT NULL,
    [CreatedBy]                 INT            NOT NULL,
    [CreationDate]              DATETIME       NOT NULL,
    [LastModifiedBy]            INT            NULL,
    [LastModificationDate]      DATETIME       NULL,
    [PageTemplateId]            INT            NOT NULL,
    [HtmlContent]               NVARCHAR (MAX) DEFAULT (NULL) NULL,
    CONSTRAINT [PK_PageTemplateHistory] PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([PageTemplateId]) REFERENCES [CMS].[PageTemplate] ([Id]),
    FOREIGN KEY ([PageTemplateId]) REFERENCES [CMS].[PageTemplate] ([Id]),
    CONSTRAINT [FK_PageTemplateHistory_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_PageTemplateHistory_PageTemplatePlaceHolder] FOREIGN KEY ([PageTemplatePlaceHolderId]) REFERENCES [CMS].[PageTemplatePlaceHolder] ([Id]),
    CONSTRAINT [FK_PageTemplateHistory_PageTemplateType] FOREIGN KEY ([PageTemplateTypeId]) REFERENCES [CMS].[PageTemplateType] ([Id])
);


GO
CREATE TRIGGER [CMS].[PageTemplateHistory_AspNet_SqlCacheNotification_Trigger] ON [CMS].[PageTemplateHistory]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'PageTemplateHistory'
                       END
