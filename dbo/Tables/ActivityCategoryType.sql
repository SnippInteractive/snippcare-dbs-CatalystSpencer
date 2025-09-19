CREATE TABLE [dbo].[ActivityCategoryType] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [Name]               NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ClientId]           INT           NULL,
    [Display]            BIT           NULL,
    [ActivityCategoryId] INT           NULL,
    CONSTRAINT [PK_ActivityCategory] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ActivityCategoryType_ActivityCategory] FOREIGN KEY ([ActivityCategoryId]) REFERENCES [dbo].[ActivityCategory] ([Id])
);

