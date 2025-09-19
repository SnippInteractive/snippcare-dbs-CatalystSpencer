CREATE TABLE [dbo].[CalculateLoyaltyOffer] (
    [Id]                     INT             IDENTITY (1, 1) NOT NULL,
    [Version]                INT             CONSTRAINT [DF_CalculateLoyaltyOffer] DEFAULT ((0)) NOT NULL,
    [CalculateLoyaltyInfoId] INT             NOT NULL,
    [Offervalue]             DECIMAL (18, 2) NOT NULL,
    [OfferType]              INT             NOT NULL,
    [OfferMetadata]          NVARCHAR (MAX)  NOT NULL,
    [PromotionId]            INT             NULL,
    [PromotionType]          INT             NOT NULL,
    [VoucherId]              NVARCHAR (25)   NULL,
    CONSTRAINT [PK_CalculateLoyaltyOffer] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [CK_CalculateLoyaltyOffer_Promotion] CHECK ([PromotionId] IS NOT NULL OR [VoucherId] IS NOT NULL AND len([VoucherId])>(0)),
    CONSTRAINT [FK_CalculateLoyaltyOffer_CalculateLoyaltyInfo] FOREIGN KEY ([CalculateLoyaltyInfoId]) REFERENCES [dbo].[CalculateLoyaltyInfo] ([Id])
);

