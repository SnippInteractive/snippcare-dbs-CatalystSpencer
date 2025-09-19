CREATE TABLE [dbo].[Application] (
    [ApplicationId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]       INT           CONSTRAINT [DF_Application_Version] DEFAULT ((0)) NOT NULL,
    [Name]          NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]      INT           NOT NULL,
    CONSTRAINT [PK_Application] PRIMARY KEY CLUSTERED ([ApplicationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Application_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

