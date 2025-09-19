CREATE TABLE [dbo].[ProductInfo] (
    [ID]                 INT             IDENTITY (1, 1) NOT NULL,
    [Version]            INT             CONSTRAINT [DF_ProductInfo_Version] DEFAULT ((0)) NOT NULL,
    [ClientID]           INT             NOT NULL,
    [ProductID]          NVARCHAR (75)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ProductDescription] NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode1]      NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode2]      NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode3]      NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode4]      NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode5]      NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode6]      NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode7]      NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode8]      NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode9]      NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode10]     NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode11]     NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode12]     NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode13]     NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode14]     NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AnalysisCode15]     NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ImportDate]         DATETIME        NOT NULL,
    [BaseValue]          DECIMAL (18, 2) NULL,
    [RetailPrice]        DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_ProductInfo] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
ALTER TABLE [dbo].[ProductInfo] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

