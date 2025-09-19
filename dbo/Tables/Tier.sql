CREATE TABLE [dbo].[Tier] (
    [Id]                     INT             IDENTITY (1, 1) NOT NULL,
    [Name]                   NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Description]            VARCHAR (1000)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EngagePointRangeFrom]   INT             NOT NULL,
    [EngagePointRangeTo]     INT             NOT NULL,
    [PurchasePointRangeFrom] INT             NOT NULL,
    [PurchasePointRangeTo]   INT             NOT NULL,
    [LoyaltyDeviceProfileId] INT             NULL,
    [TierTimeCounterTypeId]  INT             NOT NULL,
    [TierTimeCounter]        INT             NULL,
    [ClientId]               INT             NOT NULL,
    [Display]                BIT             NULL,
    [SpendAmount]            DECIMAL (10, 2) NULL,
    [TimeSpanTypeId]         INT             NULL,
    [SpanAmount]             INT             NULL,
    CONSTRAINT [PK_Tier] PRIMARY KEY CLUSTERED ([Id] ASC)
);

