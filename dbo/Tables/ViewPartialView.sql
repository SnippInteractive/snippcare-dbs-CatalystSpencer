CREATE TABLE [dbo].[ViewPartialView] (
    [Id]            INT IDENTITY (1, 1) NOT NULL,
    [Version]       INT CONSTRAINT [DF_ViewPartialView_Version] DEFAULT ((0)) NOT NULL,
    [ViewId]        INT NOT NULL,
    [PartialViewId] INT NOT NULL,
    CONSTRAINT [PK_ViewPartialView] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ViewPartialView_PartialView] FOREIGN KEY ([PartialViewId]) REFERENCES [dbo].[PartialView] ([PartialViewId]),
    CONSTRAINT [FK_ViewPartialView_View] FOREIGN KEY ([ViewId]) REFERENCES [dbo].[View] ([ViewId])
);

