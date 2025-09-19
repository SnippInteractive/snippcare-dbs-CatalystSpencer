CREATE TABLE [dbo].[ReceiptHeader] (
    [ReceiptHeaderId] INT                IDENTITY (1, 1) NOT NULL,
    [Date]            DATETIMEOFFSET (7) NOT NULL,
    [Retailer]        VARCHAR (100)      COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [PostCode]        VARCHAR (20)       COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ReceiptTrans]    UNIQUEIDENTIFIER   NOT NULL,
    [TotalPrice]      MONEY              NOT NULL,
    [ReceiptId]       INT                NOT NULL,
    PRIMARY KEY CLUSTERED ([ReceiptHeaderId] ASC),
    FOREIGN KEY ([ReceiptId]) REFERENCES [dbo].[Receipt] ([ReceiptId])
);

