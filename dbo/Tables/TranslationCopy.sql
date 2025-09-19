CREATE TABLE [dbo].[TranslationCopy] (
    [TranslationId]       INT            IDENTITY (1, 1) NOT NULL,
    [Version]             INT            NOT NULL,
    [ClientId]            INT            NOT NULL,
    [TranslationGroup]    NVARCHAR (100) NOT NULL,
    [LanguageCode]        NVARCHAR (2)   NOT NULL,
    [Value]               NVARCHAR (MAX) NOT NULL,
    [TranslationGroupKey] NVARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([TranslationId] ASC)
);

