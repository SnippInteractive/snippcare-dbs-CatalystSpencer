CREATE TABLE [dbo].[MailCampaignTemplate] (
    [MailCampaignTemplateId] INT           IDENTITY (1, 1) NOT NULL,
    [Name]                   VARCHAR (50)  NOT NULL,
    [Html]                   VARCHAR (MAX) NOT NULL,
    [Type]                   VARCHAR (50)  NOT NULL,
    [LanguageCulture]        VARCHAR (5)   NOT NULL,
    [SubmissionType]         VARCHAR (50)  NOT NULL,
    [MessageType]            VARCHAR (50)  NOT NULL,
    [Message]                VARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([MailCampaignTemplateId] ASC)
);

