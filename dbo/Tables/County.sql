CREATE TABLE [dbo].[County] (
    [CountyId]   INT           IDENTITY (1, 1) NOT NULL,
    [Version]    INT           NOT NULL,
    [Name]       NVARCHAR (50) NOT NULL,
    [ClientId]   INT           NOT NULL,
    [Display]    BIT           NOT NULL,
    [CountryId]  INT           NULL,
    [CountyCode] NVARCHAR (3)  NOT NULL,
    CONSTRAINT [PK_County] PRIMARY KEY CLUSTERED ([CountyId] ASC),
    CONSTRAINT [FK_County_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

