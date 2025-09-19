CREATE TABLE [dbo].[ContactSubType] (
    [ContactSubTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]          INT          NOT NULL,
    [Name]             VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]         INT          NOT NULL,
    [Display]          BIT          NOT NULL,
    CONSTRAINT [PK_ContactSubType] PRIMARY KEY CLUSTERED ([ContactSubTypeId] ASC),
    CONSTRAINT [FK_ContactSubType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

