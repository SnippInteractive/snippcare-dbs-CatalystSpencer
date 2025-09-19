CREATE TABLE [dbo].[VirtualPointPromotions] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [PromotionId]    INT             NULL,
    [VoucherId]      VARCHAR (50)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TrxId]          INT             NULL,
    [LineNumber]     INT             NULL,
    [PromotionValue] DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_VirtualPointPromotions] PRIMARY KEY CLUSTERED ([Id] ASC)
);

