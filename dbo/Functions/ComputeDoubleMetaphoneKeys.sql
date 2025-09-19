CREATE FUNCTION [dbo].[ComputeDoubleMetaphoneKeys]
(@word NVARCHAR (4000) NULL)
RETURNS 
     TABLE (
        [Word]         NVARCHAR (MAX) NULL,
        [PrimaryKey]   NVARCHAR (MAX) NULL,
        [SecondaryKey] NVARCHAR (MAX) NULL)
AS
 EXTERNAL NAME [SQLExtensions].[SqlDoubleMetaphone].[ComputeDoubleMetaphoneKeys]

