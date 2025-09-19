CREATE TABLE [dbo].[Report] (
    [ReportId]    INT            IDENTITY (1, 1) NOT NULL,
    [ClientId]    INT            NULL,
    [ReportIndex] INT            NULL,
    [DisplayName] VARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Description] VARCHAR (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ActualName]  VARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Deployed]    INT            NOT NULL,
    [System]      INT            CONSTRAINT [DF_Report_System] DEFAULT ((1)) NOT NULL,
    [ReportDate]  DATETIME       NULL,
    [UserDef]     INT            CONSTRAINT [DF_Report_UserDef] DEFAULT ((1)) NULL,
    [ReportType]  INT            NULL,
    CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED ([ReportId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Report_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

