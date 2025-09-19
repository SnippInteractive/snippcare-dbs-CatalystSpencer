CREATE TABLE [dbo].[ApiErrorLog] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [RequestId]         NVARCHAR (50)  NOT NULL,
    [Request]           NVARCHAR (MAX) NULL,
    [Response]          NVARCHAR (MAX) NULL,
    [CreateDate]        DATETIME       NULL,
    [Reference]         NVARCHAR (100) NULL,
    [StatusCode]        INT            NULL,
    [StatusDescription] NVARCHAR (200) NULL,
    [Method]            NVARCHAR (50)  NULL,
    [Source]            NVARCHAR (50)  NULL,
    [Deviceid]          NVARCHAR (25)  NULL,
    [Type]              NVARCHAR (50)  NULL,
    [Processed]         INT            NULL,
    CONSTRAINT [PK_ApiErrorLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);

