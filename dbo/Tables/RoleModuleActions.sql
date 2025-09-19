CREATE TABLE [dbo].[RoleModuleActions] (
    [RoleId]          INT         NOT NULL,
    [ModuleActionsId] INT         NOT NULL,
    [permissions]     VARCHAR (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_RoleModuleActions_1] PRIMARY KEY CLUSTERED ([RoleId] ASC, [ModuleActionsId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_RoleModuleActions_ModuleActions] FOREIGN KEY ([ModuleActionsId]) REFERENCES [dbo].[ModuleActions] ([ModuleActionsId]),
    CONSTRAINT [FK_RoleModuleActions_Role] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Role] ([RoleID])
);

