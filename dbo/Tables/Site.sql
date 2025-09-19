CREATE TABLE [dbo].[Site] (
    [SiteId]                INT             IDENTITY (1, 1) NOT NULL,
    [Version]               INT             CONSTRAINT [DF_Site_Version] DEFAULT ((0)) NOT NULL,
    [Name]                  NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ParentId]              INT             NULL,
    [SiteStatusId]          INT             NOT NULL,
    [SiteTypeId]            INT             NOT NULL,
    [AddressId]             INT             NULL,
    [ClientId]              INT             NOT NULL,
    [ContactDetailsId]      INT             NULL,
    [CompanyName]           VARCHAR (100)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [SiteRef]               VARCHAR (30)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LanguageId]            INT             CONSTRAINT [DF__tmp_rg_xx__Langu__387A3A7B] DEFAULT ((3)) NOT NULL,
    [Display]               BIT             CONSTRAINT [DF_Site_Display] DEFAULT ((1)) NOT NULL,
    [Permission]            VARCHAR (50)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Channel]               VARCHAR (100)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [CountryId]             INT             NULL,
    [UpdatedBy]             INT             NULL,
    [UpdatedDate]           DATETIME        NULL,
    [CashToPointThreshold]  DECIMAL (18, 2) NULL,
    [OLD_SiteID]            INT             NULL,
    [PointsToCashThreshold] DECIMAL (18, 2) NULL,
    [ApplicationFormId]     SMALLINT        CONSTRAINT [DF_ApplicationFormId] DEFAULT ((3)) NULL,
    [CommunicationName]     NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [SocialMediaUrls]       NVARCHAR (500)  NULL,
    [SmallLogoUrl]          NVARCHAR (500)  NULL,
    [MediumLogoUrl]         NVARCHAR (500)  NULL,
    [LargeLogoUrl]          NVARCHAR (500)  NULL,
    [OwnerImageUrl]         NVARCHAR (500)  NULL,
    [ExtraInfo]             NVARCHAR (1000) NULL,
    [Manager]               NVARCHAR (100)  NULL,
    [WebPageUrl]            NVARCHAR (300)  NULL,
    CONSTRAINT [PK_Site_1] PRIMARY KEY CLUSTERED ([SiteId] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_Site_Address] FOREIGN KEY ([AddressId]) REFERENCES [dbo].[Address] ([AddressId]),
    CONSTRAINT [FK_Site_Client1] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_Site_ContactDetails] FOREIGN KEY ([ContactDetailsId]) REFERENCES [dbo].[ContactDetails] ([ContactDetailsId]),
    CONSTRAINT [FK_Site_Language] FOREIGN KEY ([LanguageId]) REFERENCES [dbo].[Language] ([LanguageId]),
    CONSTRAINT [FK_Site_ParentId] FOREIGN KEY ([ParentId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_Site_SiteStatus] FOREIGN KEY ([SiteStatusId]) REFERENCES [dbo].[SiteStatus] ([SiteStatusId]),
    CONSTRAINT [FK_Site_SiteType] FOREIGN KEY ([SiteTypeId]) REFERENCES [dbo].[SiteType] ([SiteTypeId]),
    CONSTRAINT [FK_Site_User] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FKCE1592EF175804DF] FOREIGN KEY ([SiteStatusId]) REFERENCES [dbo].[SiteStatus] ([SiteStatusId]),
    CONSTRAINT [FKCE1592EFEB021D2F] FOREIGN KEY ([SiteTypeId]) REFERENCES [dbo].[SiteType] ([SiteTypeId])
);


GO
ALTER TABLE [dbo].[Site] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_Client_SiteRef]
    ON [dbo].[Site]([ClientId] ASC, [SiteRef] ASC) WITH (FILLFACTOR = 95);

