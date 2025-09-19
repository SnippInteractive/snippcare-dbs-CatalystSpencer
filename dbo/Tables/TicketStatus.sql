CREATE TABLE [dbo].[TicketStatus] (
    [TicketStatusId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]        INT           CONSTRAINT [DF_TicketStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]           NVARCHAR (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]       INT           NOT NULL,
    [Display]        BIT           CONSTRAINT [DF_TicketStatus_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_TicketStatus] PRIMARY KEY CLUSTERED ([TicketStatusId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TicketStatus_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

