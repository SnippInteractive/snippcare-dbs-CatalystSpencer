CREATE TABLE [dbo].[ReferenceDataType] (
    [ReferenceDataTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [Name]                VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [IsEditable]          BIT          NOT NULL,
    [ClientId]            INT          NOT NULL,
    CONSTRAINT [PK_ReferenceDataType] PRIMARY KEY CLUSTERED ([ReferenceDataTypeId] ASC),
    CONSTRAINT [FK_ReferenceDataType_ReferenceDataType] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

