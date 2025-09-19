CREATE TYPE [dbo].[promotion_validation_list] AS TABLE (
    [type_name] NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [value]     FLOAT (53)    NOT NULL);

