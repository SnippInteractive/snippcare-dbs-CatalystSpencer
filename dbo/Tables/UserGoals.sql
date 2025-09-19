CREATE TABLE [dbo].[UserGoals] (
    [userid]       INT         NOT NULL,
    [goal_points]  INT         NULL,
    [points_total] INT         NULL,
    [goal_active]  VARCHAR (5) NULL,
    [created]      DATETIME    NULL,
    [modified]     DATETIME    NULL,
    [GoalId]       INT         IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [pk_usreGoals] PRIMARY KEY CLUSTERED ([GoalId] ASC),
    CONSTRAINT [FK_UserGoals] FOREIGN KEY ([userid]) REFERENCES [dbo].[User] ([UserId])
);

