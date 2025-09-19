CREATE TABLE [dbo].[WidgitValidValues] (
    [WidgitValidValueId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]            INT           CONSTRAINT [DF_WidgitValidValues_Version] DEFAULT ((0)) NOT NULL,
    [WidgitId]           INT           NOT NULL,
    [Value]              NVARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TranslationCode]    VARCHAR (30)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_WidgitValidValues] PRIMARY KEY CLUSTERED ([WidgitValidValueId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WidgitValidValues_Widgit] FOREIGN KEY ([WidgitId]) REFERENCES [dbo].[Widgit] ([WidgitId])
);

