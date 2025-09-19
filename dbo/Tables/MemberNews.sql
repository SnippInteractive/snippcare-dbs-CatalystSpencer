CREATE TABLE [dbo].[MemberNews] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Description] VARCHAR (MAX)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [UrlText]     VARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Image]       NVARCHAR (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [MemberId]    INT            NULL,
    [NewsMedium]  VARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Link]        VARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_MemberNews] PRIMARY KEY CLUSTERED ([Id] ASC)
);

