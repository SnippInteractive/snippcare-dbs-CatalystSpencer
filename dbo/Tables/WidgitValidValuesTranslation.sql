CREATE TABLE [dbo].[WidgitValidValuesTranslation] (
    [WidgitValidValuesTranslationId] INT IDENTITY (1, 1) NOT NULL,
    [WidgitValidValueId]             INT NOT NULL,
    [TranslationId]                  INT NOT NULL,
    CONSTRAINT [PK_WidgitValidValuesTranslation] PRIMARY KEY CLUSTERED ([WidgitValidValuesTranslationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WidgitValidValuesTranslation_Translations] FOREIGN KEY ([TranslationId]) REFERENCES [dbo].[Translations] ([TranslationId]),
    CONSTRAINT [FK_WidgitValidValuesTranslation_WidgitValidValues] FOREIGN KEY ([WidgitValidValueId]) REFERENCES [dbo].[WidgitValidValues] ([WidgitValidValueId])
);

