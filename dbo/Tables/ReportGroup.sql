CREATE TABLE [dbo].[ReportGroup] (
    [ReportGroupId] INT           IDENTITY (1, 1) NOT NULL,
    [ClientId]      INT           NOT NULL,
    [Description]   VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Display]       BIT           CONSTRAINT [DF__tmp_rg_xx__Displ__19A0ADA0] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_ReportGroup_1] PRIMARY KEY CLUSTERED ([ReportGroupId] ASC, [ClientId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ReportGroup_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

