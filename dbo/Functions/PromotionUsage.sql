
CREATE FUNCTION [dbo].[PromotionUsage]   
(  
 @Userid int =0,@PromotionId int ,@ItemCode NVARCHAR(150) = null
)  
  
RETURNS INT  
AS  
BEGIN  
	Declare @PromotionUsage INT = 0  
  
	Declare @maxusagelimit int,@PromotionHitLimitType NVARCHAR(50), @PromotionHitLimitDate Datetime = getdate(),@PromotionUsageLimit INT;

	select @maxusagelimit = IsNULL(P.MaxUsagePerMember,-1),@PromotionHitLimitType = LOWER(ISNULL(ph.name,'na')),@PromotionUsageLimit = IsNULL(P.PromotionUsageLimit,-1)
	from Promotion p with(nolock) LEFT JOIN PromotionHitLimitType ph with(nolock)  on ph.id = p.PromotionHitLimitTypeId 
	where p.Id = @PromotionId

IF ISNULL(@Userid,0) > 0
BEGIN
	if(@maxusagelimit > 0)
	BEGIN
		IF @PromotionHitLimitType = 'day'
		BEGIN
			SET @PromotionHitLimitDate = dateadd(ms, -1, (dateadd(day, +1, convert(varchar,DATEADD(day, -1, @PromotionHitLimitDate), 101))))
		END
		ELSE IF @PromotionHitLimitType = 'week'
		BEGIN
			SET @PromotionHitLimitDate = dateadd(ms, -1, convert(varchar,DATEADD(week, DATEDIFF(week, 0, @PromotionHitLimitDate), 0), 101))
		END
		ELSE IF @PromotionHitLimitType = 'month'
		BEGIN
			SET @PromotionHitLimitDate = dateadd(ms, -1, convert(varchar,DATEADD(month, DATEDIFF(month, 0, @PromotionHitLimitDate), 0), 101))
		END
		ELSE IF @PromotionHitLimitType = 'year'
		BEGIN
			SET @PromotionHitLimitDate = dateadd(ms, -1, convert(varchar,DATEADD(year, DATEDIFF(YEAR, 0, getdate()), 0), 101))
		END
		
		IF @PromotionHitLimitType != 'na'
		BEGIN
			IF isnull(@ItemCode,'') = ''
			BEGIN
				SET @PromotionUsage=(select count(promotionid) from [PromotionRedemptionCount] WITH(NOLOCK) where MemberId=@UserId and PromotionId=@PromotionId AND LastRedemptionDate > @PromotionHitLimitDate)
			END
			ELSE
			BEGIN
				SET @PromotionUsage=(select count(promotionid) from [PromotionRedemptionCount] WITH(NOLOCK) where MemberId=@UserId and PromotionId=@PromotionId AND LastRedemptionDate > @PromotionHitLimitDate AND ItemCode = @ItemCode)
			END
		END
		ELSE
		BEGIN
			IF isnull(@ItemCode,'') = ''
			BEGIN
				SET @PromotionUsage=(select count(promotionid) from [PromotionRedemptionCount] WITH(NOLOCK) where MemberId=@UserId and PromotionId=@PromotionId )
			END
			ELSE
			BEGIN
				SET @PromotionUsage=(select count(promotionid) from [PromotionRedemptionCount] WITH(NOLOCK) where MemberId=@UserId and PromotionId=@PromotionId AND ItemCode = @ItemCode)
			END
		END
	END
	ELSE
	BEGIN
		IF isnull(@ItemCode,'') = ''
		BEGIN
			SET @PromotionUsage=(select count(promotionid) from [PromotionRedemptionCount] WITH(NOLOCK) where MemberId=@UserId and PromotionId=@PromotionId )
		END
		ELSE
		BEGIN
			SET @PromotionUsage=(select count(promotionid) from [PromotionRedemptionCount] WITH(NOLOCK) where MemberId=@UserId and PromotionId=@PromotionId AND ItemCode = @ItemCode)
		END
	END
END
ELSE
BEGIN
	IF isnull(@ItemCode,'') = ''
	BEGIN
		SET @PromotionUsage=(select count(promotionid) from [PromotionRedemptionCount] WITH(NOLOCK) where PromotionId=@PromotionId)	
		END
	ELSE
	BEGIN
		SET @PromotionUsage=(select count(promotionid) from [PromotionRedemptionCount] WITH(NOLOCK) where PromotionId=@PromotionId AND ItemCode = @ItemCode)	
	END
END

  RETURN ISNULL(@PromotionUsage,0);    
      
End