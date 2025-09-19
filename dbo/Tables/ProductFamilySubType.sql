CREATE TABLE [dbo].[ProductFamilySubType] (
    [Id]                  INT            IDENTITY (1, 1) NOT NULL,
    [Version]             INT            NOT NULL,
    [Name]                NVARCHAR (100) NOT NULL,
    [ProductFamilyTypeId] INT            NOT NULL,
    [ClientId]            INT            NULL,
    [Display]             BIT            NULL,
    CONSTRAINT [PK_PromotionFamilySubType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ProductFamilySubType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

