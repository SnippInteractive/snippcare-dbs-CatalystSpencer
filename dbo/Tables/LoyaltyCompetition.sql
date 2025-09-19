CREATE TABLE [dbo].[LoyaltyCompetition] (
    [LoyaltyCompetitionId] INT                IDENTITY (1, 1) NOT NULL,
    [Name]                 NVARCHAR (50)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [HtmlContentId]        INT                NOT NULL,
    [LoyaltyProgramId]     INT                NOT NULL,
    [StartDateTime]        DATETIMEOFFSET (7) NULL,
    [EndDateTime]          DATETIMEOFFSET (7) NULL,
    [Version]              INT                DEFAULT ((0)) NOT NULL,
    [MaxEntries]           INT                DEFAULT ((1)) NOT NULL,
    [DrawDateTime]         DATETIMEOFFSET (7) NULL,
    [Active]               BIT                DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([LoyaltyCompetitionId] ASC),
    CONSTRAINT [FK_LoyaltyCompetition_HtmlContent] FOREIGN KEY ([HtmlContentId]) REFERENCES [dbo].[HtmlContent] ([ContentId])
);

