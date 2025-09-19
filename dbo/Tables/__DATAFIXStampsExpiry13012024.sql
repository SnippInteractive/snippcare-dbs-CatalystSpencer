CREATE TABLE [dbo].[__DATAFIXStampsExpiry13012024] (
    [TrxId]            INT                NOT NULL,
    [DeviceId]         NVARCHAR (25)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DeviceIdentifier] INT                NOT NULL,
    [PromotionId]      INT                NULL,
    [Quantity]         FLOAT (53)         NULL,
    [TrxDetailId]      INT                NOT NULL,
    [Value]            MONEY              NOT NULL,
    [UserId]           INT                NULL,
    [CreateDate]       DATETIME           NOT NULL,
    [TrxDate]          DATETIMEOFFSET (7) NOT NULL
);

