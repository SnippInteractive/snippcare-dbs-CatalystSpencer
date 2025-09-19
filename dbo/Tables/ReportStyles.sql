CREATE TABLE [dbo].[ReportStyles] (
    [ClientId]    INT          NOT NULL,
    [RepLogo]     IMAGE        NULL,
    [BkColour1]   VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [FontColour1] VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [BkColour2]   VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [FontColour2] VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [BkColour3]   VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [FontColour3] VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [BkColour4]   VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [FontColour4] VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [BkColour5]   VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [FontColour5] VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_ReportStyles] PRIMARY KEY CLUSTERED ([ClientId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);

