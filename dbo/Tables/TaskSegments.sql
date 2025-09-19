CREATE TABLE [dbo].[TaskSegments] (
    [Id]        INT IDENTITY (1, 1) NOT NULL,
    [Version]   INT NOT NULL,
    [TaskId]    INT NOT NULL,
    [SegmentId] INT NOT NULL,
    CONSTRAINT [PK_TaskSegments] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_TaskSegments_SegmentAdmin] FOREIGN KEY ([SegmentId]) REFERENCES [dbo].[SegmentAdmin] ([SegmentId]),
    CONSTRAINT [FK_TaskSegments_Task] FOREIGN KEY ([TaskId]) REFERENCES [dbo].[PromotionTasks] ([Id])
);

