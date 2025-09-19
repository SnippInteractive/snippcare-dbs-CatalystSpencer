CREATE TABLE [dbo].[ContactHistory] (
    [ContactHistoryId] INT            IDENTITY (1, 1) NOT NULL,
    [Version]          INT            CONSTRAINT [DF_ContactHistory_Version] DEFAULT ((0)) NOT NULL,
    [UserId]           INT            NOT NULL,
    [ContactTypeId]    INT            NOT NULL,
    [ContactDate]      DATETIME       NOT NULL,
    [Comments]         NVARCHAR (MAX) NULL,
    [CampaignId]       INT            NULL,
    [SegmentId]        INT            NULL,
    [CampaignName]     VARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [SegmentName]      VARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ControlGroup]     BIT            NULL,
    CONSTRAINT [PK_ContactHistory] PRIMARY KEY CLUSTERED ([ContactHistoryId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ContactHistory_ContactType] FOREIGN KEY ([ContactTypeId]) REFERENCES [dbo].[ContactType] ([ContactTypeId]),
    CONSTRAINT [FK_ContactHistory_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[ContactHistory] NOCHECK CONSTRAINT [FK_ContactHistory_ContactType];


GO
ALTER TABLE [dbo].[ContactHistory] NOCHECK CONSTRAINT [FK_ContactHistory_User];


GO
CREATE NONCLUSTERED INDEX [IX_ContactHistory_UserId]
    ON [dbo].[ContactHistory]([UserId] ASC);

