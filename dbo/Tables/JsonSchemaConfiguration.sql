CREATE TABLE [dbo].[JsonSchemaConfiguration] (
    [id]                INT            NOT NULL,
    [JsonSchemaVersion] NVARCHAR (30)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [JsonSchemaType]    NVARCHAR (30)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [JsonSchema]        NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
);

