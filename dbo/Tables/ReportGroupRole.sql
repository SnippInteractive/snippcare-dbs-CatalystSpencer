CREATE TABLE [dbo].[ReportGroupRole] (
    [ReportgroupId] INT NOT NULL,
    [RoleId]        INT NOT NULL,
    CONSTRAINT [PK_ReportGroupRole] PRIMARY KEY CLUSTERED ([ReportgroupId] ASC, [RoleId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);

