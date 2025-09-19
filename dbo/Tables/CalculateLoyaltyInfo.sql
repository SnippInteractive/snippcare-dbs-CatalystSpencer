CREATE TABLE [dbo].[CalculateLoyaltyInfo] (
    [Id]               INT           IDENTITY (1, 1) NOT NULL,
    [Version]          INT           CONSTRAINT [DF_CalculateLoyaltyInfo] DEFAULT ((0)) NOT NULL,
    [TrxId]            INT           NOT NULL,
    [SiteId]           INT           NOT NULL,
    [LoyaltyProfileId] INT           NULL,
    [MemberId]         INT           NULL,
    [Created]          DATETIME2 (7) DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CalculateLoyaltyInfo] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_CalculateLoyaltyInfo_LoyaltyDeviceProfileTemplate] FOREIGN KEY ([LoyaltyProfileId]) REFERENCES [dbo].[LoyaltyDeviceProfileTemplate] ([Id]),
    CONSTRAINT [FK_CalculateLoyaltyInfo_SiteId] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_CalculateLoyaltyInfo_TrxId] FOREIGN KEY ([TrxId]) REFERENCES [dbo].[TrxHeader] ([TrxId]),
    CONSTRAINT [FK_CalculateLoyaltyInfo_UserId] FOREIGN KEY ([MemberId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [uc_Transaction_Site] UNIQUE NONCLUSTERED ([TrxId] ASC, [SiteId] ASC)
);

