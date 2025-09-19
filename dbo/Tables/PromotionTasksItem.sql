CREATE TABLE [dbo].[PromotionTasksItem] (
    [Id]             INT IDENTITY (1, 1) NOT NULL,
    [Version]        INT CONSTRAINT [DF_TaskItem_Version] DEFAULT ((0)) NOT NULL,
    [TaskId]         INT NOT NULL,
    [TaskTypeId]     INT NOT NULL,
    [TaskItemTypeId] INT NULL,
    [Quantity]       INT NULL,
    CONSTRAINT [PK_TaskItem] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PromotionTasks] FOREIGN KEY ([TaskId]) REFERENCES [dbo].[PromotionTasks] ([Id]),
    CONSTRAINT [FK_TasksType] FOREIGN KEY ([TaskTypeId]) REFERENCES [dbo].[TaskType] ([Id])
);

