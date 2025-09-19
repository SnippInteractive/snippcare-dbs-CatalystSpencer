CREATE TABLE [dbo].[VoucherCodes] (
    [DeviceID]       NVARCHAR (100)     NOT NULL,
    [UserID]         INT                NULL,
    [ClientID]       INT                NOT NULL,
    [SiteID]         INT                NULL,
    [DeviceStatusID] INT                NOT NULL,
    [ExpirationDate] DATETIMEOFFSET (7) NULL,
    [ExtReference]   NVARCHAR (100)     NULL,
    [Value]          INT                NULL,
    [ValueType]      NVARCHAR (25)      NULL,
    [Classical]      BIT                NULL,
    [DateUsed]       DATETIMEOFFSET (7) NULL,
    [DeviceLotID]    INT                NULL,
    [code_id]        BIGINT             NOT NULL,
    [usage_id]       INT                NULL,
    CONSTRAINT [PK_codes_code] PRIMARY KEY CLUSTERED ([DeviceID] ASC) WITH (FILLFACTOR = 75)
);

