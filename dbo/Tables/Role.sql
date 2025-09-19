CREATE TABLE [dbo].[Role] (
    [RoleID]   INT           IDENTITY (1, 1) NOT NULL,
    [ClientId] INT           NOT NULL,
    [Enabled]  INT           DEFAULT ((0)) NULL,
    [Name]     NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Version]  INT           CONSTRAINT [DF_Role_Version] DEFAULT ((0)) NOT NULL,
    [Visible]  INT           CONSTRAINT [DF_Role_Visible] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED ([RoleID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Role_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SysUserId of the Role Manager', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Role', @level2type = N'COLUMN', @level2name = N'RoleID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Set to 1 to enable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Role', @level2type = N'COLUMN', @level2name = N'Enabled';

