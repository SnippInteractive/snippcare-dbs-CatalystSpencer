CREATE TABLE [dbo].[ReceiptItemInvalidStatus] (
    [ReceiptId]        INT           NOT NULL,
    [InvalidShortText] VARCHAR (100) NULL,
    [InvalidReason]    VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([ReceiptId] ASC)
);

