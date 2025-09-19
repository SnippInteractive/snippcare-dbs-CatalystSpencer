CREATE TABLE [dbo].[Receipt] (
    [ReceiptId]        INT                IDENTITY (1, 1) NOT NULL,
    [ClientEventId]    UNIQUEIDENTIFIER   NOT NULL,
    [SnippEventId]     UNIQUEIDENTIFIER   NOT NULL,
    [TransTime]        DATETIMEOFFSET (7) NOT NULL,
    [CampaignId]       UNIQUEIDENTIFIER   NOT NULL,
    [ImageUrl]         VARCHAR (MAX)      COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [UserId]           VARCHAR (100)      COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ValidationTypeId] VARCHAR (50)       COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ProcessingTypeId] VARCHAR (50)       COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ProcessingStatus] VARCHAR (50)       COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ProcTime]         DATETIMEOFFSET (7) NOT NULL,
    [ImageStatus]      VARCHAR (50)       COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CreatedDate]      DATETIMEOFFSET (7) NULL,
    [LastUpdatedDate]  DATETIMEOFFSET (7) NULL,
    [Version]          INT                NULL,
    [SnippUserId]      INT                NULL,
    [ExtraInfo]        NVARCHAR (MAX)     NULL,
    [Response]         NVARCHAR (MAX)     NULL,
    PRIMARY KEY CLUSTERED ([ReceiptId] ASC)
);

