CREATE TABLE [dbo].[PromotionHitLimitType] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]  INT           CONSTRAINT [DF__PromotionHitLimitType_Version] DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (50) NOT NULL,
    [ClientId] INT           NOT NULL,
    [Display]  BIT           CONSTRAINT [DF_PromotionHitLimitType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK__PromotionHitLimitType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK__PromotionHitLimitType__Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

