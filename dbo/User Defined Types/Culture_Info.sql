CREATE TYPE [dbo].[Culture_Info] AS TABLE (
    [CountryName]          NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CountryCode]          NVARCHAR (3)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Nationality]          NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [NationalityShortCode] NVARCHAR (3)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LanguageName]         NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LanguageCode]         NVARCHAR (2)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [CurrencyName]         NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [CurrencyCode]         NVARCHAR (3)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL);

