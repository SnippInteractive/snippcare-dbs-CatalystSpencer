CREATE TABLE [SSISHelper].[SiteUpdates_Rgn_Dis_Upd] (
    [storename]     VARCHAR (100)  NULL,
    [ParentSiteRef] VARCHAR (100)  NULL,
    [SiteRef]       VARCHAR (50)   NULL,
    [SiteType]      VARCHAR (50)   NULL,
    [AddressLine1]  VARCHAR (150)  NULL,
    [AddressLine2]  VARCHAR (150)  NULL,
    [State]         VARCHAR (50)   NULL,
    [City]          VARCHAR (50)   NULL,
    [Zip]           VARCHAR (50)   NULL,
    [Country]       VARCHAR (50)   NULL,
    [Region#]       VARCHAR (50)   NULL,
    [Region_Name]   VARCHAR (50)   NULL,
    [District#]     VARCHAR (50)   NULL,
    [District_Name] VARCHAR (50)   NULL,
    [Phone]         VARCHAR (50)   NULL,
    [Active]        VARCHAR (50)   NULL,
    [ImportDate]    DATETIME       NULL,
    [Filename]      NVARCHAR (MAX) NULL,
    [ImportStatus]  NVARCHAR (10)  NULL
);

