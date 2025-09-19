CREATE TABLE [dbo].[EmbossLine] (
    [EmbossLineId]        INT IDENTITY (1, 1) NOT NULL,
    [Version]             INT CONSTRAINT [DF_EmbossLine_Version] DEFAULT ((0)) NOT NULL,
    [EmbossLineSettingId] INT NOT NULL,
    [Order]               INT NOT NULL,
    [Editable]            INT NOT NULL,
    [MaxLength]           INT NULL,
    [UpperCase]           INT NOT NULL,
    CONSTRAINT [PK_EmbossLine] PRIMARY KEY CLUSTERED ([EmbossLineId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_EmbossLine_EmbossLineSetting] FOREIGN KEY ([EmbossLineSettingId]) REFERENCES [dbo].[EmbossLineSetting] ([EmbossLineSettingId])
);

