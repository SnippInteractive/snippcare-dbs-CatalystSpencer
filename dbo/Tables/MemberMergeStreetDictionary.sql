CREATE TABLE [dbo].[MemberMergeStreetDictionary] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [StandardizedFormat]   NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [UnstandardizedFormat] NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [LanguageCode]         NVARCHAR (2)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

