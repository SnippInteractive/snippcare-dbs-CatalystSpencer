CREATE TABLE [dbo].[AddressValidStatus] (
    [AddressValidStatusId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]              INT          CONSTRAINT [DF_AddressValidStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]                 VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]             INT          CONSTRAINT [DF_AddressValidStatus_ClientId] DEFAULT ((1)) NOT NULL,
    [Display]              BIT          CONSTRAINT [DF_AddressValidStatus_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_AddressValidStatus] PRIMARY KEY CLUSTERED ([AddressValidStatusId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AddressValidStatus_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[AddressValidStatus] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

