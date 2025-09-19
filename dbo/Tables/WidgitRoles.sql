CREATE TABLE [dbo].[WidgitRoles] (
    [WidgitId] INT NOT NULL,
    [RoleId]   INT NOT NULL,
    CONSTRAINT [FK_WidgitRoles_Role] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Role] ([RoleID]),
    CONSTRAINT [FK_WidgitRoles_Widgit] FOREIGN KEY ([WidgitId]) REFERENCES [dbo].[Widgit] ([WidgitId])
);

