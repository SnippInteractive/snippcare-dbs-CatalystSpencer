CREATE TABLE [dbo].[AddressValidStatusTranslation] (
    [AddressValidStatusTranslationId] INT IDENTITY (1, 1) NOT NULL,
    [AddressValidStatusId]            INT NOT NULL,
    [TranslationId]                   INT NOT NULL,
    CONSTRAINT [PK_AddressValidStatusTranslation] PRIMARY KEY CLUSTERED ([AddressValidStatusTranslationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AddressValidStatusTranslation_AddressValidStatus] FOREIGN KEY ([AddressValidStatusId]) REFERENCES [dbo].[AddressValidStatus] ([AddressValidStatusId]),
    CONSTRAINT [FK_AddressValidStatusTranslation_Translations] FOREIGN KEY ([TranslationId]) REFERENCES [dbo].[Translations] ([TranslationId])
);

