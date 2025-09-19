CREATE PROCEDURE [dbo].[Epos_CheckPromotionMaxUsageLimit]
	@PromotionId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  Declare @totaltrxCount int;
  Declare @maxusagelimit int,@ClientId INT;
	Declare @trxStatus int;
			
	--select @maxusagelimit = IsNULL(PromotionUsageLimit,-1) from Promotion where Id = @PromotionId
	select @maxusagelimit = IsNULL(P.PromotionUsageLimit,-1),@ClientId = pf.ClientId
	from Promotion p with(nolock) INNER JOIN PromotionOfferType pf with(nolock)  on pf.id = p.PromotionOfferTypeId 
	where p.Id = @PromotionId

	if(@maxusagelimit = -1)
	begin
	select -1 as result
	end
	else
	 BEGIN
	 Select @trxStatus= TrxStatusId  from TrxStatus where Name='Completed'and ClientId=@ClientId;
		--select total completed trx which hit the passed in promotion 
		with cte as (
			  select th.TrxId  as TotalTrxCount from  TrxDetailPromotion tp
				inner join trxdetail td on td.TrxDetailID = tp.TrxDetailId 
				inner join trxheader th on th.trxid= td.TrxId		
				 where tp.promotionid=@PromotionId and th.TrxStatusTypeId = @trxStatus
				 group by th.trxid
			)

			select @totaltrxCount = count(TotalTrxCount) from cte
			--The above step could have been done also using Count(distinct th.TrxId)  as TotalTrxCount with out cte
		if(@totaltrxCount >=  @maxusagelimit)
		 begin
		 select 1 as result
		 end
		 else 
		 begin 
		 select 0 as result
		 end
	 END	
end
