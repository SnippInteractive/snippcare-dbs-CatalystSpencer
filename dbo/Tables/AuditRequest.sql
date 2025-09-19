CREATE TABLE [dbo].[AuditRequest] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [time_stamp] DATETIME         CONSTRAINT [DF_AuditRequest_time_stamp] DEFAULT (getdate()) NOT NULL,
    [host]       NVARCHAR (MAX)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [type]       NVARCHAR (50)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [source]     NVARCHAR (50)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [message]    NVARCHAR (MAX)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [level]      NVARCHAR (50)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [logger]     NVARCHAR (50)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [stacktrace] NVARCHAR (MAX)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [RequestId]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_AuditRequest] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ui_id]
    ON [dbo].[AuditRequest]([Id] ASC);

