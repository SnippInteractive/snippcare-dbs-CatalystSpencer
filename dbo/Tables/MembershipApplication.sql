CREATE TABLE [dbo].[MembershipApplication] (
    [MemberApplicationId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]             INT           CONSTRAINT [DF_MembershipApplication_Version] DEFAULT ((0)) NOT NULL,
    [MemberId]            INT           NOT NULL,
    [ApplicationDate]     DATETIME      NOT NULL,
    [ApplicationType]     SMALLINT      NOT NULL,
    [ApplicationResult]   SMALLINT      NOT NULL,
    [AccountId]           INT           NULL,
    [Comments]            VARCHAR (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DeviceId]            NVARCHAR (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_MembershipApplication] PRIMARY KEY CLUSTERED ([MemberApplicationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_MembershipApplication_MemberId] FOREIGN KEY ([MemberId]) REFERENCES [dbo].[User] ([UserId])
);

