CREATE Procedure [dbo].[GetPromotionMemberProfileItemTypes_Temp] (@ClientId int) as

BEGIN 
	
	SELECT Id,Name,CategoryId
	FROM PromotionMemberProfileItemType 		 
	WHERE ClientId = @ClientId AND Display = 1
	
END