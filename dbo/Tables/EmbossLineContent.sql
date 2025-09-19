CREATE TABLE [dbo].[EmbossLineContent] (
    [EmbossLineContentId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]             INT           CONSTRAINT [DF_EmbossLineContent_Version] DEFAULT ((0)) NOT NULL,
    [EmbossLineId]        INT           NOT NULL,
    [ContentType]         INT           NOT NULL,
    [Order]               INT           NOT NULL,
    [Value]               VARCHAR (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_EmbossLineContent] PRIMARY KEY CLUSTERED ([EmbossLineContentId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_EmbossLineContent_EmbossLine] FOREIGN KEY ([EmbossLineId]) REFERENCES [dbo].[EmbossLine] ([EmbossLineId])
);

