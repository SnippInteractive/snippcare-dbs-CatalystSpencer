CREATE TABLE [dbo].[AddressStatus] (
    [AddressStatusId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]         INT          CONSTRAINT [DF_AddressStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]            VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]        INT          CONSTRAINT [DF_AddressStatus_ClientId] DEFAULT ((1)) NOT NULL,
    [Display]         BIT          CONSTRAINT [DF_AddressStatus_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_AddressStatus] PRIMARY KEY CLUSTERED ([AddressStatusId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AddressStatus_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

