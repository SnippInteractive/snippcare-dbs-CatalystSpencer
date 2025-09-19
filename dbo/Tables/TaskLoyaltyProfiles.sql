CREATE TABLE [dbo].[TaskLoyaltyProfiles] (
    [Id]               INT IDENTITY (1, 1) NOT NULL,
    [Version]          INT CONSTRAINT [DF_TaskLoyaltyProfiles_Version] DEFAULT ((0)) NOT NULL,
    [TaskId]           INT NOT NULL,
    [LoyaltyProfileId] INT NOT NULL,
    CONSTRAINT [PK_TaskLoyaltyProfiles] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_LoyaltyDeviceProfileTemplate_TaskLoyaltyProfiles] FOREIGN KEY ([LoyaltyProfileId]) REFERENCES [dbo].[LoyaltyDeviceProfileTemplate] ([Id]),
    CONSTRAINT [FK_TaskLoyaltyProfiles_Task] FOREIGN KEY ([TaskId]) REFERENCES [dbo].[PromotionTasks] ([Id]),
    CONSTRAINT [IX_Unique_Task_LoyaltyDeviceProfile] UNIQUE NONCLUSTERED ([TaskId] ASC, [LoyaltyProfileId] ASC)
);

