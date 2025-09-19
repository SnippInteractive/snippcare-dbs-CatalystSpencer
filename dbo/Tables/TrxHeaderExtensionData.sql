CREATE TABLE [dbo].[TrxHeaderExtensionData] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [Version]       INT           NOT NULL,
    [TrxId]         INT           NOT NULL,
    [PropertyName]  VARCHAR (50)  NOT NULL,
    [PropertyValue] VARCHAR (MAX) NULL,
    [DisplayOrder]  BIT           NULL,
    [Deleted]       BIT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([TrxId]) REFERENCES [dbo].[TrxHeader] ([TrxId])
);

