CREATE TABLE [dbo].[ManualClaimTypeTranslation] (
    [ManualClaimTypeTranslationId] INT IDENTITY (1, 1) NOT NULL,
    [ManualClaimTypeId]            INT NOT NULL,
    [TranslationId]                INT NOT NULL,
    CONSTRAINT [PK_ManualClaimTypeTranslation] PRIMARY KEY CLUSTERED ([ManualClaimTypeTranslationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ManualClaimTypeTranslation_ManualClaimType] FOREIGN KEY ([ManualClaimTypeId]) REFERENCES [dbo].[ManualClaimType] ([ManualClaimTypeId]),
    CONSTRAINT [FK_ManualClaimTypeTranslation_Translations] FOREIGN KEY ([TranslationId]) REFERENCES [dbo].[Translations] ([TranslationId])
);

