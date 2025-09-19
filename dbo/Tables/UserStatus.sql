CREATE TABLE [dbo].[UserStatus] (
    [UserStatusId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]      INT          CONSTRAINT [DF_UserStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]         VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]     INT          CONSTRAINT [DF_UserStatus_ClientId] DEFAULT ((1)) NOT NULL,
    [Display]      BIT          CONSTRAINT [DF_UserStatus_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_UserStatus] PRIMARY KEY CLUSTERED ([UserStatusId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_UserStatus_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[UserStatus] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

