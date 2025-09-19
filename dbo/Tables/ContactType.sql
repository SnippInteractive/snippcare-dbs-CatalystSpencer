CREATE TABLE [dbo].[ContactType] (
    [ContactTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]       INT           CONSTRAINT [DF_ContactType_Version] DEFAULT ((0)) NOT NULL,
    [Name]          NVARCHAR (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]      INT           NOT NULL,
    [Display]       BIT           CONSTRAINT [DF_ContactType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_ContactType] PRIMARY KEY CLUSTERED ([ContactTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ContactType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

