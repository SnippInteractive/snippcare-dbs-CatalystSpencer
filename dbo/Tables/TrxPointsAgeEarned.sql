CREATE TABLE [dbo].[TrxPointsAgeEarned] (
    [TrxPointsAgeID]    INT            IDENTITY (1, 1) NOT NULL,
    [Version]           INT            NOT NULL,
    [TrxID]             INT            NOT NULL,
    [SiteID]            INT            NOT NULL,
    [Channel]           NVARCHAR (50)  NULL,
    [Points]            FLOAT (53)     NULL,
    [PointsRemaining]   FLOAT (53)     NULL,
    [UserID]            INT            NULL,
    [Fixed]             INT            NULL,
    [TrxDate]           DATETIME       NULL,
    [ExpiryDate]        DATETIME       NULL,
    [FixedReason]       NVARCHAR (200) DEFAULT ('Just a standard Load') NULL,
    [DateChangedLoaded] DATETIME       DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_TrxDetailPA] PRIMARY KEY CLUSTERED ([TrxPointsAgeID] ASC) WITH (FILLFACTOR = 90, STATISTICS_NORECOMPUTE = ON)
);

