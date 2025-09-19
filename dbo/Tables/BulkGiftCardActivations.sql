CREATE TABLE [dbo].[BulkGiftCardActivations] (
    [BulkActivationId]        INT                IDENTITY (1, 1) NOT NULL,
    [Version]                 INT                CONSTRAINT [DF_BulkGiftCardActivations_Version] DEFAULT ((0)) NOT NULL,
    [StartingDevice]          VARCHAR (50)       COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [EndDevice]               VARCHAR (50)       COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ActivationDate]          DATETIMEOFFSET (7) NOT NULL,
    [LoadAmount]              MONEY              NOT NULL,
    [Reference]               NVARCHAR (250)     COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Currency]                VARCHAR (3)        COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CreatedBy]               INT                NOT NULL,
    [LastUpdated]             DATETIMEOFFSET (7) NULL,
    [Status]                  INT                CONSTRAINT [DF_BulkGiftCardActivations_Status] DEFAULT ((0)) NOT NULL,
    [SiteId]                  INT                NOT NULL,
    [SearchByCardNumber]      BIT                NOT NULL,
    [Count]                   INT                NOT NULL,
    [ReserveFlag]             UNIQUEIDENTIFIER   NOT NULL,
    [StartDate]               DATETIME2 (7)      NOT NULL,
    [ExpiryDate]              DATETIME2 (7)      NOT NULL,
    [CreateDate]              DATETIME2 (7)      CONSTRAINT [DF_BulkGiftCardActivations_CreateDate] DEFAULT (getdate()) NOT NULL,
    [DeviceProfileTemplateId] INT                NOT NULL,
    CONSTRAINT [PK_BulkGiftCardActivations] PRIMARY KEY CLUSTERED ([BulkActivationId] ASC),
    CONSTRAINT [FK_BulkGiftCardActivations_BulkGiftCardActivationsStatus] FOREIGN KEY ([Status]) REFERENCES [dbo].[BulkGiftCardActivationsStatus] ([Id])
);

