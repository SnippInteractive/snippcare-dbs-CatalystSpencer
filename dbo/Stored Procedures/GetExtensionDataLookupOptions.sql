CREATE PROCEDURE [dbo].[GetExtensionDataLookupOptions]
    @ExtensionCategory NVARCHAR(50),
	@LookupType NVARCHAR(150),
	@Language  NVARCHAR(2)
AS
BEGIN

	 iF @LookupType = ''
	 BEGIN
		SELECT i8n.Id, i8n.[Description] as 'Name',l.LookupType,i8n.[Value]
		FROM ReferenceLookup l
		INNER JOIN ReferenceLookupi8n i8n ON l.Id = i8n.ReferenceLookupId
		WHERE  i8n.[Language] = 'en'
	END
	ELSE 
	BEGIN		
		SELECT i8n.Id, i8n.[Description] as 'Name',l.LookupType,i8n.[Value]
		FROM ReferenceLookup l
		INNER JOIN ReferenceLookupi8n i8n ON l.Id = i8n.ReferenceLookupId
		WHERE l.LookupType = @LookupType AND i8n.[Language] = 'en'	
	END	
END