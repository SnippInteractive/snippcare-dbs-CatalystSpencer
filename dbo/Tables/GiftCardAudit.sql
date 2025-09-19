CREATE TABLE [dbo].[GiftCardAudit] (
    [AuditId]    INT            IDENTITY (1, 1) NOT NULL,
    [DeviceId]   NVARCHAR (25)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [FieldName]  VARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [NewValue]   VARCHAR (MAX)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [OldValue]   VARCHAR (MAX)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ChangeDate] DATETIME       NULL,
    [ChangeBy]   INT            NULL,
    [Reason]     VARCHAR (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [SiteId]     INT            NULL,
    CONSTRAINT [PK_GiftCardAudit] PRIMARY KEY CLUSTERED ([AuditId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_GiftCardAudit_SiteId] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

