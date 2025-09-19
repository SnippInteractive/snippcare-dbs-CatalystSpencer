CREATE TABLE [dbo].[tempUser] (
    [userid]    INT           NOT NULL,
    [Username]  NVARCHAR (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [firstname] NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [lastname]  NVARCHAR (70) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
);

