CREATE TABLE [dbo].[MailCampaign] (
    [MailCampaignId]          INT           IDENTITY (1, 1) NOT NULL,
    [Title]                   VARCHAR (MAX) NULL,
    [Subject]                 VARCHAR (MAX) NULL,
    [MailCampaignTemplateId]  INT           NULL,
    [MailCampaignFrequencyId] INT           NULL,
    [MailCampaignSegmentId]   INT           NULL,
    PRIMARY KEY CLUSTERED ([MailCampaignId] ASC),
    FOREIGN KEY ([MailCampaignFrequencyId]) REFERENCES [dbo].[MailCampaignFrequency] ([MailCampaignFrequencyId]),
    FOREIGN KEY ([MailCampaignTemplateId]) REFERENCES [dbo].[MailCampaignTemplate] ([MailCampaignTemplateId]),
    FOREIGN KEY ([MailCampaignTemplateId]) REFERENCES [dbo].[MailCampaignTemplate] ([MailCampaignTemplateId])
);

