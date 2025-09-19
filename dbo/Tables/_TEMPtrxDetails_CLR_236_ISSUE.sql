CREATE TABLE [dbo].[_TEMPtrxDetails_CLR_236_ISSUE] (
    [TDPromotionId]    INT           NULL,
    [TDTrxDetailID]    INT           NOT NULL,
    [TrxId]            INT           NOT NULL,
    [CreateDate]       DATETIME      NOT NULL,
    [DeviceId]         NVARCHAR (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DeviceIdentifier] INT           NOT NULL,
    [ActualDeduction]  FLOAT (53)    NULL,
    [Deducted]         FLOAT (53)    NULL,
    [AfterValue]       FLOAT (53)    NULL
);

