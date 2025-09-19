CREATE TABLE [dbo].[PromotionMemberProfileItemType] (
    [Id]                  INT            IDENTITY (1, 1) NOT NULL,
    [Version]             INT            NOT NULL,
    [Name]                NVARCHAR (250) NOT NULL,
    [IsMemberProfileItem] BIT            NOT NULL,
    [ClientId]            INT            NOT NULL,
    [Display]             BIT            NOT NULL,
    [CategoryId]          INT            NULL,
    CONSTRAINT [PK__PromotionMemberProfileItemType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);

