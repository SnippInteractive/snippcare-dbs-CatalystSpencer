CREATE TABLE [dbo].[CampaignJob] (
    [Id]          INT           NOT NULL,
    [Type]        VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [CampaignId]  INT           NOT NULL,
    [CreateDate]  DATETIME      NULL,
    [Processed]   BIT           NULL,
    [ProcessDate] DATETIME      NULL,
    CONSTRAINT [PK_CampaignJob] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_CampaignJob_CampaignJob] FOREIGN KEY ([CampaignId]) REFERENCES [dbo].[Campaign] ([CampaignId])
);

