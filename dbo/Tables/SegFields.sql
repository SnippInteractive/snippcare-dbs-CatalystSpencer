CREATE TABLE [dbo].[SegFields] (
    [SegFieldId]     SMALLINT      NOT NULL,
    [Name]           VARCHAR (20)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TableName]      VARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [FieldName]      VARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [FieldType]      TINYINT       NOT NULL,
    [LookupTable]    VARCHAR (30)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LookupName]     VARCHAR (30)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LookupValue]    VARCHAR (30)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LookupLang]     BIT           NULL,
    [LookupClientId] BIT           NULL,
    [DW_TableName]   NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DW_FieldName]   NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_SegFields] PRIMARY KEY CLUSTERED ([SegFieldId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SegFields_SegFieldType] FOREIGN KEY ([FieldType]) REFERENCES [dbo].[SegFieldType] ([FieldTypeId])
);

