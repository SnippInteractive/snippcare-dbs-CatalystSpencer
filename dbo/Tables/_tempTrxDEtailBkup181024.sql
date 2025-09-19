CREATE TABLE [dbo].[_tempTrxDEtailBkup181024] (
    [Id]               INT        IDENTITY (1, 1) NOT NULL,
    [Version]          INT        NOT NULL,
    [PromotionId]      INT        NOT NULL,
    [TrxDetailId]      INT        NOT NULL,
    [ValueUsed]        FLOAT (53) NULL,
    [PunchTrXType]     INT        NULL,
    [ChildPromotionId] INT        NULL,
    [ChildPunch]       FLOAT (53) NULL
);

