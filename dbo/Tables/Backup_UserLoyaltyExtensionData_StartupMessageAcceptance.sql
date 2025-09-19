CREATE TABLE [dbo].[Backup_UserLoyaltyExtensionData_StartupMessageAcceptance] (
    [ID]                INT            IDENTITY (1, 1) NOT NULL,
    [Version]           INT            NOT NULL,
    [UserLoyaltyDataId] INT            NOT NULL,
    [PropertyName]      NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [PropertyValue]     NVARCHAR (MAX) NULL,
    [GroupId]           INT            NULL,
    [DisplayOrder]      INT            NULL,
    [Deleted]           BIT            NULL
);

