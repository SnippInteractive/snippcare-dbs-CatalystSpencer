CREATE TABLE [dbo].[ClientConfig] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [Version]      INT            CONSTRAINT [DF_ClientConfig_Version] DEFAULT ((0)) NOT NULL,
    [ClientId]     INT            NOT NULL,
    [Key]          VARCHAR (50)   NOT NULL,
    [Value]        NVARCHAR (MAX) NOT NULL,
    [LanguageCode] NVARCHAR (3)   DEFAULT ('all') NOT NULL,
    [Environment]  NVARCHAR (10)  DEFAULT ('all') NOT NULL,
    CONSTRAINT [PK_ClientConfig] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ClientConfig_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_ClientConfig_ClientConfig] FOREIGN KEY ([Id]) REFERENCES [dbo].[ClientConfig] ([Id]),
    CONSTRAINT [IX_ClientConfig] UNIQUE NONCLUSTERED ([Key] ASC, [ClientId] ASC, [LanguageCode] ASC, [Environment] ASC)
);


GO
CREATE TRIGGER [dbo].[ClientConfig_AspNet_SqlCacheNotification_Trigger] ON [dbo].[ClientConfig]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'ClientConfig'
                       END
