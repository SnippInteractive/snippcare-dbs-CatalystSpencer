CREATE TABLE [dbo].[RoleModule] (
    [RoleId]      INT         NOT NULL,
    [ModuleId]    INT         NOT NULL,
    [permissions] VARCHAR (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_RoleModule_1] PRIMARY KEY CLUSTERED ([RoleId] ASC, [ModuleId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_RoleModule_Module] FOREIGN KEY ([ModuleId]) REFERENCES [dbo].[Module] ([ModuleId]),
    CONSTRAINT [FK_RoleModule_Role] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Role] ([RoleID])
);

