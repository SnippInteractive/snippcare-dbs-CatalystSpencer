CREATE TABLE [dbo].[ErrorCodeMessages] (
    [Code]     VARCHAR (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Name]     VARCHAR (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ClientId] INT           NULL,
    [Display]  BIT           NULL,
    [Version]  INT           NULL
);

