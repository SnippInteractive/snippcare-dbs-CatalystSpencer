CREATE TABLE [dbo].[ReservationStatus] (
    [ReservationStatusId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]             INT          NOT NULL,
    [Name]                VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId]            INT          NOT NULL,
    [Display]             BIT          NOT NULL,
    PRIMARY KEY CLUSTERED ([ReservationStatusId] ASC),
    FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

