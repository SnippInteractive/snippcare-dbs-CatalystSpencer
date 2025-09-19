CREATE TABLE [dbo].[PartialView] (
    [PartialViewId]    INT            IDENTITY (1, 1) NOT NULL,
    [Version]          INT            CONSTRAINT [DF_PartialView_Version] DEFAULT ((0)) NOT NULL,
    [Name]             VARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]         INT            NOT NULL,
    [ViewPermissionId] INT            NULL,
    [EditPermissionId] INT            NULL,
    [Type]             VARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Config]           NVARCHAR (MAX) DEFAULT ('') NULL,
    CONSTRAINT [PK_PartialView] PRIMARY KEY CLUSTERED ([PartialViewId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PartialView_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

