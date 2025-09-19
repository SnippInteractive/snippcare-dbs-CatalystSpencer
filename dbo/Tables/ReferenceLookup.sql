CREATE TABLE [dbo].[ReferenceLookup] (
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [ClientId]     INT          NOT NULL,
    [LookupType]   VARCHAR (50) NOT NULL,
    [DisplayOrder] INT          NOT NULL,
    [Active]       BIT          DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Client_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

