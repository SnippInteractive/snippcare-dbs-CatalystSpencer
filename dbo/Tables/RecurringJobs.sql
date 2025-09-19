CREATE TABLE [dbo].[RecurringJobs] (
    [Id]                         INT            IDENTITY (1, 1) NOT NULL,
    [ClientId]                   INT            NOT NULL,
    [PreAPICallStoredProcedure]  NVARCHAR (MAX) NULL,
    [APIConfiguration]           NVARCHAR (MAX) NULL,
    [PostAPICallStoredProcedure] NVARCHAR (MAX) NULL,
    [Frequency]                  NVARCHAR (20)  NOT NULL,
    [FrequencyValue]             NVARCHAR (20)  NOT NULL,
    [TimeToRun]                  NVARCHAR (20)  NOT NULL,
    [CampaignId]                 NVARCHAR (50)  NULL,
    [ExtraInfo]                  NVARCHAR (MAX) NULL,
    [StartDate]                  DATETIME       NOT NULL,
    [ExpiresOn]                  DATETIME       NULL,
    [Active]                     BIT            NOT NULL,
    [JobMethod]                  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_RecurringJobs] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_RecurringJobs_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

