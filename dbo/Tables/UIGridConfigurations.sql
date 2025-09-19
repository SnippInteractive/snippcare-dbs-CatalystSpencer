CREATE TABLE [dbo].[UIGridConfigurations] (
    [GridConfigId] INT            IDENTITY (1, 1) NOT NULL,
    [Version]      INT            CONSTRAINT [DF_UIGridConfigurations_Version] DEFAULT ((0)) NOT NULL,
    [GridName]     NVARCHAR (75)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ColumnName]   NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Databinding]  NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [DisplayOrder] INT            NOT NULL,
    [ClientId]     INT            NOT NULL,
    CONSTRAINT [PK_UIGridConfigurations] PRIMARY KEY CLUSTERED ([GridConfigId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_UIGridConfigurations_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

