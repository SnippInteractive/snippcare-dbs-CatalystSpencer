CREATE TABLE [dbo].[Permission] (
    [PermissionId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]      INT          CONSTRAINT [DF_Permission_Version] DEFAULT ((0)) NOT NULL,
    [Name]         VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_Permission] PRIMARY KEY CLUSTERED ([PermissionId] ASC) WITH (FILLFACTOR = 100)
);

