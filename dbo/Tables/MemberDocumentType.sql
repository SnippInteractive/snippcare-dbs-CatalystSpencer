CREATE TABLE [dbo].[MemberDocumentType] (
    [DocumentTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]        INT           CONSTRAINT [DF_MemberDocumentType_Version] DEFAULT ((0)) NOT NULL,
    [Name]           NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]       INT           NOT NULL,
    [Display]        INT           CONSTRAINT [DF_MemberDocumentType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_MemberDocumentType] PRIMARY KEY CLUSTERED ([DocumentTypeId] ASC),
    CONSTRAINT [FK_MemberDocumentType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

