
CREATE PROCEDURE [dbo].[GetReferenceLookup]
(
	@LookupType			VARCHAR(100),
	@Language			VARCHAR(2),
	@ClientId			INT
)
AS
BEGIN
	SELECT		LookupHeader.LookupType, 
				LookupDetails.Id,
				LookupDetails.[Description] as [Name],
				[Value]

	FROM		ReferenceLookup LookupHeader
	INNER JOIN	ReferenceLookupI8n LookupDetails
	ON			LookupHeader.Id= LookupDetails.ReferenceLookupId
	WHERE		LookupHeader.ClientId = @ClientId
	AND			LookupHeader.LookupType = @LookupType
	AND			LookupDetails.[Language] = @Language
END
