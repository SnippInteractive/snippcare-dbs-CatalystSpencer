CREATE TABLE [dbo].[Translations] (
    [TranslationId]       INT            IDENTITY (1, 1) NOT NULL,
    [Version]             INT            CONSTRAINT [DF_Translations_Version] DEFAULT ((0)) NOT NULL,
    [ClientId]            INT            NULL,
    [TranslationGroup]    VARCHAR (200)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [LanguageCode]        VARCHAR (2)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Value]               NVARCHAR (MAX) NULL,
    [TranslationGroupKey] NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [UserEdited]          BIT            CONSTRAINT [DF_Translations_UserEdited] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Translations] PRIMARY KEY CLUSTERED ([TranslationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [uc_Client_Group_Key_Lang] UNIQUE NONCLUSTERED ([ClientId] ASC, [TranslationGroup] ASC, [LanguageCode] ASC, [TranslationGroupKey] ASC) WITH (FILLFACTOR = 100)
);

