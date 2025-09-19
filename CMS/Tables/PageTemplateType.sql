CREATE TABLE [CMS].[PageTemplateType] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [Name]                 NVARCHAR (25) NOT NULL,
    [CreatedBy]            INT           NOT NULL,
    [CreationDate]         DATETIME      NOT NULL,
    [LastModifiedBy]       INT           NULL,
    [LastModificationDate] DATETIME      NULL,
    [TemplateGroup]        NVARCHAR (25) NULL,
    [ThemeId]              INT           DEFAULT ((1)) NULL,
    [TemplateDisplayName]  NVARCHAR (50) NULL,
    [GroupDisplayName]     NVARCHAR (50) NULL,
    CONSTRAINT [PK_PageTemplateType] PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([ThemeId]) REFERENCES [CMS].[Theme] ([Id]),
    FOREIGN KEY ([ThemeId]) REFERENCES [CMS].[Theme] ([Id])
);


GO
CREATE TRIGGER [CMS].[PageTemplateType_AspNet_SqlCacheNotification_Trigger] ON [CMS].[PageTemplateType]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'PageTemplateType'
                       END
