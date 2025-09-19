CREATE TABLE [dbo].[__Litter_Skus] (
    [Brand]                          NVARCHAR (255) NULL,
    [Product]                        NVARCHAR (255) NULL,
    [Geography]                      NVARCHAR (255) NULL,
    [Time]                           NVARCHAR (255) NULL,
    [UPC 10 digit]                   NVARCHAR (255) NULL,
    [Category Name]                  NVARCHAR (255) NULL,
    [Manufacturer Name]              NVARCHAR (255) NULL,
    [Type Of Litter / Deodorant]     NVARCHAR (255) NULL,
    [Total Pounds]                   FLOAT (53)     NULL,
    [Absorbency Level]               NVARCHAR (255) NULL,
    [Flavor / Scent]                 NVARCHAR (255) NULL,
    [Price per Unit]                 MONEY          NULL,
    [Dollar Sales]                   MONEY          NULL,
    [Dollar Sales Index vs Year Ago] FLOAT (53)     NULL,
    [Unit Sales]                     FLOAT (53)     NULL,
    [Unit Sales Index vs Year Ago]   FLOAT (53)     NULL
);

