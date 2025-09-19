CREATE TABLE [dbo].[RefreshTokens] (
    [Id]              NVARCHAR (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Subject]         NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]        NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [IssuedUtc]       DATETIME       NOT NULL,
    [ExpiresUtc]      DATETIME       NOT NULL,
    [ProtectedTicket] NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_dbo.RefreshTokens] PRIMARY KEY CLUSTERED ([Id] ASC)
);

