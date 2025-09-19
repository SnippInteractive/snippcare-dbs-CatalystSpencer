CREATE TABLE [dbo].[PromotionValidation] (
    [Id]                        INT             IDENTITY (1, 1) NOT NULL,
    [Version]                   INT             CONSTRAINT [DF__PromotionValidation_Version] DEFAULT ((0)) NOT NULL,
    [PromotionValidationTypeId] INT             NOT NULL,
    [PromotionId]               INT             NOT NULL,
    [Value]                     DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK__PromotionValidation] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK__PromotionValidation_PromotionValidationType] FOREIGN KEY ([PromotionValidationTypeId]) REFERENCES [dbo].[PromotionValidationType] ([Id])
);

