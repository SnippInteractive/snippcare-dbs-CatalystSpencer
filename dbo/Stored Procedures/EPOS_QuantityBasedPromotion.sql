-- =============================================
-- Author:		Wei Liu
-- Create date: 2020-02-10
-- Description:	ePos Quantity Based Promotion
-- =============================================
create PROCEDURE EPOS_QuantityBasedPromotion  @PromotionId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	select * from PromotionCategory
	select * from PromotionCategoryType
	select * from PromotionOfferType
	select * from Promotion
	SELECT * from PromotionItem where Promotionid = 1106
	select * from PromotionItemType

	

END
