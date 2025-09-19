CREATE FUNCTION [dbo].[GenerateRandomNumber]
(@prefix NVARCHAR (4000) NULL, @numberLength INT NULL, @suffix NVARCHAR (4000) NULL)
RETURNS NVARCHAR (4000)
AS
 EXTERNAL NAME [SQLExtensions].[RandomDeviceNumberGenerator].[GenerateRandomNumber]

