CREATE TABLE [Schedular].[Fulfilment] (
    [Id]                INT IDENTITY (1, 1) NOT NULL,
    [UserId]            INT NOT NULL,
    [QuantityFulfilled] INT NOT NULL,
    [IsMaxLimitReached] BIT NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

