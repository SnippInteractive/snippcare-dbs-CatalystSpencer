CREATE TABLE [dbo].[SiteAuthentication] (
    [Id]     INT            IDENTITY (1, 1) NOT NULL,
    [Name]   NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ApiKey] NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Secret] NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SiteId] INT            NOT NULL,
    CONSTRAINT [FK_ClientAuthentication_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

