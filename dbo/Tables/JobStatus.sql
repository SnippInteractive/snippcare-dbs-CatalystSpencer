CREATE TABLE [dbo].[JobStatus] (
    [JobStatusId] INT            IDENTITY (1, 1) NOT NULL,
    [Version]     INT            NOT NULL,
    [Name]        NVARCHAR (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]    INT            NOT NULL,
    [Display]     BIT            NOT NULL,
    CONSTRAINT [PK_JobStatus] PRIMARY KEY CLUSTERED ([JobStatusId] ASC) WITH (FILLFACTOR = 100)
);

