CREATE FUNCTION [dbo].[GenerateRandomNumbers]
(@prefix NVARCHAR (4000) NULL, @numberLength INT NULL, @numberDevicesToGenerate NUMERIC (18) NULL, @suffix NVARCHAR (4000) NULL)
RETURNS 
     TABLE (
        [RandomNumber] NVARCHAR (50) NULL)
AS
 EXTERNAL NAME [SQLExtensions].[RandomDeviceNumberGenerator].[GenerateRandomNumbers]

