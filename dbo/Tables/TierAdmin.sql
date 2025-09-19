CREATE TABLE [dbo].[TierAdmin] (
    [Id]                      INT             IDENTITY (1, 1) NOT NULL,
    [Version]                 INT             NULL,
    [LoyaltyProfileId]        INT             NULL,
    [Description]             NVARCHAR (200)  NULL,
    [TierTypeId]              INT             NOT NULL,
    [TierDuration]            INT             NULL,
    [StartMonth]              DATETIME        NULL,
    [Validity]                INT             NULL,
    [TierLinkTypeId]          INT             NOT NULL,
    [ThresholdFrom]           DECIMAL (18, 2) NULL,
    [ThresholdTo]             DECIMAL (18, 2) NULL,
    [GoodWill]                DECIMAL (18, 2) NULL,
    [CreatedDate]             DATETIME        NULL,
    [CreatedBy]               INT             NULL,
    [UpdatedDate]             DATETIME        NULL,
    [UpdatedBy]               INT             NULL,
    [ImageUrl]                VARCHAR (MAX)   DEFAULT (NULL) NULL,
    [QualifiedTierMultiplier] MONEY           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TierAdmin] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_TierAdmin_CreatedByUser] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_TierAdmin_LoyaltyProfile] FOREIGN KEY ([LoyaltyProfileId]) REFERENCES [dbo].[LoyaltyDeviceProfileTemplate] ([Id]),
    CONSTRAINT [FK_TierAdmin_TierLinkType] FOREIGN KEY ([TierLinkTypeId]) REFERENCES [dbo].[TierLinkType] ([TierLinkTypeId]),
    CONSTRAINT [FK_TierAdmin_TierType] FOREIGN KEY ([TierTypeId]) REFERENCES [dbo].[TierType] ([TierTypeId])
);


GO
ALTER TABLE [dbo].[TierAdmin] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

