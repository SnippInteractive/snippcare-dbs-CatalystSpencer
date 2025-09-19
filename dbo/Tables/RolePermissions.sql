CREATE TABLE [dbo].[RolePermissions] (
    [RoleId]       INT NOT NULL,
    [PermissionId] INT NOT NULL,
    CONSTRAINT [FK_RolePermissions_Permission] FOREIGN KEY ([PermissionId]) REFERENCES [dbo].[Permission] ([PermissionId]),
    CONSTRAINT [FK_RolePermissions_Role] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Role] ([RoleID])
);

