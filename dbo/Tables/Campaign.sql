CREATE TABLE [dbo].[Campaign] (
    [CampaignId]             INT            IDENTITY (1, 1) NOT NULL,
    [ClientId]               INT            NULL,
    [CampaignName]           VARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Description]            VARCHAR (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [StartDate]              SMALLDATETIME  NULL,
    [EndDate]                SMALLDATETIME  NULL,
    [OutputType]             TINYINT        NULL,
    [OutputMsg]              TEXT           COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TemplateId]             INT            NULL,
    [Coordinator]            INT            NULL,
    [SiteId]                 INT            NULL,
    [TrackerId]              VARCHAR (20)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PostDispatchType]       CHAR (3)       COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PostReturnType]         SMALLINT       NULL,
    [TestRun]                BIT            CONSTRAINT [DF_Campaign_TestRun] DEFAULT ((1)) NULL,
    [ExportDirectory]        VARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [OutputByMemberOrDevice] SMALLINT       NULL,
    [RoundOffType]           INT            CONSTRAINT [DF_Campaign_RoundOffType] DEFAULT ((0)) NULL,
    [RoundOffPlace]          INT            NULL,
    [old_id]                 INT            NULL,
    CONSTRAINT [PK_Campaign] PRIMARY KEY CLUSTERED ([CampaignId] ASC) WITH (FILLFACTOR = 100)
);

