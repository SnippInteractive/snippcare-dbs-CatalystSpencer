CREATE TABLE [dbo].[CampaignRequestDetails] (
    [CampreqDetId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [CampreqId]    INT            NOT NULL,
    [Comment]      VARCHAR (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Timestamp]    DATETIME       NOT NULL,
    CONSTRAINT [PK_CampaignRequestDetails] PRIMARY KEY CLUSTERED ([CampreqDetId] ASC) WITH (FILLFACTOR = 100)
);

