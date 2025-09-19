CREATE TABLE [dbo].[__tempExtrainfo] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [DeviceId]       NVARCHAR (25)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [UserId]         INT            NULL,
    [ExtraInfo]      NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EmbossLine1]    NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [EmbossLine2]    NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [StartDate]      DATETIME2 (7)  NULL,
    [ExpirationDate] DATETIME2 (7)  NULL
);

