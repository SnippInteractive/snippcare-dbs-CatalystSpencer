CREATE TABLE [dbo].[ShelterInfoRejectReasons] (
    [Id]       INT             IDENTITY (1, 1) NOT NULL,
    [Version]  INT             NULL,
    [Reason]   NVARCHAR (1000) NULL,
    [ClientId] INT             NULL,
    [Display]  BIT             NULL,
    CONSTRAINT [ShelterInfoRejectReasons_Id_PK] PRIMARY KEY CLUSTERED ([Id] ASC)
);

