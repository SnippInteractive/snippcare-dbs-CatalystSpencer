CREATE TABLE [dbo].[Community] (
    [CommunityId]    INT           IDENTITY (1, 1) NOT NULL,
    [Name]           NVARCHAR (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Version]        INT           CONSTRAINT [DF_Community_Version] DEFAULT ((0)) NOT NULL,
    [UserId]         INT           NOT NULL,
    [oldCommunityId] INT           NULL,
    CONSTRAINT [PK_Community] PRIMARY KEY CLUSTERED ([CommunityId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Community_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);

