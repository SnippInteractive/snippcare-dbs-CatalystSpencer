CREATE TABLE [dbo].[EmbossLineSetting] (
    [EmbossLineSettingId] INT IDENTITY (1, 1) NOT NULL,
    [Version]             INT CONSTRAINT [DF_EmbossLineSetting_Version] DEFAULT ((0)) NOT NULL,
    [ProgramId]           INT NULL,
    [ClientId]            INT NOT NULL,
    [IsCompany]           INT NOT NULL,
    [MainCard]            INT NOT NULL,
    [IsDefault]           INT CONSTRAINT [DF_EmbossLineSetting_IsDefault] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_EmbossLineSetting] PRIMARY KEY CLUSTERED ([EmbossLineSettingId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_EmbossLineSetting_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_EmbossLineSetting_LoyaltyProgramme] FOREIGN KEY ([ProgramId]) REFERENCES [dbo].[LoyaltyProgramme] ([ProgramId])
);

