CREATE TABLE [dbo].[FrequencyType] (
    [FrequencyTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Name]            NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ClientId]        INT           NULL,
    [Display]         BIT           NULL,
    [Version]         INT           NULL,
    CONSTRAINT [PK_FrequencyType] PRIMARY KEY CLUSTERED ([FrequencyTypeId] ASC)
);

