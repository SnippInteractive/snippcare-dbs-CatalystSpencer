CREATE TABLE [dbo].[ReceiptItem] (
    [ReceiptItemId] INT           IDENTITY (1, 1) NOT NULL,
    [ItemName]      VARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ItemPrice]     MONEY         NOT NULL,
    [ItemQTY]       INT           NOT NULL,
    [ReceiptId]     INT           NOT NULL,
    [ItemNumber]    INT           NULL,
    PRIMARY KEY CLUSTERED ([ReceiptItemId] ASC),
    FOREIGN KEY ([ReceiptId]) REFERENCES [dbo].[Receipt] ([ReceiptId])
);

