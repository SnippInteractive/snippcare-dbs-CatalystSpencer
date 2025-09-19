CREATE TABLE [CMS].[PageTemplatePlaceHolder] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [PlaceHolder]          NVARCHAR (MAX) NULL,
    [ClientId]             INT            NOT NULL,
    [CreatedBy]            INT            NOT NULL,
    [CreationDate]         DATETIME       NOT NULL,
    [LastModifiedBy]       INT            NULL,
    [LastModificationDate] DATETIME       NULL,
    CONSTRAINT [PK_PageTemplatePlaceHolder] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Client_PageTemplatePlaceHolder] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
CREATE TRIGGER [CMS].[PageTemplatePlaceHolder_AspNet_SqlCacheNotification_Trigger] ON [CMS].[PageTemplatePlaceHolder]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'PageTemplatePlaceHolder'
                       END
