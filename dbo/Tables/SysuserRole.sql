CREATE TABLE [dbo].[SysuserRole] (
    [SysuserID]  INT NOT NULL,
    [RoleID]     INT NOT NULL,
    [UserRoleId] INT IDENTITY (1, 1) NOT NULL,
    [Version]    INT CONSTRAINT [DF_SysuserRole_Version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SysuserRole_1] PRIMARY KEY CLUSTERED ([UserRoleId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SysuserRole_Role] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[Role] ([RoleID]),
    CONSTRAINT [FK_SysuserRole_User] FOREIGN KEY ([SysuserID]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[SysuserRole] NOCHECK CONSTRAINT [FK_SysuserRole_Role];


GO
ALTER TABLE [dbo].[SysuserRole] NOCHECK CONSTRAINT [FK_SysuserRole_User];

