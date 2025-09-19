CREATE TABLE [dbo].[PointsCalculationRuleType] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]  INT           CONSTRAINT [DF__PointsCalculationRuleType_Version] DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ClientId] INT           NOT NULL,
    [Display]  BIT           CONSTRAINT [DF_PointsCalculationRuleType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK__PointsCalculationRuleType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK__PointsCalculationRuleType__Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

