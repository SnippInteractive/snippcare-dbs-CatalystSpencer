CREATE TABLE [dbo].[TrxDetailStampCard] (
    [Id]               INT        IDENTITY (1, 1) NOT NULL,
    [Version]          INT        CONSTRAINT [DF__TrxDetail__Versi__12E98E70] DEFAULT ((0)) NOT NULL,
    [PromotionId]      INT        NOT NULL,
    [TrxDetailId]      INT        NOT NULL,
    [ValueUsed]        FLOAT (53) NULL,
    [PunchTrXType]     INT        NULL,
    [ChildPromotionId] INT        NULL,
    [ChildPunch]       FLOAT (53) NULL,
    CONSTRAINT [PK_TrxDetailStampCard] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TrxDetailStampCard_TrxDetail] FOREIGN KEY ([TrxDetailId]) REFERENCES [dbo].[TrxDetail] ([TrxDetailID])
);


GO
CREATE NONCLUSTERED INDEX [IX_TrxDetail_SC]
    ON [dbo].[TrxDetailStampCard]([TrxDetailId] ASC);

