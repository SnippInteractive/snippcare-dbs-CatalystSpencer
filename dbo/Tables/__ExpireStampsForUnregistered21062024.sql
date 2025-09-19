CREATE TABLE [dbo].[__ExpireStampsForUnregistered21062024] (
    [DeviceId]          NVARCHAR (25)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DeviceIdentifier]  INT             NULL,
    [TrxId]             INT             NULL,
    [UserID]            INT             NULL,
    [TrxTypeId]         INT             NULL,
    [ValueUsed]         DECIMAL (18, 2) NULL,
    [PromotionId]       INT             NULL,
    [PromotionCategory] NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AfterValue]        DECIMAL (18, 2) NULL,
    [PromotionName]     NVARCHAR (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TrxDate]           DATETIME        NULL
);

