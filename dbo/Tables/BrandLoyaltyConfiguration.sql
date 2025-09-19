CREATE TABLE [dbo].[BrandLoyaltyConfiguration] (
    [Id]                TINYINT       IDENTITY (1, 1) NOT NULL,
    [ConfigurationType] VARCHAR (100) NULL,
    [Configuration]     VARCHAR (MAX) NULL,
    [LastUpdated]       DATETIME      NULL,
    CONSTRAINT [PK__BrandLoy__3214EC07B3BE16DA] PRIMARY KEY CLUSTERED ([Id] ASC)
);

