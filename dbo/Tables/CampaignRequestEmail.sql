CREATE TABLE [dbo].[CampaignRequestEmail] (
    [CampReqId]   INT NOT NULL,
    [Sent]        INT NULL,
    [Opened]      INT NULL,
    [Clicked]     INT NULL,
    [Bounced]     INT NULL,
    [Unsubscribe] INT NULL,
    CONSTRAINT [PK_CampaignRequestEmail] PRIMARY KEY CLUSTERED ([CampReqId] ASC) WITH (FILLFACTOR = 100)
);

