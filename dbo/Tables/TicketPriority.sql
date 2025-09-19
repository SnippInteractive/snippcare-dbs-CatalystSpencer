CREATE TABLE [dbo].[TicketPriority] (
    [TicketPriorityId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]          INT           CONSTRAINT [DF_TicketPriority_Version] DEFAULT ((0)) NOT NULL,
    [Name]             NVARCHAR (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]         INT           NOT NULL,
    [Display]          BIT           CONSTRAINT [DF_TicketPriority_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_TicketPriority] PRIMARY KEY CLUSTERED ([TicketPriorityId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TicketPriority_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

