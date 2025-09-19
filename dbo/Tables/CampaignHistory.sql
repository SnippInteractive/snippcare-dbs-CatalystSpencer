CREATE TABLE [dbo].[CampaignHistory] (
    [CampaignHistoryId] INT           IDENTITY (1, 1) NOT NULL,
    [CampaignId]        INT           NOT NULL,
    [SysUserId]         INT           NOT NULL,
    [RunDate]           SMALLDATETIME NOT NULL,
    CONSTRAINT [PK_CampaignHistory] PRIMARY KEY CLUSTERED ([CampaignHistoryId] ASC) WITH (FILLFACTOR = 100)
);

