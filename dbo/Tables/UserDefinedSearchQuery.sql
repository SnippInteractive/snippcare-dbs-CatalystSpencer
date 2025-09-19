CREATE TABLE [dbo].[UserDefinedSearchQuery] (
    [UserDefinedSearchQueryId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]                  INT           CONSTRAINT [DF_UserDefinedSearchQuery_Version] DEFAULT ((0)) NOT NULL,
    [UserId]                   INT           NOT NULL,
    [Name]                     VARCHAR (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CreateDate]               DATETIME      NOT NULL,
    [UserSubTypeId]            INT           NULL,
    [UserStatusId]             INT           NULL,
    [AddressStatusId]          INT           NULL,
    [AccountTypeId]            INT           NULL,
    [AuditReason]              VARCHAR (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AddressTypeId]            INT           NULL,
    [IncludeProspects]         BIT           NULL,
    CONSTRAINT [PK_UserDefinedSearchQuery] PRIMARY KEY CLUSTERED ([UserDefinedSearchQueryId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_User_UDSQuery] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_UserDefinedSearchQuery_AddressStatus] FOREIGN KEY ([AddressStatusId]) REFERENCES [dbo].[AddressStatus] ([AddressStatusId]),
    CONSTRAINT [FK_UserDefinedSearchQuery_AddressType] FOREIGN KEY ([AddressTypeId]) REFERENCES [dbo].[AddressType] ([AddressTypeId]),
    CONSTRAINT [FK_UserDefinedSearchQuery_UserDefinedSearchQuery] FOREIGN KEY ([UserDefinedSearchQueryId]) REFERENCES [dbo].[UserDefinedSearchQuery] ([UserDefinedSearchQueryId]),
    CONSTRAINT [FK_UserStatus_UDSQuery] FOREIGN KEY ([UserStatusId]) REFERENCES [dbo].[UserStatus] ([UserStatusId]),
    CONSTRAINT [FK_UserSubType_UDSQuery] FOREIGN KEY ([UserSubTypeId]) REFERENCES [dbo].[UserSubType] ([UserSubTypeId])
);


GO
CREATE NONCLUSTERED INDEX [USDQ_UserId]
    ON [dbo].[UserDefinedSearchQuery]([UserId] ASC) WITH (FILLFACTOR = 100);

