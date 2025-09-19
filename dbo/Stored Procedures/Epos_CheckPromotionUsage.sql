
-- =============================================
-- Author:		ANISH
-- Create date: 28-06-2017
-- Description:	Classical Voucher Maximum Redemption Check
-- =============================================
CREATE PROCEDURE [dbo].[Epos_CheckPromotionUsage]
	-- Add the parameters for the stored procedure here
	@UserId INT,
	@PromotionId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	Declare @UsedPromotionrCount INT
	--SET @UsedPromotionrCount=(select count(promotionid) from [PromotionRedemptionCount] where MemberId=@UserId and PromotionId=@PromotionId)	
	SET @UsedPromotionrCount= [dbo].[PromotionUsage](@UserId,@PromotionId,null)
	select isnull(@UsedPromotionrCount,0) as Result-- ok
end
