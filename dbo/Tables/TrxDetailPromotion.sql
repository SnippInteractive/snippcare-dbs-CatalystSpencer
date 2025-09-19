CREATE TABLE [dbo].[TrxDetailPromotion] (
    [Id]          INT        IDENTITY (1, 1) NOT NULL,
    [Version]     INT        DEFAULT ((0)) NOT NULL,
    [PromotionId] INT        NOT NULL,
    [TrxDetailId] INT        NOT NULL,
    [ValueUsed]   FLOAT (53) NULL,
    CONSTRAINT [PK_TrxDetailPromotion] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TrxDetailPromotion_TrxDetail] FOREIGN KEY ([TrxDetailId]) REFERENCES [dbo].[TrxDetail] ([TrxDetailID])
);

