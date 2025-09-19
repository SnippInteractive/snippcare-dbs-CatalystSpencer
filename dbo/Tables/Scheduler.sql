CREATE TABLE [dbo].[Scheduler] (
    [SchedulerId]          INT            IDENTITY (1, 1) NOT NULL,
    [Name]                 NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Description]          NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [UpdatedDate]          DATETIME       NULL,
    [UpdatedBy]            INT            NULL,
    [ClientId]             INT            NULL,
    [Version]              INT            NULL,
    [FrequencyTypeId]      INT            NULL,
    [RecursWeek]           INT            NULL,
    [RecursDays]           INT            NULL,
    [StartTime]            NVARCHAR (10)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EndTime]              NVARCHAR (10)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [RecursMonthDay]       INT            NULL,
    [RecursMonth]          INT            NULL,
    [RecursMonthDaysOrder] INT            NULL,
    [IsActive]             BIT            CONSTRAINT [DF_Scheduler_IsActive] DEFAULT ((1)) NULL,
    [StartDate]            DATETIME       NULL,
    [EndDate]              DATETIME       NULL,
    CONSTRAINT [PK_Scheduler] PRIMARY KEY CLUSTERED ([SchedulerId] ASC),
    CONSTRAINT [FK_Scheduler_Scheduler_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

