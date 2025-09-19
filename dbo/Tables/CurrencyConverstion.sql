CREATE TABLE [dbo].[CurrencyConverstion] (
    [Id]                    INT             IDENTITY (1, 1) NOT NULL,
    [Version]               INT             CONSTRAINT [DF_CurrencyConverstion_Version] DEFAULT ((0)) NOT NULL,
    [ClientId]              INT             NOT NULL,
    [OriginCurrencyId]      INT             NOT NULL,
    [DestinationCurrencyId] INT             NOT NULL,
    [ConversionUnit]        DECIMAL (11, 8) NULL,
    CONSTRAINT [PK_CurrencyConverstion] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_CurrencyConverstion_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

