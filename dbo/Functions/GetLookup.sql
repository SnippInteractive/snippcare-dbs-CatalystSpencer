CREATE  FUNCTION [dbo].[GetLookup] 
 (
  @clientId  int,
  @lookupType varchar(50),
  @language char(2) = 'de'
 )
RETURNS @retTable TABLE 
 (
  Code  varchar(20),
  Description varchar(100),
  DisplayOrder INT
 )
AS


BEGIN

	INSERT INTO @retTable 
		SELECT code, description,DisplayOrder 
		FROM Lookup l inner join LookupI8n l8 on l.LookupId = l8.LookupId 
		WHERE ClientId = @clientId and LookupType = @lookupType and language = @language
		and Active=1

	RETURN 
END

