CREATE Procedure [dbo].[UpdatePromotionItemQty] (@promotionId int) as

BEGIN 	
	UPDATE PromotionItem SET Quantity = null WHERE promotionid = @promotionId
END
