
CREATE FUNCTION [dbo].[ConvertDateStringFormat](
    @InputDateString VARCHAR(50) 
 ) 
RETURNS nvarchar(50)
AS
BEGIN

Declare @ConvertedFormatString nvarchar(50) =  convert(varchar, CAST(@InputDateString as datetime), 101) -- Nov  6 2015  6:27AM --> 11/06/2015
RETURN @ConvertedFormatString 

END
