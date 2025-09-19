CREATE TABLE [dbo].[User] (
    [UserId]                          INT                IDENTITY (1400000, 1) NOT NULL,
    [Version]                         INT                NOT NULL,
    [UserTypeId]                      INT                NOT NULL,
    [UserSubTypeId]                   INT                NULL,
    [Username]                        NVARCHAR (80)      COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Password]                        NVARCHAR (100)     COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SiteId]                          INT                NOT NULL,
    [CreateDate]                      DATETIME           NOT NULL,
    [FirstLoginDate]                  DATETIME           NULL,
    [LastLoginDate]                   DATETIME           NULL,
    [ExpirationDate]                  DATETIME           NULL,
    [UserStatusId]                    INT                NOT NULL,
    [PersonalDetailsId]               INT                NULL,
    [UserLoyaltyDataId]               INT                NULL,
    [Notes]                           NVARCHAR (MAX)     NULL,
    [ExtReference]                    NVARCHAR (50)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LegacyNumber]                    NVARCHAR (25)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LanguageId]                      INT                NOT NULL,
    [ContactByEmail]                  INT                NULL,
    [ContactByMail]                   INT                NULL,
    [ContactBySms]                    INT                NULL,
    [ContactByPhone]                  INT                NULL,
    [ContactStatus]                   SMALLINT           NULL,
    [LastUpdatedDate]                 DATETIME           NULL,
    [UserStatusChangedDate]           DATETIME           NULL,
    [ValidationCodeExpirationDate]    DATETIME           NULL,
    [ValidationCode]                  NVARCHAR (100)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EmailAddressAuthenticated]       BIT                NULL,
    [AccActivationReminderSentOn]     DATETIMEOFFSET (7) NULL,
    [ApplicationId]                   INT                NULL,
    [LoginAttemptCounter]             INT                NULL,
    [UserAccountLocked]               INT                NULL,
    [LockoutDateTime]                 DATETIMEOFFSET (7) NULL,
    [UnauthenticatedUniqueIdentifier] UNIQUEIDENTIFIER   NULL,
    [DuplicateStatus]                 INT                NULL,
    [DuplicateDate]                   DATETIME           NULL,
    [PreferredContactTypeId]          INT                NULL,
    [MemberSegmentTypeId]             INT                NULL,
    [Region]                          NVARCHAR (50)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Recruiter]                       NVARCHAR (50)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Magazine]                        INT                NULL,
    [LastUpdatedBySiteId]             INT                NULL,
    [NameIdentifier]                  VARCHAR (36)       COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([UserId] ASC) WITH (FILLFACTOR = 95),
    FOREIGN KEY ([LastUpdatedBySiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_User_Language] FOREIGN KEY ([LanguageId]) REFERENCES [dbo].[Language] ([LanguageId]),
    CONSTRAINT [FK_User_PersonalDetails] FOREIGN KEY ([PersonalDetailsId]) REFERENCES [dbo].[PersonalDetails] ([PersonalDetailsId]),
    CONSTRAINT [FK_User_SiteId] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_User_UserLoyaltyData] FOREIGN KEY ([UserLoyaltyDataId]) REFERENCES [dbo].[UserLoyaltyData] ([UserLoyaltyDataId]),
    CONSTRAINT [FK_User_UserStatus] FOREIGN KEY ([UserStatusId]) REFERENCES [dbo].[UserStatus] ([UserStatusId]),
    CONSTRAINT [FK_User_UserSubType] FOREIGN KEY ([UserSubTypeId]) REFERENCES [dbo].[UserSubType] ([UserSubTypeId]),
    CONSTRAINT [FK_User_UserType1] FOREIGN KEY ([UserTypeId]) REFERENCES [dbo].[UserType] ([UserTypeId])
);


GO
ALTER TABLE [dbo].[User] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [IX_User_SiteId]
    ON [dbo].[User]([SiteId] ASC)
    INCLUDE([UserId], [UserTypeId], [UserStatusId], [PersonalDetailsId]);


GO
CREATE NONCLUSTERED INDEX [IX_User_Username]
    ON [dbo].[User]([Username] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_User_UserSubType]
    ON [dbo].[User]([UserSubTypeId] ASC)
    INCLUDE([UserId], [Version], [UserTypeId], [SiteId], [CreateDate], [UserStatusId], [PersonalDetailsId], [UserLoyaltyDataId]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_User_UserTypeId]
    ON [dbo].[User]([UserTypeId] ASC)
    INCLUDE([UserId], [Username]);


GO
CREATE NONCLUSTERED INDEX [IX_User_PersonalDetailsID]
    ON [dbo].[User]([PersonalDetailsId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_User_UserStatusId]
    ON [dbo].[User]([UserStatusId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_User_UserLoyaltyDataId]
    ON [dbo].[User]([UserLoyaltyDataId] ASC)
    INCLUDE([UserId], [SiteId]);

