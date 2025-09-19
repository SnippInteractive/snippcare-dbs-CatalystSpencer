CREATE TABLE [SSISHelper].[User_Export] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [MemberID]         INT            NULL,
    [Firstname]        NVARCHAR (50)  NULL,
    [Lastname]         NVARCHAR (70)  NOT NULL,
    [MemberType]       VARCHAR (12)   NOT NULL,
    [CreateDate]       DATETIME       NULL,
    [LastUpdatedDate]  DATETIME       NULL,
    [Email]            NVARCHAR (200) NULL,
    [MobilePhone]      NVARCHAR (200) NULL,
    [LoyaltyDeviceID]  NVARCHAR (100) NOT NULL,
    [#JewelryPunches]  INT            NULL,
    [#JewelryVouchers] INT            NULL,
    [#TShirtPunches]   INT            NULL,
    [#TShirtVouchers]  INT            NULL,
    [ContactByEmail]   INT            NULL,
    [ExportDate]       DATETIME       NULL,
    [Filename]         NVARCHAR (MAX) NULL,
    [ExportStatus]     NVARCHAR (15)  NULL
);

