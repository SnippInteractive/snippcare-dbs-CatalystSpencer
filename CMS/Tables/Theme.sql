CREATE TABLE [CMS].[Theme] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [Name]       VARCHAR (50)  NOT NULL,
    [ClientId]   INT           DEFAULT ((3)) NOT NULL,
    [IsSelected] BIT           DEFAULT ('1') NULL,
    [IsActive]   BIT           DEFAULT ('1') NOT NULL,
    [ImageUrl]   VARCHAR (MAX) NULL,
    CONSTRAINT [PK_Theme] PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
CREATE TRIGGER [CMS].[Theme_AspNet_SqlCacheNotification_Trigger] ON [CMS].[Theme]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'Theme'
                       END
