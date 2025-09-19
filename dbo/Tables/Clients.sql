CREATE TABLE [dbo].[Clients] (
    [Id]                   NVARCHAR (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Secret]               NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Name]                 NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ApplicationType]      INT            NOT NULL,
    [Active]               BIT            NOT NULL,
    [RefreshTokenLifeTime] INT            NOT NULL,
    [AllowedOrigin]        NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_dbo.Clients] PRIMARY KEY CLUSTERED ([Id] ASC)
);

