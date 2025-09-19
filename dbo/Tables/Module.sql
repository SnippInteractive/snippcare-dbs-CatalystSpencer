CREATE TABLE [dbo].[Module] (
    [ModuleId]           INT          IDENTITY (1, 1) NOT NULL,
    [Version]            INT          CONSTRAINT [DF_Module_Version] DEFAULT ((0)) NOT NULL,
    [ClientId]           INT          NOT NULL,
    [InternalName]       VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ModuleGroup]        VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ModuleOrder]        INT          NULL,
    [AssignPermissionId] INT          NULL,
    [EditPermissionId]   INT          NULL,
    [ViewPermissionId]   INT          NULL,
    [Href]               VARCHAR (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Controller]         VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Action]             VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [RootElement]        INT          NULL,
    [Area]               VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ApplicationId]      INT          DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Module] PRIMARY KEY CLUSTERED ([ModuleId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Module_ApplicationId] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId]),
    CONSTRAINT [FK_Module_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

