CREATE TYPE [dbo].[string_list] AS TABLE (
    [value]   NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [display] INT            NOT NULL);

