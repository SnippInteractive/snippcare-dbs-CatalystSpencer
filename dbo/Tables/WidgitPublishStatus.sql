CREATE TABLE [dbo].[WidgitPublishStatus] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Version]       INT            NOT NULL,
    [WidgitName]    NVARCHAR (100) NOT NULL,
    [PublishStatus] BIT            NOT NULL,
    [ClientId]      INT            NULL,
    CONSTRAINT [PKY_WidgitPublishStatus] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);

