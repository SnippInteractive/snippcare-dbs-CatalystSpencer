CREATE TABLE [dbo].[PromotionOfferType] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [Version]  INT            CONSTRAINT [DF__PormotionOfferType_Version] DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId] INT            NOT NULL,
    [Display]  BIT            NOT NULL,
    CONSTRAINT [PK__PormotionOfferType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK__PormotionOfferType__Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

