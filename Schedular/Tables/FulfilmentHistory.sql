CREATE TABLE [Schedular].[FulfilmentHistory] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [FulfilmentId]   INT            NOT NULL,
    [UserId]         INT            NOT NULL,
    [ConfirmationId] NVARCHAR (200) NOT NULL,
    [RewardTrxId]    INT            NOT NULL,
    [RewardAmount]   INT            NOT NULL,
    [FulfilledDate]  DATETIME       NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([FulfilmentId]) REFERENCES [Schedular].[Fulfilment] ([Id])
);

