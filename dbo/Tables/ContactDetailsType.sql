CREATE TABLE [dbo].[ContactDetailsType] (
    [ContactDetailsTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]              INT           CONSTRAINT [DF_ContactDetailsType_Version] DEFAULT ((0)) NOT NULL,
    [Name]                 NVARCHAR (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]             INT           NOT NULL,
    [Display]              BIT           CONSTRAINT [DF_ContactDetailsType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_ContactDetailsType] PRIMARY KEY CLUSTERED ([ContactDetailsTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ContactDetailsType_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

