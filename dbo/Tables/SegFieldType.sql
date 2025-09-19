CREATE TABLE [dbo].[SegFieldType] (
    [FieldTypeId] TINYINT    NOT NULL,
    [Description] NCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_SegFieldType] PRIMARY KEY CLUSTERED ([FieldTypeId] ASC) WITH (FILLFACTOR = 100)
);

