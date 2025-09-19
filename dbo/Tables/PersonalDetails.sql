CREATE TABLE [dbo].[PersonalDetails] (
    [PersonalDetailsId]               INT           IDENTITY (1, 1) NOT NULL,
    [Version]                         INT           CONSTRAINT [DF_PersonalDetails_Version] DEFAULT ((0)) NOT NULL,
    [Firstname]                       NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Lastname]                        NVARCHAR (70) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Middlename]                      NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DateOfBirth]                     DATETIME      NULL,
    [GenderTypeId]                    INT           NULL,
    [TitleTypeId]                     INT           NULL,
    [SalutationId]                    INT           NULL,
    [NationalityId]                   INT           NULL,
    [ReferenceId]                     INT           NULL,
    [PhoneticFirstnamePrimaryKey]     NVARCHAR (4)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PhoneticFirstnameAlternativeKey] NVARCHAR (4)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PhoneticLastnamePrimaryKey]      NVARCHAR (4)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PhoneticLastnameAlternativeKey]  NVARCHAR (4)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LastUpdated]                     DATETIME      NULL,
    [Title]                           NVARCHAR (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_PersonalDetails] PRIMARY KEY CLUSTERED ([PersonalDetailsId] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_PersonalDetails_GenderType] FOREIGN KEY ([GenderTypeId]) REFERENCES [dbo].[GenderType] ([GenderTypeId]),
    CONSTRAINT [FK_PersonalDetails_Nationality] FOREIGN KEY ([NationalityId]) REFERENCES [dbo].[Nationality] ([NationalityId]),
    CONSTRAINT [FK_PersonalDetails_SalutationType] FOREIGN KEY ([SalutationId]) REFERENCES [dbo].[SalutationType] ([SalutationTypeId]),
    CONSTRAINT [FK_PersonalDetails_TitleType] FOREIGN KEY ([TitleTypeId]) REFERENCES [dbo].[TitleType] ([TitleTypeId])
);


GO
ALTER TABLE [dbo].[PersonalDetails] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [PD_FLD]
    ON [dbo].[PersonalDetails]([Firstname] ASC, [Lastname] ASC, [DateOfBirth] ASC) WITH (FILLFACTOR = 95);

