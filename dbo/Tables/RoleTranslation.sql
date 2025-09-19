CREATE TABLE [dbo].[RoleTranslation] (
    [RoleTranslationId] INT IDENTITY (1, 1) NOT NULL,
    [RoleId]            INT NOT NULL,
    [TranslationId]     INT NOT NULL,
    CONSTRAINT [PK_RoleTranslation] PRIMARY KEY CLUSTERED ([RoleTranslationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_RoleTranslation_Role] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Role] ([RoleID]),
    CONSTRAINT [FK_RoleTranslation_Translation] FOREIGN KEY ([TranslationId]) REFERENCES [dbo].[Translations] ([TranslationId])
);

