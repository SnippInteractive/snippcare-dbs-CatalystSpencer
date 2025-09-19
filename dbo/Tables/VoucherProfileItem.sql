CREATE TABLE [dbo].[VoucherProfileItem] (
    [Id]                       INT           IDENTITY (1, 1) NOT NULL,
    [Version]                  INT           CONSTRAINT [DF__VoucherItem_Version] DEFAULT ((0)) NOT NULL,
    [VoucherProfileId]         INT           NOT NULL,
    [VoucherProfileItemTypeId] INT           NOT NULL,
    [Code]                     NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Mode]                     NVARCHAR (20) DEFAULT ('') NULL,
    [FilterType]               INT           NULL,
    [ItemIncludeExclude]       NVARCHAR (25) NULL,
    [VoucherItemGroupId]       INT           NULL,
    CONSTRAINT [PK__VoucherProfileItemItem] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK__VoucherProfileItem__VoucherDeviceProfileTemplate] FOREIGN KEY ([VoucherProfileId]) REFERENCES [dbo].[VoucherDeviceProfileTemplate] ([Id]),
    CONSTRAINT [FK__VoucherProfileItem_PromotionItemType] FOREIGN KEY ([VoucherProfileItemTypeId]) REFERENCES [dbo].[PromotionItemType] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_ItemCode]
    ON [dbo].[VoucherProfileItem]([Code] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_VoucherProfileItem]
    ON [dbo].[VoucherProfileItem]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_VoucherProfileItem_Code]
    ON [dbo].[VoucherProfileItem]([Code] ASC);

