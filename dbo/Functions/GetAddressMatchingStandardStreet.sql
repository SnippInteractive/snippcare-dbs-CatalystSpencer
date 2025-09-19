
-- ===========================================================================================================================================
-- Author:		Noel Sebbey
-- Create date: 28 October 2014
-- Description:	This function replaces a street into a standardized format if it contains a string match in the street dictionary
--				@Street - The street being checked on the street dictionary
--				@LanguageCode - The language code for the street being checked
-- ===========================================================================================================================================
CREATE FUNCTION [dbo].[GetAddressMatchingStandardStreet]
(
	@Street nvarchar(50),
	@LanguageCode nvarchar(2)
)
RETURNS NVARCHAR(50)
AS
BEGIN
	SELECT @Street = REPLACE(@Street, UnstandardizedFormat, StandardizedFormat)
	FROM [dbo].[MemberMergeStreetDictionary]
	WHERE @Street LIKE '%' + UnstandardizedFormat + '%'
	AND LanguageCode = @LanguageCode
		
	RETURN @Street
END
