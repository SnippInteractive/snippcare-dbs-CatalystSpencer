CREATE TABLE [dbo].[View] (
    [ViewId]  INT           IDENTITY (1, 1) NOT NULL,
    [Version] INT           CONSTRAINT [DF_View_Version] DEFAULT ((0)) NOT NULL,
    [Name]    VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_View] PRIMARY KEY CLUSTERED ([ViewId] ASC) WITH (FILLFACTOR = 100)
);

