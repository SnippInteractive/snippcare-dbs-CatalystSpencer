CREATE TABLE [dbo].[Nationality] (
    [NationalityId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]       INT           CONSTRAINT [DF_Nationality_Version] DEFAULT ((0)) NOT NULL,
    [Name]          NVARCHAR (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ShortCode]     VARCHAR (2)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CountryId]     INT           NOT NULL,
    [ClientId]      INT           CONSTRAINT [DF_Nationality_ClientId] DEFAULT ((1)) NOT NULL,
    [Display]       BIT           CONSTRAINT [DF_Nationality_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Nationality] PRIMARY KEY CLUSTERED ([NationalityId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Nationality_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

