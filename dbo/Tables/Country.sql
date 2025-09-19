CREATE TABLE [dbo].[Country] (
    [CountryId]    INT           IDENTITY (1, 1) NOT NULL,
    [Version]      INT           CONSTRAINT [DF_Country_Version] DEFAULT ((0)) NOT NULL,
    [Name]         NVARCHAR (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CountryCode]  VARCHAR (2)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]     INT           CONSTRAINT [DF_Country_ClientId] DEFAULT ((1)) NOT NULL,
    [DisplayOrder] INT           NULL,
    [Display]      BIT           CONSTRAINT [DF_Country_Display] DEFAULT ((1)) NOT NULL,
    [MobilePrefix] NVARCHAR (10) NULL,
    CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED ([CountryId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Country_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

