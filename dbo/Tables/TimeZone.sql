CREATE TABLE [dbo].[TimeZone] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (100) NOT NULL,
    [Standard]     NVARCHAR (100) NOT NULL,
    [Version]      INT            NULL,
    [ClientId]     INT            NULL,
    [DisplayOrder] INT            NULL,
    [Display]      BIT            NULL,
    CONSTRAINT [PK_TimeZone_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

