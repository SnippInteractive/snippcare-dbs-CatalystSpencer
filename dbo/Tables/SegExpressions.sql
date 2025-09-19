CREATE TABLE [dbo].[SegExpressions] (
    [ExpressionId]   SMALLINT     NOT NULL,
    [Description]    VARCHAR (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SQLSymbol]      VARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [NoParameters]   TINYINT      NOT NULL,
    [SupportedTypes] INT          NOT NULL,
    CONSTRAINT [PK_SegExpressions] PRIMARY KEY CLUSTERED ([ExpressionId] ASC) WITH (FILLFACTOR = 100)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 = No Parameters, 1= 1 Parameter, 2 = 2 parameters, 3 - List of values', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegExpressions', @level2type = N'COLUMN', @level2name = N'NoParameters';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This is additive 1 = String, 2 = Number, 4 = Date, 8 = Lookup', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegExpressions', @level2type = N'COLUMN', @level2name = N'SupportedTypes';

