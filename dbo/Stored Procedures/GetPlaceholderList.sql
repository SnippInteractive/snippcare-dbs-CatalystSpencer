
CREATE PROCEDURE [dbo].[GetPlaceholderList]
(
	@ClientId INT
)
AS
BEGIN

	DECLARE	@Result NVARCHAR(MAX) = ''

	SET @Result = 
	(
			select PropertyKey AS Name,'##'+PropertyKey+'##' AS Value  from CommunicationPlaceholderMapping Where @ClientId = @ClientId AND Display = 1
			FOR			JSON PATH
	)

	/*-----------------------------------------------------------------------------------------------------------------
		Getting the searched Result.
	-----------------------------------------------------------------------------------------------------------------*/
	SELECT ISNULL(@Result,'') as Result


END
