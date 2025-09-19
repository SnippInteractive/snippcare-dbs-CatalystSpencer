CREATE TABLE [dbo].[MemberMergeHistory] (
    [Id]             INT          IDENTITY (1, 1) NOT NULL,
    [UserId]         INT          NULL,
    [MergedUserId]   INT          NULL,
    [MergedDeviceId] VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Notes]          TEXT         COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [MergeDate]      DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

