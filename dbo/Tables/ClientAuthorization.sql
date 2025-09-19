CREATE TABLE [dbo].[ClientAuthorization] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Version]           INT           NOT NULL,
    [ClientId]          INT           NOT NULL,
    [UserId]            INT           NOT NULL,
    [IssueDate]         DATETIME2 (7) NOT NULL,
    [ExpirationDateUtc] DATETIME2 (7) NULL,
    [Scope]             VARCHAR (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_ClientAuthorization] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ClientAuthorization_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_ClientAuthorization_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [UC_ClientAuthorization] UNIQUE NONCLUSTERED ([ClientId] ASC, [UserId] ASC) WITH (FILLFACTOR = 100)
);

