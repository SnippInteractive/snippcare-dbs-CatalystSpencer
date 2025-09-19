CREATE TABLE [dbo].[__DATAFIXUNREGDiviceTrxData13012024] (
    [TrxId]            INT            NOT NULL,
    [TrxTypeId]        INT            NOT NULL,
    [DeviceId]         NVARCHAR (25)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [DeviceLotId]      INT            NULL,
    [DeviceIdentifier] INT            NOT NULL,
    [AccountId]        INT            NULL,
    [UNREGExtraInfo]   NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PhoneNumber]      NVARCHAR (80)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
);

