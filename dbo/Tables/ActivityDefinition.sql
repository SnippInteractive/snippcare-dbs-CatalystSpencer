CREATE TABLE [dbo].[ActivityDefinition] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [ActivityTypeId]  INT            NOT NULL,
    [Description]     NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TagLine]         NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Points]          INT            NULL,
    [Reference]       NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Image]           NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [CategoryId]      INT            NULL,
    [PointTypeId]     INT            DEFAULT ((1)) NOT NULL,
    [PointAmount]     INT            DEFAULT ((0)) NULL,
    [StartDate]       DATETIME2 (7)  NULL,
    [EndDate]         DATETIME2 (7)  NULL,
    [Enable]          BIT            NULL,
    [OrdinalPosition] INT            NULL,
    [Location]        NVARCHAR (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_ActivityDefinition] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ActivityDefinition_ActivityCategoryType] FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[ActivityCategoryType] ([Id]),
    CONSTRAINT [FK_ActivityDefinition_ActivityType] FOREIGN KEY ([ActivityTypeId]) REFERENCES [dbo].[ActivityType] ([Id])
);

