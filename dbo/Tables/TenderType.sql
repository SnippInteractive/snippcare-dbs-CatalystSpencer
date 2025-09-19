CREATE TABLE [dbo].[TenderType] (
    [TenderTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]      INT          CONSTRAINT [DF_TenderType_Version] DEFAULT ((0)) NOT NULL,
    [Name]         VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]     INT          NOT NULL,
    [Display]      BIT          CONSTRAINT [DF_TenderType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_TenderType] PRIMARY KEY CLUSTERED ([TenderTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TenderType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[TenderType] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

