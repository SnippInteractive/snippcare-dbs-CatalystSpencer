-- =============================================
-- Author:		Bibin Abraham
-- Create date: 28/10/2020
-- Description:	Apply Promotion for First ,Second or Transaction within period
-- =============================================
CREATE PROCEDURE [dbo].[ApplyPointsForTransactionPromo] (@ClientId int, 
	@UserId INT,@DeviceId nvarchar(25),
	@ItemCode NVARCHAR(30),
	@PromoProfileItem NVARCHAR(300),@SiteId INT,@TrxId INT,
	@Success BIT OUTPUT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	Declare @Description varchar(100),@TrxTypeId int=0,@TrxStatusId INT=0,@Valid int=0;
	Declare @promotionId int=0,@CurrentPoint DECIMAL(8, 2),@AccountId INT ;
	Declare @PromotionPointValue DECIMAL(8, 2),@PromotionCategoryId int=14,
			@Reward NVARCHAR(MAX),@OfferTypeId INT,@RewardOfferTypeId INT,@UserSiteId INT,@NewTrxId INT,
			@TrxdateTime DATETIME = GETDATE(),@TrxDetailId INT,@PosTxnId NVARCHAR(20) = LOWER(NEWID()),
			@PromoStratDate DATETIME,@PromoEndDate DATETIME,@promoQty Int,@PromoOfferType NVARCHAR(30);

		SELECT @PromotionCategoryId = Id FROM PromotionCategory WHERE Name = 'Transaction' AND ClientId = @ClientId

		--1.Find number of completed pos and receipt transactions for the user
		Declare @purchasetrxCount int,@purchaseCompleteStatus int;
		Select @purchaseCompleteStatus = TrxStatusId From TrxStatus where ClientId=@ClientId and Name='Completed'
		Select @purchasetrxCount= Count(TrxId) from TrxHeader th inner join Device d 
			on d.DeviceId=th.DeviceId  join TrxType ty 
			on th.TrxTypeId= ty.TrxTypeId 
			where d.UserId=@UserId and ty.Name in ('PosTransaction','Receipt') 
			and th.TrxStatusTypeId = @purchaseCompleteStatus and th.DeviceId=@DeviceId 
		--2.Set Promotion Profile Item based on transaction count	
		 SET @PromoProfileItem = CASE  @purchasetrxCount WHEN 1 THEN 'FirstTransaction' WHEN 2 THEN 'SecondTransaction' WHEN 3 THEN 'ThirdTransaction' ELSE 'TransactionWithinPeriod' END
		
	
	IF @ItemCode in ('Transaction') and LEN(@PromoProfileItem) > 1
	BEGIN
			--3.Check if any valid promotion exist for Transaction based promotion category and apply points	
	Declare @promotionitemTypeid int;
	select @promotionitemTypeid = Id from PromotionItemType where ClientId=@ClientId and Name=@PromoProfileItem
		SET @Description=@PromoProfileItem;--FirstTransaction,SecondTransaction
		--Get Active Promotion for Category = Transaction and PromotionItemType=First/Second/TrxWithinPeriod
		
		SELECT TOP 2  p.Id,  p.PromotionOfferValue, poi.Quantity,p.StartDate,p.EndDate	,Reward,pot.Name into #TrxPromotions
				FROM Promotion p 
		  INNER JOIN PromotionItem poi		on poi.PromotionId = p.Id	
		  INNER JOIN PromotionSites ps		on ps.PromotionId=p.Id	
		  INNER JOIN PromotionLoyaltyProfiles plp on plp.PromotionId = p.Id 
		  INNER JOIN PromotionOfferType pot on pot.Id=p.PromotionOfferTypeId and pot.ClientId=@ClientId
		  INNER JOIN DeviceProfile dp		on plp.LoyaltyProfileId=dp.DeviceProfileId 
		  INNER JOIN Device d				on d.Id=dp.DeviceId 
				WHERE  p.[Enabled] = 1 
				AND p.StartDate <= GETDATE() AND p.EndDate >= GETDATE() AND poi.PromotionItemTypeId=@promotionitemTypeid
				AND p.PromotionCategoryId = @PromotionCategoryId AND p.PromotionOfferTypeId in (select Id From PromotionOfferType where Name in ('Points','Reward','PointsMultiplier') and ClientId = @ClientId)
				AND ps.SiteId in( SELECT SiteId from GetParentSitesBySiteId(@SiteId))
				AND d.UserId=@UserId and d.DeviceId=@DeviceId --and d.DeviceStatusId=2
				ORDER BY p.PromotionOfferValue DESC		
				
	/*CHECK IF ANY SELECTED PROMOTION HAVE A VALID SEGMENT-DONE THIS WAY TO AVOID A CURSOR*/
	If EXISTS( select 1 from PromotionSegments where PromotionId in (Select Id from #TrxPromotions))
	BEGIN
		Select t.Id into #promotoHold from #TrxPromotions t 
			inner join PromotionSegments ps on ps.PromotionId=t.Id
			inner join SegmentUsers su on su.SegmentId=ps.SegmentId 
			where su.UserId=@UserId and ps.PromotionId in (Select Id from #TrxPromotions)
			order by PromotionOfferValue desc
			/*IF USER EXIST IN A PROMOTION SEGMENT KEEP THAT PROMOTION AND DELETE ALL OTHER PROMOTIONS FROM SELECTION*/
		delete from #TrxPromotions where Id not in (select Id from #promotoHold)				
	END
	
	SELECT TOP 1 @promotionId = Id, @PromotionPointValue = PromotionOfferValue,@promoQty= Quantity,
			@PromoStratDate=StartDate,@PromoEndDate=EndDate	,
			@Reward = Reward
			,@PromoOfferType=Name from #TrxPromotions order by PromotionOfferValue desc

		SET @Valid = CASE WHEN ISNULL(@promotionId,0) > 0 THEN 1 ELSE 0 END
		
		IF @PromoOfferType = 'Reward' AND 
		(
			ISNULL(@Reward,'') = '' OR 
			ISNULL(ISJSON(@Reward),'')= '' OR 
			ISJSON(@Reward)= 0
		) 
		BEGIN
		SET @Valid=0;
		RETURN;
		
		END
		
		--need to clarify with christian if its possible to apply same promotions multiple times with in the allowed period/day
		IF @PromoProfileItem = 'TransactionWithinPeriod'
		BEGIN	
		--if an entry exist with the same description(TransactionWithinPeriod-trxdate) in trxdetail table then a new trx will not be created
		SET @Description = @PromoProfileItem +'-'+Convert(varchar(10),@PromoStratDate,103)+'-'+Convert(varchar(10),@PromoEndDate,103)
		-- Check the total count of trx for this user against the promotion stratdate & enddate
		Declare @purcashewithinperiodCount smallint;
		SET @TrxStatusId=(SELECT TrxStatusId FROM TrxStatus WHERE [name]='Completed' AND clientid = @ClientId)
		-- This select will be expensive ,need to figure out a way to avoid this
		 Select @purcashewithinperiodCount = Count(TrxId) from TrxHeader where DeviceId=@DeviceId 
		 and TrxDate between @PromoStratDate and @PromoEndDate and TrxTypeId in (select TrxTypeId from TrxType where Name in ('PosTransaction',
						'Receipt') and ClientId = @ClientId)and TrxStatusTypeId=@TrxStatusId
		 -- Set Valid status only if purchase count with in promo period is > = to Counter set on promo
		 SET @Valid = CASE WHEN ISNULL(@purcashewithinperiodCount,0) >= @promoQty THEN 1 ELSE 0 END
		END
		
		IF @Valid = 1
		BEGIN
			DECLARE @trxStatusName NVARCHAR(100)='Completed';
			SET @TrxTypeId=(SELECT TrxTypeId FROM trxtype WHERE [name]='Transaction' AND clientid = @ClientId)
			IF @TrxStatusId = 0 --this check is to avoid another db call when its TransactionWithinPeriod
			BEGIN
			SET @TrxStatusId=(SELECT TrxStatusId FROM TrxStatus WHERE [name]=@trxStatusName AND clientid = @ClientId)
			END
			
			---If transaction exist for the same TrxType(Transaction) with @ItemCode(FirstTrx,SecondTrx,Purchasewithinperiod), then abort

				IF NOT EXISTS(SELECT 1
					FROM   TrxHeader th inner join TrxDetail td on th.TrxId=td.TrxID
					inner join TrxType tt on th.TrxTypeid= tt.TrxTypeID and tt.ClientId=@ClientId
					where tt.Name in ('PosTransaction','Receipt') and th.TrxStatusTypeId in 
					(SELECT TrxStatusId FROM TrxStatus WHERE [name] in (@trxStatusName) AND clientid = @ClientId) 
					and th.DeviceId=@DeviceId
					and td.ItemCode=@ItemCode and td.PromotionId = @PromotionId)
					BEGIN		
												
						SELECT @NewTrxId = @TrxId;								  
					END
	 
			IF @NewTrxId != 0
			BEGIN
				
				-- select loyalty account to update points balance
				Select @AccountId= Accountid from Device where DeviceId=@DeviceId and UserId=@UserId;
				IF(@PromoOfferType = 'PointsMultiplier' and ISNULL(@PromotionPointValue,0) > 0)
				BEGIN
				--multiply points earned in first/second transaction by promoitonal OfferValue
					Set @PromotionPointValue = (Select SUM(Points- ISNULL(BonusPoints,0))*@PromotionPointValue from TrxDetail where trxid=@TrxId )
				END
				IF ISNULL(@AccountId,0) > 0 
				BEGIN
				declare @newLineNumber int,@currencyCode nvarchar(10) ;
				Select @newLineNumber = MAX(LineNumber)+1,@currencyCode =HomeCurrencyCode from TrxDetail where TrxId=@TrxId
				group by HomeCurrencyCode
				--An entry with new lineitem for First/Second/Nth purchase transaction for applying promotion 
					INSERT INTO TrxDetail
								([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,PromotionItemId,HomeCurrencyCode)
					VALUES ('1', @NewTrxId,@newLineNumber,@ItemCode,@Description,1,0,0,@PromotionPointValue, @PromotionId, @PromotionPointValue,null,@currencyCode);
		
					SELECT @TrxDetailId = Scope_identity();
				-- Save Promotion hit details
					INSERT INTO TrxDetailPromotion ([Version], PromotionId, TrxDetailId , ValueUsed) VALUES (1, @promotionId, @TrxDetailId, @PromotionPointValue);
				-- Get current point balance and append the promotion points to users loyalty account	
					SELECT @CurrentPoint = ISNULL(PointsBalance,0) FROM Account WHERE AccountId= @AccountId AND  UserId = @UserId 
					UPDATE Account SET PointsBalance = (@CurrentPoint + ISNULL(@PromotionPointValue,0)) WHERE  AccountId= @AccountId AND UserId = @UserId 
				-- IF Promotion hit is Reward create a reward entry and link it with the Transaction entry done at first, check @NewTrxId = Scope_identity()
					
					IF	ISNULL(@Reward,'') <> '' AND -- Checking Variable is null
						ISNULL(ISJSON(@Reward),'')<> '' AND -- Checking Json value is null
						ISJSON(@Reward)= 1 -- Checking whether it is a valid json		
					BEGIN
						DECLARE @rewId NVARCHAR(10)=JSON_VALUE(@Reward,'$.RewardId')
						DECLARE @ProductId NVARCHAR(10)=JSON_VALUE(@Reward,'$.Id')

						DECLARE @ProductValue DECIMAL(18,2) = null;
						IF ISNULL(JSON_VALUE(@Reward,'$.Value') , '') != ''
						BEGIN
							SET @ProductValue = CAST(JSON_VALUE(@Reward,'$.Value') AS DECIMAL(18,2))
						END

						DECLARE @RewardIdAndProductId NVARCHAR(100)=''

						IF ISNULL(@rewId,'')<>'' AND ISNULL(@ProductId,'')<>''
						BEGIN
							SET @RewardIdAndProductId = @rewId + '/' + @ProductId
						END

						Declare @trxstatusStarted int,@NewRewardTrxId INT;
						SELECT @TrxTypeId= TrxTypeId from TrxType where Name='Reward' and ClientId=@ClientId
						SET @TrxStatusId=(SELECT TrxStatusId FROM TrxStatus WHERE [name]='Started' AND clientid = @ClientId)
					
						INSERT INTO TrxHeader
										(ClientId,DeviceId,TrxTypeId,TrxDate,SiteId,TerminalId,TerminalDescription,Reference,OpId,TrxStatusTypeId,InitialTransaction,OLD_TrxId,TrxCommitDate)
							VALUES      (@ClientId,@DeviceId,@TrxTypeId,@TrxdateTime,@UserSiteId,'','', @PosTxnId,'',@TrxStatusId,@NewTrxId,@NewTrxId,GetDate());
						SELECT @NewRewardTrxId = Scope_identity();	
						INSERT INTO TrxDetail
						([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,PromotionItemId,AuthorisationNr)
						SELECT [Version], @NewRewardTrxId,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,Points, PromotionId, ISNULL(ISNULL(@ProductValue,PromotionalValue),0) AS PromotionalValue,PromotionItemId,@RewardIdAndProductId
						FROM TrxDetail WHERE TrxID=@NewTrxId
		
					END

					EXEC TriggerActionsBasedOnTransactionHit @ClientId, @UserId, @NewTrxId

					-- Audit Account Balance update
					Declare @Message nvarchar(250),@ChangeBy INT;
					--commenting to avoid another db call , we can identify this entry happened from SP from the reason field on Audit
					--select @ChangeBy= UserId from [User] where Username='superuser'
					SET @Message = 'Success, '+@PromoOfferType+' Applied for '+@ItemCode + '-'+@PromoProfileItem+',PromotionId-'+ CAST(@PromotionId as varchar(10))
					INSERT INTO AUDIT ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType,OperatorId,SiteId)
					VALUES (1,@UserId,@ItemCode, @CurrentPoint + @PromotionPointValue, @CurrentPoint, GETDATE(), NULL,@Message,'Account',null,@SiteId)
					SET @Success = 1 
				END
			END
		END
	END
   
END
