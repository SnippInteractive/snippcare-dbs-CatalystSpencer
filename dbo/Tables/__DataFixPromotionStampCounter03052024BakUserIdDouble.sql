CREATE TABLE [dbo].[__DataFixPromotionStampCounter03052024BakUserIdDouble] (
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
    [DeviceIdentifier]   INT             NULL
);

