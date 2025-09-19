CREATE FUNCTION [dbo].[ComputeDoubleMetaphone]
(@word NVARCHAR (4000) NULL)
RETURNS [dbo].[SqlDoubleMetaphoneData]
AS
 EXTERNAL NAME [SQLExtensions].[SqlDoubleMetaphone].[ComputeDoubleMetaphone]

