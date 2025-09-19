CREATE TABLE [dbo].[MemberLink] (
    [LinkId]          INT        IDENTITY (1, 1) NOT NULL,
    [MemberId1]       INT        NOT NULL,
    [MemberId2]       INT        NULL,
    [LinkType]        INT        NOT NULL,
    [ParentChild]     INT        NULL,
    [CreatedBy]       INT        NULL,
    [CreatedDate]     DATETIME   NULL,
    [Version]         INT        CONSTRAINT [DF_MemberLink_Version] DEFAULT ((0)) NOT NULL,
    [ConfidenceLevel] FLOAT (53) NULL,
    [CommunityId]     INT        NULL,
    CONSTRAINT [PK_MemberLink_1] PRIMARY KEY CLUSTERED ([LinkId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_MemberLink_Community] FOREIGN KEY ([CommunityId]) REFERENCES [dbo].[Community] ([CommunityId]),
    CONSTRAINT [FK_MemberLink_MemberId1] FOREIGN KEY ([MemberId1]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_MemberLink_MemberId2] FOREIGN KEY ([MemberId2]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_MemberLink_MemberLinkType] FOREIGN KEY ([LinkType]) REFERENCES [dbo].[MemberLinkType] ([MemberLinkTypeId])
);


GO
ALTER TABLE [dbo].[MemberLink] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

