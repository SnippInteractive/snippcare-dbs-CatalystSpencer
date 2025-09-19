CREATE TABLE [dbo].[ZipCity] (
    [Id]       INT          IDENTITY (1, 1) NOT NULL,
    [Version]  INT          CONSTRAINT [DF_ZipCity_Version] DEFAULT ((0)) NOT NULL,
    [Country]  VARCHAR (3)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Zip]      VARCHAR (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ZipExtra] VARCHAR (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [City]     VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_ZipCity] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);

