CREATE TABLE [dbo].[UserProfileExtraInfo] (
    [UserProfileExtraInfoId] INT             IDENTITY (1, 1) NOT NULL,
    [UserId]                 INT             NULL,
    [SocialSecurity]         NVARCHAR (50)   NULL,
    [Covercard]              NVARCHAR (20)   NULL,
    [MpiId]                  NVARCHAR (13)   NULL,
    [BodyWeight]             DECIMAL (18, 2) NULL,
    [BodyHeight]             DECIMAL (18, 2) NULL,
    [Waist]                  DECIMAL (18, 2) NULL,
    [Insurance]              NVARCHAR (200)  NULL,
    [InsuranceNumber]        NVARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([UserProfileExtraInfoId] ASC)
);

