CREATE TABLE [dbo].[PromotionCriteria] (
    [Id]        INT            IDENTITY (1, 1) NOT NULL,
    [Version]   INT            NOT NULL,
    [Name]      NVARCHAR (500) NOT NULL,
    [IsDefault] BIT            NOT NULL,
    [ClientId]  INT            NOT NULL,
    [Display]   BIT            NOT NULL,
    CONSTRAINT [PK_PromotionCriteria] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PromotionCriteria_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

