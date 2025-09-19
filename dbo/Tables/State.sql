CREATE TABLE [dbo].[State] (
    [StateId]      INT          IDENTITY (1, 1) NOT NULL,
    [Version]      INT          NOT NULL,
    [ClientId]     INT          NOT NULL,
    [Display]      BIT          NOT NULL,
    [CountryId]    INT          NULL,
    [Name]         VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [StateCode]    NVARCHAR (3) NULL,
    [LanguageCode] NVARCHAR (3) DEFAULT ('en') NULL,
    CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED ([StateId] ASC),
    CONSTRAINT [FK_CountryCounty_] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_State_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[State] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

