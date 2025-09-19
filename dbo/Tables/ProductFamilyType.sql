CREATE TABLE [dbo].[ProductFamilyType] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [Version]  INT            NULL,
    [Name]     NVARCHAR (100) NULL,
    [ClientId] INT            NOT NULL,
    [Display]  BIT            NULL,
    CONSTRAINT [PK_PromotionType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PromotionType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

