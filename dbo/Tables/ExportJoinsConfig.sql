CREATE TABLE [dbo].[ExportJoinsConfig] (
    [TableName]   VARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TableJoin]   VARCHAR (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ConfigId]    SMALLINT       NOT NULL,
    [Description] VARCHAR (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_ExportJoinsConfig] PRIMARY KEY CLUSTERED ([TableName] ASC, [ConfigId] ASC) WITH (FILLFACTOR = 100)
);

