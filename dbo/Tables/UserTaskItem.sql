CREATE TABLE [dbo].[UserTaskItem] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [TaskItemId]      INT                NOT NULL,
    [UserId]          INT                NOT NULL,
    [TaskCompleted]   INT                DEFAULT ((0)) NOT NULL,
    [TargetAchieved]  BIT                DEFAULT ((0)) NOT NULL,
    [CreatedDateTime] DATETIMEOFFSET (7) NOT NULL,
    [UpdatedDateTime] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_UserTaskId] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_TaskItemId] FOREIGN KEY ([TaskItemId]) REFERENCES [dbo].[PromotionTasksItem] ([Id]) ON DELETE CASCADE ON UPDATE CASCADE
);

