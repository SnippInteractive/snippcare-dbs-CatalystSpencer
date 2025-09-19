CREATE TABLE [dbo].[UserSubType] (
    [UserSubTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]       INT           CONSTRAINT [DF_UserSubType_Version] DEFAULT ((0)) NOT NULL,
    [Name]          NVARCHAR (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [UserTypeId]    INT           NULL,
    [ClientId]      INT           NOT NULL,
    [Display]       BIT           CONSTRAINT [DF_UserSubType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_UserSubType] PRIMARY KEY CLUSTERED ([UserSubTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_UserSubType_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_UserSubType_UserType] FOREIGN KEY ([UserTypeId]) REFERENCES [dbo].[UserType] ([UserTypeId])
);


GO
ALTER TABLE [dbo].[UserSubType] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

