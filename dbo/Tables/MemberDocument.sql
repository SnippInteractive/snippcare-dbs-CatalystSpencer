CREATE TABLE [dbo].[MemberDocument] (
    [MemberDocumentId]     INT            IDENTITY (1, 1) NOT NULL,
    [Version]              INT            CONSTRAINT [DF_MemberDocuments_Version] DEFAULT ((0)) NOT NULL,
    [UserId]               INT            NULL,
    [CreateDate]           DATETIME       NOT NULL,
    [DocumentTitle]        NVARCHAR (100) NOT NULL,
    [MemberDocumentTypeId] INT            NOT NULL,
    [DocumentUrl]          NVARCHAR (250) NULL,
    CONSTRAINT [PK_MemberDocuments] PRIMARY KEY CLUSTERED ([MemberDocumentId] ASC),
    CONSTRAINT [FK_MemberDocuments_MemberDocumentType] FOREIGN KEY ([MemberDocumentTypeId]) REFERENCES [dbo].[MemberDocumentType] ([DocumentTypeId]),
    CONSTRAINT [FK_MemberDocuments_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);

