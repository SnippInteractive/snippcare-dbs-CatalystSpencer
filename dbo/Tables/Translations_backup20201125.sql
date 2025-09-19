CREATE TABLE [dbo].[Translations_backup20201125] (
    [TranslationId]       INT            IDENTITY (1, 1) NOT NULL,
    [Version]             INT            NOT NULL,
    [ClientId]            INT            NULL,
    [TranslationGroup]    VARCHAR (200)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [LanguageCode]        VARCHAR (2)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Value]               NVARCHAR (MAX) NULL,
    [TranslationGroupKey] NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [UserEdited]          BIT            NOT NULL
);

