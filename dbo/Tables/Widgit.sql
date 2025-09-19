CREATE TABLE [dbo].[Widgit] (
    [WidgitId]      INT           IDENTITY (1, 1) NOT NULL,
    [Version]       INT           CONSTRAINT [DF_Widgit_Version] DEFAULT ((0)) NOT NULL,
    [PartialViewId] INT           NOT NULL,
    [Name]          VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ControlType]   VARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [DisplayOrder]  INT           NULL,
    [DisplayStatus] INT           CONSTRAINT [DF_Widgit_DisplayStatus] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Widgit] PRIMARY KEY CLUSTERED ([WidgitId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Widgit_PartialView] FOREIGN KEY ([PartialViewId]) REFERENCES [dbo].[PartialView] ([PartialViewId]),
    CONSTRAINT [ucCodes] UNIQUE NONCLUSTERED ([PartialViewId] ASC, [DisplayOrder] ASC) WITH (FILLFACTOR = 100)
);

