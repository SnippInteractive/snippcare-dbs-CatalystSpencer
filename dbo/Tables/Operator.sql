CREATE TABLE [dbo].[Operator] (
    [ID]         INT           IDENTITY (1, 1) NOT NULL,
    [Version]    INT           CONSTRAINT [DF_Operator_Version] DEFAULT ((0)) NOT NULL,
    [OperatorId] VARCHAR (10)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Name]       VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ClientId]   INT           NOT NULL,
    CONSTRAINT [FK_Client_Operator] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Operator]
    ON [dbo].[Operator]([ID] ASC) WITH (FILLFACTOR = 100);

