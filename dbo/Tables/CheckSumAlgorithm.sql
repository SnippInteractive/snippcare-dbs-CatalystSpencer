CREATE TABLE [dbo].[CheckSumAlgorithm] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]  INT           CONSTRAINT [DF_CheckSumAlgorithm_Version] DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId] INT           NOT NULL,
    [Display]  BIT           CONSTRAINT [DF_CheckSumAlgorithm_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_CheckSumAlgorithm] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_CheckSumAlgorithm_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

