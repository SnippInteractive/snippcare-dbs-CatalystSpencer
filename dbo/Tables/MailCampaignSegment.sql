CREATE TABLE [dbo].[MailCampaignSegment] (
    [MailCampaignSegmentId] INT IDENTITY (1, 1) NOT NULL,
    [SegmentWithinDays]     INT NOT NULL,
    [SegmentMinPoints]      INT NOT NULL,
    [SegmentMaxPoints]      INT NOT NULL,
    [SegmentTypeId]         INT NOT NULL,
    [AdvancedSegmentTypeId] INT NULL,
    PRIMARY KEY CLUSTERED ([MailCampaignSegmentId] ASC),
    FOREIGN KEY ([AdvancedSegmentTypeId]) REFERENCES [dbo].[MailCampaignAdvancedSegmentType] ([MailCampaignAdvancedSegmentTypeId]),
    FOREIGN KEY ([SegmentTypeId]) REFERENCES [dbo].[MailCampaignSegmentType] ([MailCampaignSegmentTypeId])
);

