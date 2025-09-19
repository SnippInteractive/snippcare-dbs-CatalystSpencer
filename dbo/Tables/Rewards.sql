CREATE TABLE [dbo].[Rewards] (
    [Id]                      INT            IDENTITY (1, 1) NOT NULL,
    [RewardId]                INT            NOT NULL,
    [Name]                    NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Description]             NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TemplateCode]            NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [MonetaryValue]           DECIMAL (18)   NULL,
    [DeviceProfileTemplateId] INT            NULL,
    [PointsCost]              DECIMAL (18)   NULL,
    [AssetId]                 NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ImagePath]               NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [SiteId]                  INT            NULL,
    [Category]                VARCHAR (10)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Brand]                   NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [StartDate]               DATETIME       NULL,
    [ExpirationDate]          DATETIME       NULL,
    [Instructions]            NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [WalletDescription]       VARCHAR (50)   NULL,
    CONSTRAINT [PK_Rewards] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Rewards_DeviceProfileTemplate] FOREIGN KEY ([DeviceProfileTemplateId]) REFERENCES [dbo].[DeviceProfileTemplate] ([Id]),
    CONSTRAINT [FK_Rewards_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

