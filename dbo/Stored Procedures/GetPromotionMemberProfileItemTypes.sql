CREATE Procedure [dbo].[GetPromotionMemberProfileItemTypes] (@ClientId int, @Display bit=1, @IsProfileItem bit=0) as

BEGIN 
	IF @Display = 1 
	BEGIN
		SELECT Id,Name,CategoryId,Display
		FROM PromotionMemberProfileItemType 		 
		WHERE ClientId = @ClientId AND Display = 1
	END
	ELSE
	BEGIN
		SELECT Id,Name,CategoryId,Display
		FROM PromotionMemberProfileItemType 		 
		WHERE ClientId = @ClientId AND IsMemberProfileItem = @IsProfileItem
	END
	
	
END
