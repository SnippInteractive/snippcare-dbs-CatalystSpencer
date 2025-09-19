CREATE TABLE [dbo].[TrxPointsAgePriority] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [Version]      INT           NOT NULL,
    [SpendChannel] NVARCHAR (50) NULL,
    [PriorityNo]   INT           NOT NULL,
    [EarnChannel]  NVARCHAR (50) NULL
);

