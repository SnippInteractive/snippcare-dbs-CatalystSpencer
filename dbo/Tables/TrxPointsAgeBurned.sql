CREATE TABLE [dbo].[TrxPointsAgeBurned] (
    [TrxPointsBurnID]   INT           IDENTITY (1, 1) NOT NULL,
    [Version]           INT           NOT NULL,
    [TrxID]             INT           NOT NULL,
    [TrxPointsAgeID]    INT           NOT NULL,
    [SiteID]            INT           NOT NULL,
    [Channel]           NVARCHAR (50) NULL,
    [PointsBurnt]       FLOAT (53)    NULL,
    [UserID]            INT           NULL,
    [TrxDate]           DATETIME      NULL,
    [DateChangedLoaded] DATETIME      DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_TrxPABurn] PRIMARY KEY CLUSTERED ([TrxPointsBurnID] ASC) WITH (FILLFACTOR = 90, STATISTICS_NORECOMPUTE = ON)
);

