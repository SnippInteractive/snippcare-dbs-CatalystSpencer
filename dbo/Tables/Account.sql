CREATE TABLE [dbo].[Account] (
    [AccountId]           INT             IDENTITY (1, 1) NOT NULL,
    [Version]             INT             CONSTRAINT [DF_Account_Version] DEFAULT ((0)) NOT NULL,
    [UserId]              INT             NULL,
    [ExtRef]              NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AccountStatusTypeId] INT             NOT NULL,
    [Pin]                 INT             NULL,
    [ProgramId]           INT             NULL,
    [PointsPending]       DECIMAL (18, 2) NULL,
    [CreateDate]          DATETIME        NULL,
    [Version_old]         NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [MonetaryBalance]     DECIMAL (18, 2) CONSTRAINT [DF_Account_Balance] DEFAULT ((0)) NULL,
    [PointsBalance]       DECIMAL (18, 2) CONSTRAINT [DF_Account_PointsPending] DEFAULT ((0)) NULL,
    [CurrencyId]          INT             NULL,
    [OLD_MemberID]        INT             NULL,
    CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED ([AccountId] ASC) WITH (FILLFACTOR = 95, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Account_AccountStatusType] FOREIGN KEY ([AccountStatusTypeId]) REFERENCES [dbo].[AccountStatus] ([AccountStatusId]),
    CONSTRAINT [FK_Account_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [dbo].[Currency] ([Id]),
    CONSTRAINT [FK_Account_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[Account] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [Account_UserId]
    ON [dbo].[Account]([UserId] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This programId can represent the Gift card program for the accoun types of gift card or the loyalty program for accounts of type loyalty', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'ProgramId';

