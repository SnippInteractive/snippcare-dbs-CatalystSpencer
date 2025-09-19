CREATE TABLE [dbo].[LoyaltyError$] (
    [Store]              FLOAT (53)     NULL,
    [Reg #]              FLOAT (53)     NULL,
    [Trans #]            FLOAT (53)     NULL,
    [Trans Date]         DATETIME       NULL,
    [Reconciled]         BIT            NOT NULL,
    [Last Error Message] NVARCHAR (255) NULL,
    [Siteid]             INT            NULL,
    [trxdate]            DATETIME       NULL,
    [Id]                 INT            NULL
);

