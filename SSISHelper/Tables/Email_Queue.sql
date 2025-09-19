CREATE TABLE [SSISHelper].[Email_Queue] (
    [Id]            BIGINT             IDENTITY (1, 1) NOT NULL,
    [TemplateID]    NVARCHAR (MAX)     NOT NULL,
    [Version]       INT                CONSTRAINT [DF_Email_Queue_Version] DEFAULT ((0)) NOT NULL,
    [Source]        NVARCHAR (200)     NOT NULL,
    [ContactTypeID] INT                NOT NULL,
    [PlaceHolders]  NVARCHAR (MAX)     NOT NULL,
    [DateScheduled] DATETIMEOFFSET (7) NULL,
    [DateSent]      DATETIMEOFFSET (7) NULL,
    [ExtraInfo]     NVARCHAR (MAX)     NOT NULL,
    [UserId]        INT                NULL,
    [SysUserId]     INT                NULL,
    CONSTRAINT [PK_EmailQueue] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_email_Queue_ContactType] FOREIGN KEY ([ContactTypeID]) REFERENCES [dbo].[ContactType] ([ContactTypeId]),
    CONSTRAINT [FK_email_Queue_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);

