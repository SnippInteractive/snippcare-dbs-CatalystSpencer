CREATE TABLE [dbo].[ModuleActions] (
    [ModuleActionsId] INT          IDENTITY (1, 1) NOT NULL,
    [ModuleId]        INT          NULL,
    [Name]            VARCHAR (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_ModuleActions] PRIMARY KEY CLUSTERED ([ModuleActionsId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ModuleActions_Module] FOREIGN KEY ([ModuleId]) REFERENCES [dbo].[Module] ([ModuleId])
);

