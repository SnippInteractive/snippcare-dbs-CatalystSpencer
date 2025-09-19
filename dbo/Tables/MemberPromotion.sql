CREATE TABLE [dbo].[MemberPromotion] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [Version]         INT                CONSTRAINT [DF__MemberPromotion_Version] DEFAULT ((0)) NOT NULL,
    [MemberId]        INT                NOT NULL,
    [StartDate]       DATETIMEOFFSET (7) NOT NULL,
    [PromotionId]     INT                NOT NULL,
    [EndDate]         DATETIMEOFFSET (7) NOT NULL,
    [OffersAvailable] INT                DEFAULT ((0)) NOT NULL,
    [OffersUsed]      INT                DEFAULT ((0)) NOT NULL,
    [Updated]         DATETIMEOFFSET (7) DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK__MemberPromotion] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK__MemberPromotion_Member] FOREIGN KEY ([MemberId]) REFERENCES [dbo].[User] ([UserId])
);

