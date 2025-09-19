CREATE TABLE [dbo].[ReportParameterType] (
    [ParamTypeID] INT          NOT NULL,
    [Description] VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_ReportParameterType] PRIMARY KEY CLUSTERED ([ParamTypeID] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);

