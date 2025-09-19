CREATE TABLE [dbo].[PromotionSegments] (
    [Id]          INT IDENTITY (1, 1) NOT NULL,
    [Version]     INT NOT NULL,
    [PromotionId] INT NOT NULL,
    [SegmentId]   INT NOT NULL,
    CONSTRAINT [PK_PromotionSegments] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PromotionSegments_Promotion] FOREIGN KEY ([PromotionId]) REFERENCES [dbo].[Promotion] ([Id]),
    CONSTRAINT [FK_PromotionSegments_SegmentAdmin] FOREIGN KEY ([SegmentId]) REFERENCES [dbo].[SegmentAdmin] ([SegmentId])
);

