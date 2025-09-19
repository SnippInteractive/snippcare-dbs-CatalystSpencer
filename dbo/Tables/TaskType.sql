CREATE TABLE [dbo].[TaskType] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Name]     NVARCHAR (50) NOT NULL,
    [ClientId] INT           NOT NULL,
    [Display]  BIT           NOT NULL,
    CONSTRAINT [PK_TaskType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

