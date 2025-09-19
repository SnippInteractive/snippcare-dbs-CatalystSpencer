-- =============================================
-- Author:		Bibin Abraham
-- Create date: 21/04/2021
-- Description:	Round Points based on Loyalty Profile Rounding Rule 
-- =============================================
CREATE FUNCTION [dbo].[RoundPoints](
	@points decimal(18,2),@roundtype nvarchar(100),@TrxId INT = 0
) 
RETURNS decimal(18,2)
AS
BEGIN
	--  return variable 
	Declare @roundedpoints decimal(18,2)

	IF @roundtype = 'RoundPromotionPointsOnBasket' AND ISNULL(@TrxId,0) > 0 --VOY-727 Little Potato Promotion Value Roundin FROM SP [bws_GetTransactionSearch] 
	BEGIN
		set @roundedpoints = @points

		DECLARE @DeviceId NVARCHAR(25),@ClientId INT
		SELECT @DeviceId = DeviceId,@ClientId = ClientId FROM TrxHeader with(nolock) where TrxId = @TrxId

		IF ISNULL(@DeviceId,'') != '' AND ISNULL(@ClientId,0) > 0
		BEGIN
			IF EXISTS(SELECT 1 FROM ClientConfig with(nolock) Where [Key] = 'EnableBasketPromotionRounding' AND Value = 'True' AND ClientId = @ClientId)
			BEGIN
				IF EXISTS(SELECT 1 from Device d with(nolock) 
				join DeviceProfile dp with(nolock) on d.id=dp.DeviceId 
				join DeviceProfileTemplate dpt with(nolock) on dp.DeviceProfileId = dpt.Id
				join LoyaltyDeviceProfileTemplate ldpt with(nolock) on dpt.id = ldpt.id
				join PointsCalculationRuleType pcr with(nolock) on ldpt.PointsCalculationRuleTypeId = pcr.Id
				where D.Deviceid = @DeviceId AND ldpt.SpendToPointsConversionUnit = 0 AND pcr.name = 'RoundPointsOnBasket')
				BEGIN
				--	IF EXISTS(SELECT 1 FROM TrxDetail td 
				--	INNER JOIN TrxDetailPromotion tdp on tdp.TrxDetailId = td.TrxDetailId 
				--	INNER JOIN Promotion P on tdp.PromotionId = P.Id
				--	INNER JOIN PromotionOfferType pt on p.PromotionOfferTypeId = pt.Id
				--	WHERE TrxId = @TrxId AND pt.Name ='Points' AND pt.ClientId = @ClientId AND PromotionTypeId = 1 AND tdp.ValueUsed > 0) --Basket
				--	BEGIN
						set @roundedpoints = ROUND(@points,0) 
					--END
				END
			END
		END
	END
	ELSE
	BEGIN
	-- Round decimal points 
	set @roundedpoints = CASE @roundtype 
							WHEN 'ROUND' THEN ROUND(@points,0) 
							WHEN 'FLOOR' THEN FLOOR(@points) 
							--Floor down to nearest 50 EG:-75.77 to 50 or 249 to 200 or 1049.40 to 1000
							WHEN 'FLOOR50' THEN FLOOR(@points / 50) * 50
							WHEN 'CEILING' THEN CEILING(@points) 
							ELSE @points END
	END
	-- Return the result of the function
	RETURN @roundedpoints

END
