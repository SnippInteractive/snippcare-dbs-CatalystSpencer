CREATE TABLE [dbo].[TicketDocuments] (
    [id]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [TicketId]    INT             NULL,
    [Filepath]    VARCHAR (200)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [FileContent] VARBINARY (MAX) NULL,
    [FileType]    VARCHAR (5)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Version]     INT             CONSTRAINT [DF_TicketDocuments_Version] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_TicketDocuments] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TicketDocuments_TicketId] FOREIGN KEY ([TicketId]) REFERENCES [dbo].[Ticket] ([TicketId])
);

