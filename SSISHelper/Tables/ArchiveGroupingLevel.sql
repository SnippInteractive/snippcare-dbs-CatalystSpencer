CREATE TABLE [SSISHelper].[ArchiveGroupingLevel] (
    [ID]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [ReferenceDate]   INT           NOT NULL,
    [UserID]          INT           NOT NULL,
    [PropertyName]    NVARCHAR (50) NOT NULL,
    [PropertyValue]   NVARCHAR (50) NOT NULL,
    [LastUpdatedDate] DATETIME      NULL
);

