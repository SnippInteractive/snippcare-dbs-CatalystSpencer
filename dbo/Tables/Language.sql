CREATE TABLE [dbo].[Language] (
    [LanguageId]   INT           IDENTITY (1, 1) NOT NULL,
    [Version]      INT           CONSTRAINT [DF_Language_Version] DEFAULT ((0)) NOT NULL,
    [Name]         NVARCHAR (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [LanguageCode] VARCHAR (10)  NULL,
    [ClientId]     INT           CONSTRAINT [DF_Language_ClientId] DEFAULT ((1)) NOT NULL,
    [DisplayOrder] INT           NULL,
    [Display]      BIT           CONSTRAINT [DF_Language_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Language] PRIMARY KEY CLUSTERED ([LanguageId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Language_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

