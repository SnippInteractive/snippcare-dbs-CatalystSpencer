CREATE TABLE [dbo].[ReportGroupDetails] (
    [ReportGroupId] INT NOT NULL,
    [ReportId]      INT NOT NULL,
    CONSTRAINT [PK_ReportGroup] PRIMARY KEY CLUSTERED ([ReportGroupId] ASC, [ReportId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ReportGroup_Report] FOREIGN KEY ([ReportId]) REFERENCES [dbo].[Report] ([ReportId])
);

