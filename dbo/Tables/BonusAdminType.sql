CREATE TABLE [dbo].[BonusAdminType] (
    [BonusAdminTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]          INT           NOT NULL,
    [Name]             NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]         INT           NOT NULL,
    [Display]          BIT           NOT NULL,
    CONSTRAINT [PK_BonusAdminType] PRIMARY KEY CLUSTERED ([BonusAdminTypeId] ASC)
);

