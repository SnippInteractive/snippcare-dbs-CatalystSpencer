CREATE TABLE [dbo].[WidgitMetaData] (
    [WidgitMetaDataId] INT           IDENTITY (1, 1) NOT NULL,
    [WidgitId]         INT           NOT NULL,
    [Version]          INT           CONSTRAINT [DF_WidgitMetaData_Version] DEFAULT ((0)) NOT NULL,
    [Key]              VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Value]            VARCHAR (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_WidgitMetaData] PRIMARY KEY CLUSTERED ([WidgitMetaDataId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WidgitMetaData_Widgit] FOREIGN KEY ([WidgitId]) REFERENCES [dbo].[Widgit] ([WidgitId])
);

