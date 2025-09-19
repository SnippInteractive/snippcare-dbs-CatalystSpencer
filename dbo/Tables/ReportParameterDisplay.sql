CREATE TABLE [dbo].[ReportParameterDisplay] (
    [ReportParameterId]        INT           NOT NULL,
    [Language]                 CHAR (2)      COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Display]                  VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ReportParameterDisplayId] INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_ReportParameterDisplay] PRIMARY KEY CLUSTERED ([ReportParameterDisplayId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);

