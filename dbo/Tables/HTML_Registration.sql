CREATE TABLE [dbo].[HTML_Registration] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Status]      INT            NOT NULL,
    [ClientId]    INT            NOT NULL,
    [PreviewHTML] NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [RenderHTML]  NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [CreatedDate] DATETIME       NOT NULL,
    [TemplateId]  INT            NOT NULL,
    CONSTRAINT [PK_HTML_Registration] PRIMARY KEY CLUSTERED ([Id] ASC)
);

