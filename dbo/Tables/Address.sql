CREATE TABLE [dbo].[Address] (
    [AddressId]                    INT            IDENTITY (1, 1) NOT NULL,
    [Version]                      INT            CONSTRAINT [DF_Address_Version] DEFAULT ((0)) NOT NULL,
    [AddressTypeId]                INT            NOT NULL,
    [AddressStatusId]              INT            NOT NULL,
    [AddressLine1]                 NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AddressLine2]                 NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [HouseName]                    NVARCHAR (80)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [HouseNumber]                  NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Street]                       NVARCHAR (80)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Locality]                     NVARCHAR (80)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [City]                         NVARCHAR (60)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Zip]                          NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [CountryId]                    INT            NOT NULL,
    [ValidFromDate]                DATETIME       NULL,
    [AddressValidStatusId]         INT            NOT NULL,
    [PostBox]                      INT            NULL,
    [PostBoxNumber]                NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ContactDetailsId]             INT            NULL,
    [LastUpdatedBy]                INT            NULL,
    [LastUpdated]                  DATETIME       NULL,
    [PhoneticStreetPrimaryKey]     NVARCHAR (4)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PhoneticStreetAlternativeKey] NVARCHAR (4)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PhoneticCityPrimaryKey]       NVARCHAR (4)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PhoneticCityAlternativeKey]   NVARCHAR (4)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Notes]                        NVARCHAR (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [StateId]                      INT            NULL,
    CONSTRAINT [PK_Address_1] PRIMARY KEY CLUSTERED ([AddressId] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_Address_AddressStatus] FOREIGN KEY ([AddressStatusId]) REFERENCES [dbo].[AddressStatus] ([AddressStatusId]),
    CONSTRAINT [FK_Address_AddressType] FOREIGN KEY ([AddressTypeId]) REFERENCES [dbo].[AddressType] ([AddressTypeId]),
    CONSTRAINT [FK_Address_AddressValidStatus] FOREIGN KEY ([AddressValidStatusId]) REFERENCES [dbo].[AddressValidStatus] ([AddressValidStatusId]),
    CONSTRAINT [FK_Address_ContactDetails] FOREIGN KEY ([ContactDetailsId]) REFERENCES [dbo].[ContactDetails] ([ContactDetailsId]),
    CONSTRAINT [FK_Address_Country] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_Address_LastUpdatedBy] FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[Address] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [Address_AddressStatusId]
    ON [dbo].[Address]([AddressStatusId] ASC)
    INCLUDE([AddressId], [AddressValidStatusId]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [Address_Country]
    ON [dbo].[Address]([CountryId] ASC)
    INCLUDE([AddressId], [AddressStatusId], [AddressTypeId], [AddressValidStatusId]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Address_AddressTypeId_AddressStatusId_City_CountryId]
    ON [dbo].[Address]([AddressTypeId] ASC, [AddressStatusId] ASC, [City] ASC, [CountryId] ASC)
    INCLUDE([AddressId], [HouseNumber], [Street], [Zip]);

