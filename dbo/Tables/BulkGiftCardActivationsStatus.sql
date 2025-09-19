CREATE TABLE [dbo].[BulkGiftCardActivationsStatus] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]  INT           CONSTRAINT [DF_BulkGiftCardActivationsStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Display]  BIT           NOT NULL,
    [ClientId] INT           NOT NULL,
    CONSTRAINT [PK_BulkGiftCardActivationsStatus] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_BulkGiftCardActivationsStatus_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

