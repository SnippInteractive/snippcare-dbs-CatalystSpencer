CREATE TABLE [dbo].[ApplicationFormTemplate] (
    [ApplicationFormTemplateId] SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Html]                      NVARCHAR (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_ApplicationForm] PRIMARY KEY CLUSTERED ([ApplicationFormTemplateId] ASC)
);

