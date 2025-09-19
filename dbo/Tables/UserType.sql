CREATE TABLE [dbo].[UserType] (
    [UserTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]    INT          CONSTRAINT [DF_UserType_Version] DEFAULT ((0)) NOT NULL,
    [Name]       VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]   INT          CONSTRAINT [DF_UserType_ClientId] DEFAULT ((1)) NOT NULL,
    [Display]    BIT          CONSTRAINT [DF_UserType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_UserType] PRIMARY KEY CLUSTERED ([UserTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_UserType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[UserType] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

