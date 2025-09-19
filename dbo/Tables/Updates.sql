CREATE TABLE [dbo].[Updates] (
    [UpdateId]    INT            IDENTITY (1, 1) NOT NULL,
    [SiteId]      INT            NOT NULL,
    [Type]        NVARCHAR (20)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Title]       VARCHAR (MAX)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Description] NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Content]     NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Price]       DECIMAL (18)   NULL,
    [Image]       NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DateAdded]   DATETIME       NOT NULL,
    [ValidFrom]   DATETIME       NOT NULL,
    [ValidTo]     DATETIME       NOT NULL,
    CONSTRAINT [FK_Updates_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

