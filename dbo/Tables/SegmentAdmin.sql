CREATE TABLE [dbo].[SegmentAdmin] (
    [SegmentId]   INT            IDENTITY (1, 1) NOT NULL,
    [Version]     INT            NOT NULL,
    [Name]        NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Description] NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ValidFrom]   DATE           NULL,
    [ValidTo]     DATE           NULL,
    [EndTime]     TIME (7)       NULL,
    [Tier]        BIT            NULL,
    [SiteId]      INT            NULL,
    [Createdby]   INT            NULL,
    [CreatedDate] DATETIME       NULL,
    [UpdatedDate] DATETIME       NULL,
    [Deleted]     BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SegmentAdmin] PRIMARY KEY CLUSTERED ([SegmentId] ASC),
    CONSTRAINT [FK_SegmentAdmin_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);


GO
ALTER TABLE [dbo].[SegmentAdmin] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

