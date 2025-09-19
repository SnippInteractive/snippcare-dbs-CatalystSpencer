CREATE TABLE [dbo].[ActivityType] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [Name]     NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Image]    NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ClientId] INT            NULL,
    [Display]  BIT            NULL,
    CONSTRAINT [PK_ActivityType] PRIMARY KEY CLUSTERED ([Id] ASC)
);

