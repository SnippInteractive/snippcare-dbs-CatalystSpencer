CREATE TABLE [dbo].[AddressStatusTranslation] (
    [AddressStatusTranslationId] INT IDENTITY (1, 1) NOT NULL,
    [AddressStatusId]            INT NOT NULL,
    [TranslationId]              INT NOT NULL,
    CONSTRAINT [PK_AddressStatusTranslation] PRIMARY KEY CLUSTERED ([AddressStatusTranslationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AddressStatusTranslation_AddressStatus] FOREIGN KEY ([AddressStatusId]) REFERENCES [dbo].[AddressStatus] ([AddressStatusId]),
    CONSTRAINT [FK_AddressStatusTranslation_Translations] FOREIGN KEY ([TranslationId]) REFERENCES [dbo].[Translations] ([TranslationId])
);

