CREATE TABLE [dbo].[CommunicationPlaceholderMapping] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [PropertyKey]   NVARCHAR (255) NOT NULL,
    [PropertyValue] NVARCHAR (MAX) NOT NULL,
    [TableName]     NVARCHAR (255) NOT NULL,
    [CreatedDate]   DATETIME       CONSTRAINT [DF__Communica__Creat__56007BC1] DEFAULT (getdate()) NULL,
    [ExtraInfo]     NVARCHAR (MAX) NULL,
    [SQLQuery]      NVARCHAR (500) NULL,
    [Display]       INT            NULL,
    [ClientId]      INT            NULL,
    CONSTRAINT [PK__Communic__3214EC07F60C4CCD] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

