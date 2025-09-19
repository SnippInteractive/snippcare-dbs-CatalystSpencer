CREATE TABLE [SSISHelper].[Transaction_Export] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [EposTrxId]       BIGINT         NULL,
    [reference]       NVARCHAR (50)  NULL,
    [TrxDate]         NVARCHAR (10)  NULL,
    [LoyaltyDeviceID] NVARCHAR (25)  NULL,
    [MemberID]        INT            NULL,
    [MobilePhone]     NVARCHAR (100) NULL,
    [CatTrxID]        INT            NOT NULL,
    [TotalAmount]     MONEY          NULL,
    [#items]          INT            NULL,
    [ExportDate]      DATETIME       NULL,
    [Filename]        NVARCHAR (MAX) NULL,
    [ExportStatus]    NVARCHAR (10)  NULL
);

