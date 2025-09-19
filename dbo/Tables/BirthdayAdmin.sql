CREATE TABLE [dbo].[BirthdayAdmin] (
    [Id]                    INT      IDENTITY (1, 1) NOT NULL,
    [Version]               INT      NOT NULL,
    [BirthdayContactTypeId] INT      NOT NULL,
    [SiteId]                INT      NOT NULL,
    [UpdatedBy]             INT      NOT NULL,
    [UpdatedDate]           DATETIME NOT NULL,
    CONSTRAINT [PK_BirthdayAdmin] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_BirthdayAdmin_BirthdayContactType] FOREIGN KEY ([BirthdayContactTypeId]) REFERENCES [dbo].[BirthdayContactType] ([BirthdayContactTypeId]) ON DELETE CASCADE,
    CONSTRAINT [FK_BirthdayAdmin_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

