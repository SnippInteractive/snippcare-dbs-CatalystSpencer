CREATE TABLE [dbo].[NewsLetter] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Subject]     VARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Description] VARCHAR (200)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [CreatedBy]   INT            NOT NULL,
    [CreateDate]  DATETIME       NOT NULL,
    [UpdatedBy]   INT            NULL,
    [UpdateDate]  DATETIME       NULL,
    [Html]        NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ClientId]    INT            NOT NULL,
    CONSTRAINT [PK_Templates] PRIMARY KEY CLUSTERED ([Id] ASC)
);

