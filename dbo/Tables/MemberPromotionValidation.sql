CREATE TABLE [dbo].[MemberPromotionValidation] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [Version]     INT             CONSTRAINT [DF__MemberPromotionValidation_Version] DEFAULT ((0)) NOT NULL,
    [MemberId]    INT             NOT NULL,
    [PromotionId] INT             NOT NULL,
    [Counter]     DECIMAL (18, 2) NOT NULL,
    [Updated]     DATETIME2 (7)   NOT NULL,
    CONSTRAINT [PK__MemberPromotionValidation] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK__MemberPromotionValidation_Member] FOREIGN KEY ([MemberId]) REFERENCES [dbo].[User] ([UserId])
);

