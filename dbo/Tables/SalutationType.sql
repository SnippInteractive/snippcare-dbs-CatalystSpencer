CREATE TABLE [dbo].[SalutationType] (
    [SalutationTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [Name]             VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Version]          INT          CONSTRAINT [DF_SalutationType_Version] DEFAULT ((0)) NOT NULL,
    [ClientId]         INT          CONSTRAINT [DF_SalutationType_ClientId] DEFAULT ((1)) NOT NULL,
    [Display]          BIT          CONSTRAINT [DF_SalutationType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_SalutationType] PRIMARY KEY CLUSTERED ([SalutationTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SalutationType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

