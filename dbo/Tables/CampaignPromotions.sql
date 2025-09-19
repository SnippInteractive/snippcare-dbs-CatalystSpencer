CREATE TABLE [dbo].[CampaignPromotions] (
    [CampaignId] INT NOT NULL,
    [SegmentId]  INT NOT NULL,
    [MemberId]   INT NOT NULL,
    CONSTRAINT [PK_CampaignPromotions] PRIMARY KEY CLUSTERED ([CampaignId] ASC, [SegmentId] ASC) WITH (FILLFACTOR = 100)
);

