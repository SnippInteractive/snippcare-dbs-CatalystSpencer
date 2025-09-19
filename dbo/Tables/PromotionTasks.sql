CREATE TABLE [dbo].[PromotionTasks] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (100) NULL,
    [Description]       NVARCHAR (255) NULL,
    [StartDate]         DATETIME2 (7)  NOT NULL,
    [EndDate]           DATETIME2 (7)  NULL,
    [Enabled]           BIT            NOT NULL,
    [OfferValue]        FLOAT (53)     NULL,
    [MaxUsagePerMember] INT            NULL,
    [UsageLimit]        INT            NULL,
    [OfferTypeId]       INT            NULL,
    [RewardId]          INT            NULL,
    [VoucherId]         INT            NULL,
    [SiteId]            INT            NOT NULL,
    [ImageUrl]          NVARCHAR (250) NULL,
    CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);

