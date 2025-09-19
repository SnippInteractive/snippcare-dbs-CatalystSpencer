CREATE TABLE [dbo].[AddressType] (
    [AddressTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]       INT           CONSTRAINT [DF_AddressType_Version] DEFAULT ((0)) NOT NULL,
    [Name]          NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]      INT           CONSTRAINT [DF_AddressType_ClientId] DEFAULT ((1)) NOT NULL,
    [Display]       BIT           CONSTRAINT [DF_AddressType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_AddressType] PRIMARY KEY CLUSTERED ([AddressTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AddressType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

