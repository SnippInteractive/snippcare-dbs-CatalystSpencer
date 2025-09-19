CREATE TABLE [dbo].[test_cdc] (
    [TransAK]             INT            NULL,
    [TransDate]           DATETIME       NULL,
    [Reference]           NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TerminalDescription] NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TerminalId]          NVARCHAR (25)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [OperatorId]          NVARCHAR (10)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PassedPosTrxId]      NVARCHAR (50)  NULL,
    [ReservationId]       NVARCHAR (25)  NULL,
    [IsAnonymousAK]       BIT            NULL,
    [IsAnonymousName]     NVARCHAR (20)  NULL,
    [DataSourceId]        INT            NOT NULL,
    [CTOperation]         CHAR (1)       COLLATE Latin1_General_BIN NULL
);

