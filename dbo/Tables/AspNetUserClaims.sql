CREATE TABLE [dbo].[AspNetUserClaims] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [UserId]     NVARCHAR (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClaimType]  NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ClaimValue] NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_dbo.AspNetUserClaims] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_UserId]
    ON [dbo].[AspNetUserClaims]([UserId] ASC);

