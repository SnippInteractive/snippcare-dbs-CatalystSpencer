CREATE TABLE [dbo].[MemberPromotionItemTrxHeader] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [Version]         INT             CONSTRAINT [DF__MemberPromotionItemTrxDetail_Version] DEFAULT ((0)) NOT NULL,
    [TrxHeaderId]     INT             NOT NULL,
    [PromotionItemId] INT             NOT NULL,
    [ValueUsed]       DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK__MemberPromotionItemTrxDetail] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK__MemberPromotionItemTrxHeader_PromotionItem] FOREIGN KEY ([PromotionItemId]) REFERENCES [dbo].[PromotionItem] ([Id]),
    CONSTRAINT [FK__MemberPromotionItemTrxHeader_TrxHeader] FOREIGN KEY ([TrxHeaderId]) REFERENCES [dbo].[TrxHeader] ([TrxId])
);

