CREATE TABLE [dbo].[TrxDetail] (
    [TrxDetailID]         INT             IDENTITY (1, 1) NOT NULL,
    [Version]             INT             NOT NULL,
    [TrxID]               INT             NOT NULL,
    [LineNumber]          INT             NOT NULL,
    [ItemCode]            NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Description]         NVARCHAR (1000) NULL,
    [Anal1]               NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal2]               NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal3]               NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal4]               NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Quantity]            FLOAT (53)      NOT NULL,
    [Value]               MONEY           NOT NULL,
    [Points]              FLOAT (53)      NOT NULL,
    [PromotionID]         INT             NULL,
    [PromotionalValue]    MONEY           NULL,
    [EposDiscount]        MONEY           NULL,
    [LoyaltyDiscount]     MONEY           NULL,
    [AuthorisationNr]     NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [status]              NVARCHAR (1)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [BonusPoints]         FLOAT (53)      NULL,
    [PromotionItemId]     INT             NULL,
    [VAT]                 MONEY           NULL,
    [VATPercentage]       FLOAT (53)      NULL,
    [OriginalTrxDetailId] INT             NULL,
    [Anal5]               NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal6]               NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal7]               NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal8]               NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal9]               NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal10]              NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [HomeCurrencyCode]    NCHAR (3)       COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ConvertedNetValue]   MONEY           NULL,
    [Anal11]              NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal12]              NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal13]              NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal14]              NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal15]              VARCHAR (50)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Anal16]              VARCHAR (50)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_TrxDetail] PRIMARY KEY CLUSTERED ([TrxDetailID] ASC) WITH (FILLFACTOR = 95, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TrxDetail_TrxHeader] FOREIGN KEY ([TrxID]) REFERENCES [dbo].[TrxHeader] ([TrxId])
);


GO
ALTER TABLE [dbo].[TrxDetail] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [index_trxid]
    ON [dbo].[TrxDetail]([TrxID] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Analysiscode1]
    ON [dbo].[TrxDetail]([Anal1] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AnlaysisCode4]
    ON [dbo].[TrxDetail]([Anal4] ASC);

