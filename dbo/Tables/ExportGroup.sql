CREATE TABLE [dbo].[ExportGroup] (
    [ExportGroupType]           CHAR (1)      COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ExportGroupId]             INT           NOT NULL,
    [FieldIds]                  VARCHAR (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TurnoverInPeriodStartDate] DATE          NULL,
    [TurnoverInPeriodEndDate]   DATE          NULL,
    [ExCampId]                  INT           NULL,
    [NewCampId]                 VARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_ExportGroup] PRIMARY KEY CLUSTERED ([ExportGroupType] ASC, [ExportGroupId] ASC) WITH (FILLFACTOR = 80)
);

