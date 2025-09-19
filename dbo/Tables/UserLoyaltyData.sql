CREATE TABLE [dbo].[UserLoyaltyData] (
    [UserLoyaltyDataId]        INT                IDENTITY (1, 1) NOT NULL,
    [Version]                  INT                CONSTRAINT [DF_UserLoyaltyData_Version] DEFAULT ((0)) NOT NULL,
    [LoyaltySignupDate]        DATETIMEOFFSET (7) NULL,
    [LoyaltyApplicationSigned] INT                NULL,
    [Recruiter]                NVARCHAR (50)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [CreatedBy]                INT                NULL,
    [LastUpdated]              DATETIMEOFFSET (7) CONSTRAINT [DF_UserLoyaltyData_LastUpdated] DEFAULT (getdate()) NOT NULL,
    [FirstReaction]            DATETIMEOFFSET (7) NULL,
    [LastReaction]             DATETIMEOFFSET (7) NULL,
    [TurnoverYTD]              MONEY              NULL,
    [TurnoverLastYear]         MONEY              NULL,
    [TurnoverAll]              MONEY              NULL,
    [RedeemVoucherAttempts]    INT                CONSTRAINT [DF_UserLoyaltyData_RedeemVoucherAttempts] DEFAULT ((0)) NOT NULL,
    [LastRedeemVoucherDate]    DATETIMEOFFSET (7) NULL,
    [TurnoverAllTemp]          DECIMAL (18, 2)    NULL,
    CONSTRAINT [PK_UserLoyaltyData] PRIMARY KEY CLUSTERED ([UserLoyaltyDataId] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_UserLoyaltyData_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[UserLoyaltyData] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

