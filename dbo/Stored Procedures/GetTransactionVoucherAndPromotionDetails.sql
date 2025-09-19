


CREATE Procedure [dbo].[GetTransactionVoucherAndPromotionDetails] 
(
	@ClientId	int,
	@TrxId		int
) 
AS  
  
BEGIN   

	

		IF EXISTS (select 1 from ClientConfig where ClientId = @ClientId AND [Key] = 'EnableStampManualClaim' and [Value] = 'true')
		BEGIN

			SELECT		td.ItemCode ,
					td.Description as ItemName,
					'' as Name,
					'' as PromotionName,
					td.Description as Description,
					tvd.VoucherAmount  as VoucherAmount,
					tvd.VoucherAmount  as PointBalance,
					tvd.TrxVoucherId as DeviceId,
					td.TrxDetailId,
					td.Quantity,
					null as PromotionId,
					td.BonusPoints  

			FROM		TrxDetail td 
			INNER JOIN	TrxVoucherDetail tvd   
			ON			td.TrxDetailID = tvd.TrxDetailId  
			WHERE		td.TrxId=@TrxId 

		END
		ELSE
		BEGIN

			Declare @rewardTrxTypeid INT
		 
			SELECT	@rewardTrxTypeid = TrxTypeId 
			FROM	TrxType 
			where	Clientid=@ClientId 
			AND		Name='Reward'  
			 --select the corresponding reward trx Qty to a temp table so this qty can be displayed as Qualified Qty on Promotion/Voucher grid on TrxInfo tab  
			 --Qty on trxdetail for the reward trx is the number of times a reward hit a line item  
  
  
			SELECT		td.TrxDetailId,td.Quantity,td.LineNumber 

			INTO		#tempRewardPromo  

			FROM		Trxheader th 
			INNER JOIN  TrxDetail td   
			ON			th.TrxId = td.TrxID  
			WHERE		th.old_trxid =@TrxId 
			AND			TrxTypeid=@rewardTrxTypeid  


   
			SELECT		td.ItemCode ,
						td.Description as ItemName,
						p.Name,
						p.Name as PromotionName,
						p.Description,
						tp.ValueUsed  as VoucherAmount,
						tp.ValueUsed  as PointBalance,
						p.Name as DeviceId,
						td.TrxDetailId,
						ISNULL(trw.Quantity,1)as Quantity,
						tp.PromotionId,
						td.BonusPoints   

			INTO		#tempRewardPromotions
		  
			FROM		TrxDetail td 
			INNER JOIN	TrxDetailPromotion tp   
			ON			td.TrxDetailID = tp.TrxDetailId  
			INNER JOIN	Promotion p 
			ON			p.Id=tp.PromotionId  
			LEFT JOIN	#tempRewardPromo trw 
			ON			trw.LineNumber=td.LineNumber  
			WHERE		td.TrxId=@TrxId  
 
  
			SELECT		td.ItemCode ,
						td.Description as ItemName,
						'' as Name,
						'' as PromotionName,
						td.Description as Description,
						tvd.VoucherAmount  as VoucherAmount,
						tvd.VoucherAmount  as PointBalance,
						tvd.TrxVoucherId as DeviceId,
						td.TrxDetailId,
						td.Quantity,
						null as PromotionId,
						td.BonusPoints  

			FROM		TrxDetail td 
			INNER JOIN	TrxVoucherDetail tvd   
			ON			td.TrxDetailID = tvd.TrxDetailId  
			WHERE		td.TrxId=@TrxId  
  
			UNION  
  
			SELECT		td.ItemCode,
						td.Description as ItemName,
						tup.PromotionName as 'Name',
						tup.PromotionName as PromotionName,
						tup.PromotionDescription as 'Description',
						tup.OfferValue  as VoucherAmount,
						tup.OfferValue  as PointBalance,
						tup.PromotionName as DeviceId,
						td.TrxDetailId,
						td.Quantity ,
						null as PromotionId,
						td.BonusPoints 

			FROM		TrxDetail td 
			INNER JOIN	TrxUsedPromotions tup   
			ON			td.TrxDetailID = tup.TrxDetailId  
			WHERE		td.TrxId=@TrxId AND td.PromotionId NOT IN (SELECT DISTINCT PromotionId FROM #tempRewardPromotions)  
  
			UNION  
  
			SELECT		ItemCode ,
						ItemName,
						Name,
						PromotionName,
						Description, 
						VoucherAmount,
						PointBalance,
						DeviceId,
						TrxDetailId, 
						Quantity,
						PromotionId,
						BonusPoints 

			FROM		#tempRewardPromotions 

		END
		 

		
   
END
