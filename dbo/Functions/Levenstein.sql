CREATE FUNCTION [dbo].[Levenstein]
(@firstword NVARCHAR (255) NULL, @secondword NVARCHAR (255) NULL)
RETURNS FLOAT (53)
AS
 EXTERNAL NAME [TextFunctions].[StringMetrics].[Levenstein]

