CREATE TABLE [dbo].[TierUsers] (
    [Id]            INT      IDENTITY (1, 1) NOT NULL,
    [TierId]        INT      NOT NULL,
    [UserId]        INT      NOT NULL,
    [StartOfPeriod] DATETIME NULL,
    [EndOfPeriod]   DATETIME NULL,
    [Enabled]       BIT      NULL,
    [ThresholdTo]   MONEY    NULL,
    CONSTRAINT [PK_TierUsers] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_TierUsers_TierAdmin] FOREIGN KEY ([TierId]) REFERENCES [dbo].[TierAdmin] ([Id]),
    CONSTRAINT [FK_TierUsers_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[TierUsers] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

