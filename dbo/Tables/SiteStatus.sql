CREATE TABLE [dbo].[SiteStatus] (
    [SiteStatusId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]      INT          CONSTRAINT [DF_SiteStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]         VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]     INT          NULL,
    [Display]      BIT          CONSTRAINT [DF_SiteStatus_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_SiteStatus] PRIMARY KEY CLUSTERED ([SiteStatusId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SiteStatus_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

