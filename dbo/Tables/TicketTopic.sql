CREATE TABLE [dbo].[TicketTopic] (
    [TicketTopicId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]       INT           CONSTRAINT [DF_TicketTopic_Version] DEFAULT ((0)) NOT NULL,
    [Name]          NVARCHAR (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]      INT           NOT NULL,
    [Display]       BIT           CONSTRAINT [DF_TicketTopic_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_TicketTopic] PRIMARY KEY CLUSTERED ([TicketTopicId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TicketTopic_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

