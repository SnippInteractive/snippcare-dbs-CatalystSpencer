CREATE TABLE [dbo].[Image] (
    [Id]        INT             IDENTITY (1, 1) NOT NULL,
    [ImageData] VARBINARY (MAX) NULL,
    [Mimetype]  NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [SourceId]  INT             NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

