CREATE TABLE [dbo].[WidgitMetaDataTranslation] (
    [WidgitMetaDataTranslationId] INT IDENTITY (1, 1) NOT NULL,
    [WidgitMetaDataId]            INT NOT NULL,
    [TranslationId]               INT NOT NULL,
    CONSTRAINT [PK_WidgitMetaDataTranslation] PRIMARY KEY CLUSTERED ([WidgitMetaDataTranslationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WidgitMetaDataTranslation_Translations] FOREIGN KEY ([TranslationId]) REFERENCES [dbo].[Translations] ([TranslationId]),
    CONSTRAINT [FK_WidgitMetaDataTranslation_WidgitMetaData] FOREIGN KEY ([WidgitMetaDataId]) REFERENCES [dbo].[WidgitMetaData] ([WidgitMetaDataId])
);

