CREATE TABLE [dbo].[OAuthMembership] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [Provider]       NVARCHAR (30)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ProviderUserId] NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [UserId]         INT            NOT NULL,
    [Version]        INT            CONSTRAINT [DF_OAuthMembership_Version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_OAuthMembership] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OAuthMembership_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [IX_OAuthMembership] UNIQUE NONCLUSTERED ([Provider] ASC, [ProviderUserId] ASC) WITH (FILLFACTOR = 100)
);

