CREATE TABLE [dbo].[TrxType] (
    [TrxTypeId]     INT           IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]      INT           NOT NULL,
    [Version]       INT           CONSTRAINT [DF_TrxType_Version] DEFAULT ((0)) NOT NULL,
    [Display]       BIT           CONSTRAINT [DF_TrxType_Display] DEFAULT ((1)) NOT NULL,
    [NegativeValue] BIT           NULL,
    CONSTRAINT [PK_TrxType] PRIMARY KEY CLUSTERED ([TrxTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TrxType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[TrxType] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

