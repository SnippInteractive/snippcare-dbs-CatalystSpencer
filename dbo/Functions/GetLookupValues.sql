-- =============================================
-- Author:		Seamus Rochford
-- Create date: 9/12/2010
-- Description:	Convert a list of lookup codes to a list of lookup values
-- =============================================
CREATE FUNCTION [dbo].[GetLookupValues] 
(
	@lookupTable varchar(30),
	@lookupName varchar(30),
	@lookupValue varchar(30),
	@lookupLang varchar(2),
	@lookupClientId int,
	@CodeList varchar(max)	
)
RETURNS varchar(max)
AS
BEGIN
	-- Declare the return variable here
	declare @outList varchar(max);

	exec Camp_GetLookupValuesList @lookupTable, @lookupName, @lookupValue, @lookupLang, @lookupClientId, @CodeList, @outList
	
	RETURN @outList;
END
