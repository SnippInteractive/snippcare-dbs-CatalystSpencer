CREATE TABLE [dbo].[PointsToCashConversionUnit] (
    [Id]                             INT        IDENTITY (1, 1) NOT NULL,
    [StartValue]                     FLOAT (53) NOT NULL,
    [EndValue]                       FLOAT (53) NULL,
    [ConversionUnit]                 FLOAT (53) NOT NULL,
    [LoyaltyDeviceProfileTemplateId] INT        NOT NULL,
    [Version]                        INT        CONSTRAINT [DF__PointsToC__Versi__377B294A] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__PointsTo__3214EC073592E0D8] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PointsToCashConversionUnit_LoyaltyDeviceProfileTemplate] FOREIGN KEY ([LoyaltyDeviceProfileTemplateId]) REFERENCES [dbo].[LoyaltyDeviceProfileTemplate] ([Id])
);

