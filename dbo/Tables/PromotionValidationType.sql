CREATE TABLE [dbo].[PromotionValidationType] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]  INT           CONSTRAINT [DF__PromotionValidationType_Version] DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Display]  BIT           NOT NULL,
    [ClientId] INT           NOT NULL,
    CONSTRAINT [PK__PromotionValidationType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK__PromotionValidationType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

