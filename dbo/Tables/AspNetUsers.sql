CREATE TABLE [dbo].[AspNetUsers] (
    [Id]                   NVARCHAR (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Email]                NVARCHAR (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EmailConfirmed]       BIT            NOT NULL,
    [PasswordHash]         NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [SecurityStamp]        NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PhoneNumber]          NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PhoneNumberConfirmed] BIT            NOT NULL,
    [TwoFactorEnabled]     BIT            NOT NULL,
    [LockoutEndDateUtc]    DATETIME       NULL,
    [LockoutEnabled]       BIT            NOT NULL,
    [AccessFailedCount]    INT            NOT NULL,
    [UserName]             NVARCHAR (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_dbo.AspNetUsers] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex]
    ON [dbo].[AspNetUsers]([UserName] ASC);

