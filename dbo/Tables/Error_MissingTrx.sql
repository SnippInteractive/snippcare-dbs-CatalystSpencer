CREATE TABLE [dbo].[Error_MissingTrx] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [CreateDate]  DATETIME       NOT NULL,
    [TrxId]       INT            NOT NULL,
    [StatusCode]  INT            NULL,
    [Description] NVARCHAR (500) NULL,
    CONSTRAINT [PK_Error_MissingTrx] PRIMARY KEY CLUSTERED ([Id] ASC)
);

