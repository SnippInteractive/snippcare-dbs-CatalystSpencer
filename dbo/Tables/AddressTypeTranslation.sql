CREATE TABLE [dbo].[AddressTypeTranslation] (
    [AddressTypeTranslationId] INT IDENTITY (1, 1) NOT NULL,
    [AddressTypeId]            INT NOT NULL,
    [TranslationId]            INT NOT NULL,
    CONSTRAINT [PK_AddressTypeTranslation] PRIMARY KEY CLUSTERED ([AddressTypeTranslationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AddressTypeTranslation_AddressType] FOREIGN KEY ([AddressTypeId]) REFERENCES [dbo].[AddressType] ([AddressTypeId]),
    CONSTRAINT [FK_AddressTypeTranslation_Translations] FOREIGN KEY ([TranslationId]) REFERENCES [dbo].[Translations] ([TranslationId])
);

