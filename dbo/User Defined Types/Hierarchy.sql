CREATE TYPE [dbo].[Hierarchy] AS TABLE (
    [element_id]  INT             NOT NULL,
    [sequenceNo]  INT             NULL,
    [parent_ID]   INT             NULL,
    [Object_ID]   INT             NULL,
    [NAME]        NVARCHAR (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [StringValue] NVARCHAR (MAX)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ValueType]   VARCHAR (10)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    PRIMARY KEY CLUSTERED ([element_id] ASC));

