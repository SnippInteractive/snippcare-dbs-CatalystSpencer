CREATE TABLE [dbo].[Audit] (
    [AuditId]       INT            IDENTITY (1, 1) NOT NULL,
    [Version]       INT            CONSTRAINT [DF_Audit_Version] DEFAULT ((0)) NOT NULL,
    [UserId]        INT            NOT NULL,
    [FieldName]     VARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [NewValue]      NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [OldValue]      NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ChangeDate]    DATETIME       NULL,
    [ChangeBy]      INT            NULL,
    [Reason]        NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ReferenceType] NVARCHAR (75)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [OperatorId]    NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [SiteId]        INT            NULL,
    [AdminScreen]   VARCHAR (100)  NULL,
    [SysUser]       INT            NULL,
    CONSTRAINT [PK_Audit] PRIMARY KEY CLUSTERED ([AuditId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Audit_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_Audit_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_Audit_User1] FOREIGN KEY ([ChangeBy]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[Audit] NOCHECK CONSTRAINT [FK_Audit_Site];


GO
ALTER TABLE [dbo].[Audit] NOCHECK CONSTRAINT [FK_Audit_User];


GO
ALTER TABLE [dbo].[Audit] NOCHECK CONSTRAINT [FK_Audit_User1];


GO
CREATE NONCLUSTERED INDEX [IX_UserId]
    ON [dbo].[Audit]([UserId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FieldName]
    ON [dbo].[Audit]([FieldName] ASC);

