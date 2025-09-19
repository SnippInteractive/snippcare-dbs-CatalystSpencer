CREATE TABLE [dbo].[EmailProfile] (
    [EmailProfileId]  INT           IDENTITY (1, 1) NOT NULL,
    [ClientId]        INT           NULL,
    [ProfileName]     VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [MailServer]      VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [MailFrom]        VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AccountName]     VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AccountPassword] VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Port]            INT           NULL,
    [UseSSL]          INT           NULL,
    [Anonymous]       INT           NULL,
    [EmailsPerMin]    INT           NULL,
    CONSTRAINT [PK_EmailProfile] PRIMARY KEY CLUSTERED ([EmailProfileId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EmailProfile_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

