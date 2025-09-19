CREATE TABLE [dbo].[ClientAuthentication] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [ApiKey]   NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Secret]   NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId] INT            NOT NULL,
    [Name]     NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [FK_ClientAuthentication_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

