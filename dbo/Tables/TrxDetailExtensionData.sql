CREATE TABLE [dbo].[TrxDetailExtensionData] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [Version]       INT           NOT NULL,
    [TrxDetailId]   INT           NOT NULL,
    [PropertyName]  VARCHAR (50)  NOT NULL,
    [PropertyValue] VARCHAR (MAX) NULL,
    [DisplayOrder]  BIT           NULL,
    [Deleted]       BIT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([TrxDetailId]) REFERENCES [dbo].[TrxDetail] ([TrxDetailID])
);

