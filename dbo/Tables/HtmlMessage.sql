CREATE TABLE [dbo].[HtmlMessage] (
    [HtmlMessageId] INT           IDENTITY (0, 1) NOT NULL,
    [Version]       INT           NOT NULL,
    [ClientId]      INT           NOT NULL,
    [ApplicationId] INT           NOT NULL,
    [LanguageCode]  VARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Description]   VARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Message]       VARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Editable]      INT           NOT NULL,
    [MessageType]   VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_dbo.HtmlMessage] PRIMARY KEY CLUSTERED ([HtmlMessageId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HtmlMessage_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

