CREATE TABLE [dbo].[MailCampaignFrequency] (
    [MailCampaignFrequencyId] INT          IDENTITY (1, 1) NOT NULL,
    [FrequencyTypeId]         INT          NOT NULL,
    [XDays]                   INT          NOT NULL,
    [StartDate]               DATETIME     NOT NULL,
    [EndDate]                 DATETIME     NOT NULL,
    [TimeZone]                VARCHAR (50) NOT NULL,
    [ScheduledHour]           INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([MailCampaignFrequencyId] ASC),
    FOREIGN KEY ([FrequencyTypeId]) REFERENCES [dbo].[MailCampaignFrequencyType] ([MailCampaignFrequencyTypeId])
);

