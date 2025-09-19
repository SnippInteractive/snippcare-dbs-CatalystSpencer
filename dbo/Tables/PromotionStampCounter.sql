CREATE TABLE [dbo].[PromotionStampCounter] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [Version]            INT             NOT NULL,
    [UserId]             INT             NOT NULL,
    [PromotionId]        INT             NOT NULL,
    [TrxId]              INT             NOT NULL,
    [CounterDate]        DATETIME        NOT NULL,
    [BeforeValue]        INT             NOT NULL,
    [AfterValue]         DECIMAL (18, 2) NULL,
    [PreviousStampCount] DECIMAL (18, 2) NULL,
    [OnTheFlyQuantity]   INT             NULL,
    [DeviceIdentifier]   INT             NULL,
    CONSTRAINT [PK_PromotionStampCounter] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PromotionStampCounter_Device] FOREIGN KEY ([DeviceIdentifier]) REFERENCES [dbo].[Device] ([Id]),
    CONSTRAINT [FK_PromotionStampCounter_Promotion] FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotion] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [NCI_IdDevice]
    ON [dbo].[PromotionStampCounter]([DeviceIdentifier] ASC) WITH (FILLFACTOR = 50);


GO
CREATE NONCLUSTERED INDEX [NCI_PromotionId]
    ON [dbo].[PromotionStampCounter]([PromotionId] ASC);


GO
CREATE NONCLUSTERED INDEX [NCI_UserId]
    ON [dbo].[PromotionStampCounter]([UserId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_PSC]
    ON [dbo].[PromotionStampCounter]([UserId] ASC, [PromotionId] ASC);

