CREATE TABLE [dbo].[ActivityCategory] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [Name]     NVARCHAR (250) NULL,
    [ClientId] INT            NULL,
    [Display]  BIT            NULL,
    CONSTRAINT [PK_ActivityCategory_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

