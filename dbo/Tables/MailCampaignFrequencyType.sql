CREATE TABLE [dbo].[MailCampaignFrequencyType] (
    [MailCampaignFrequencyTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]                     INT          NOT NULL,
    [Name]                        VARCHAR (50) NOT NULL,
    [ClientId]                    INT          NOT NULL,
    [Display]                     BIT          NOT NULL,
    PRIMARY KEY CLUSTERED ([MailCampaignFrequencyTypeId] ASC),
    FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

