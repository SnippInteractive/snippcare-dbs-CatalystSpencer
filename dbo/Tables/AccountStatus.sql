CREATE TABLE [dbo].[AccountStatus] (
    [AccountStatusId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]         INT           CONSTRAINT [DF_AccountStatusType_Version] DEFAULT ((0)) NOT NULL,
    [Name]            NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]        INT           NOT NULL,
    [Display]         BIT           CONSTRAINT [DF_AccountStatus_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_AccountStatusType] PRIMARY KEY CLUSTERED ([AccountStatusId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountStatusType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[AccountStatus] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [UX_AccountStatus_Column]
    ON [dbo].[AccountStatus]([ClientId] ASC, [Name] ASC);

