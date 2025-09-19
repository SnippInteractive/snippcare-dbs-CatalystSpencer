CREATE TABLE [dbo].[GenderType] (
    [GenderTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]      INT          CONSTRAINT [DF_GenderType_Version] DEFAULT ((0)) NOT NULL,
    [Name]         VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]     INT          CONSTRAINT [DF_GenderType_ClientId] DEFAULT ((1)) NOT NULL,
    [Display]      BIT          CONSTRAINT [DF_GenderType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_GenderType] PRIMARY KEY CLUSTERED ([GenderTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_GenderType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[GenderType] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

