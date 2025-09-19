CREATE TYPE [dbo].[string_list2] AS TABLE (
    [value]   NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [value2]  NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [display] INT            NOT NULL);

