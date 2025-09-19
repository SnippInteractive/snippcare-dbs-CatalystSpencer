CREATE TABLE [dbo].[SiteType] (
    [SiteTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]    INT           CONSTRAINT [DF_SiteType_Version] DEFAULT ((0)) NOT NULL,
    [Name]       NVARCHAR (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]   INT           NULL,
    [Display]    BIT           CONSTRAINT [DF_SiteType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_SiteType] PRIMARY KEY CLUSTERED ([SiteTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SiteType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

