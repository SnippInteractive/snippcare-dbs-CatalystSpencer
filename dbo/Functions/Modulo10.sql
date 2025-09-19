CREATE FUNCTION [dbo].[Modulo10]
(@number NVARCHAR (4000) NULL)
RETURNS INT
AS
 EXTERNAL NAME [SQLExtensions].[RandomDeviceNumberGenerator].[Modulo10]

