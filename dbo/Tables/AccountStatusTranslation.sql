CREATE TABLE [dbo].[AccountStatusTranslation] (
    [AccountStatusTypeTranslationId] INT IDENTITY (1, 1) NOT NULL,
    [AccountStatusId]                INT NOT NULL,
    [TranslationId]                  INT NOT NULL,
    CONSTRAINT [PK_AccountStatusTypeTranslation] PRIMARY KEY CLUSTERED ([AccountStatusTypeTranslationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountStatusTypeTranslation_AccountStatusType] FOREIGN KEY ([AccountStatusId]) REFERENCES [dbo].[AccountStatus] ([AccountStatusId]),
    CONSTRAINT [FK_AccountStatusTypeTranslation_Translations] FOREIGN KEY ([TranslationId]) REFERENCES [dbo].[Translations] ([TranslationId])
);

