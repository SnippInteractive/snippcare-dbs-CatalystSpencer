CREATE TABLE [dbo].[WebServiceRequests] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [Request]     NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Response]    NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [RequestDate] DATETIME       CONSTRAINT [DF_WebServiceRequests_RequestDate] DEFAULT (getdate()) NOT NULL,
    [Service]     NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_WebServiceRequests] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 100)
);

