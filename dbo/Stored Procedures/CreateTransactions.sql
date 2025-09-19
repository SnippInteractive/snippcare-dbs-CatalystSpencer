CREATE PROCEDURE [dbo].[CreateTransactions]  
(  
	 @ClientId							INT,  
	 @DeviceId							NVARCHAR(25),  
	 @TrxTypeId							INT,  
	 @TrxdateTime						DATETIME,  
	 @SiteId							INT,  
	 @PosTxnId							NVARCHAR(250),  
	 @TrxStatusId						INT,  
	 @RewardId							NVARCHAR(20)='',  
	 @ActivityDescription				NVARCHAR(MAX)='',  
	 @PromotionOfferValue				DECIMAL(18,2),   
	 @PromotionId						INT,  
	 @UserId							INT,  
	 @IsTrxFromPromotion				BIT,  
	 @IsAccountBalanceUpdateRequired	BIT,  
	 @Value								INT  = NULL,  
	 @ItemCode							NVARCHAR(250)= NULL,  
	 @AnalysisCode1						NVARCHAR(250)= NULL,  
	 @AnalysisCode2						NVARCHAR(250)= NULL,  
	 @AnalysisCode3						NVARCHAR(250)= NULL,  
	 @AnalysisCode4						NVARCHAR(250)= NULL, 
	 @Quantity							FLOAT = 1,	
	 ----------------------------------------------------------						 
	 @Res								NVARCHAR(250)='0' OUTPUT,  
	 @CurrentPointBalance				DECIMAL(18,2) OUTPUT,
	 @TransactionId						INT OUTPUT        
  
)  
AS  
BEGIN  
	  DECLARE	@NewTrxId  INT, 
				@AccountId  INT,  
				@TrxDetailId INT,  
				@CurrentPoint DECIMAL(18,2)  
  
	  /*---------------------------------  
	   TRX HEADER INSERTION  
	  ---------------------------------*/  

	  	SELECT	@AccountId= Accountid 
			FROM	Device 
			WHERE	DeviceId=@DeviceId 
			AND		UserId=@UserId;	

		SELECT	@CurrentPoint = ISNULL(PointsBalance,0)   
		FROM	Account   
		WHERE	AccountId= @AccountId   
		AND		UserId = @UserId   

		INSERT INTO TrxHeader  
		(  
			ClientId,DeviceId,TrxTypeId,  
			TrxDate,SiteId,TerminalId,  
			TerminalDescription,Reference,OpId,  
			TrxStatusTypeId,TrxCommitDate, AccountPointsBalance  
		)  
		VALUES         
		(  
			@ClientId,@DeviceId,@TrxTypeId,  
			@TrxdateTime,@SiteId,'',  
			'', @PosTxnId,'',  
			@TrxStatusId,GETDATE(), @CurrentPoint  
		)  

		SELECT @NewTrxId = SCOPE_IDENTITY();  

		IF ISNULL(@NewTrxId,0)>0  
		BEGIN  
				SET @RewardId = ISNULL(@RewardId,''); 
		 
				SELECT	@AccountId = Accountid   
				FROM	Device   
				WHERE	DeviceId=@DeviceId   
				AND		UserId=@UserId;  
  
				/*----------------------------  
				TRX DETAIL INSERTION  
				----------------------------*/  
				IF ISNULL(@AccountId,0) > 0   
				BEGIN  
				print @ItemCode
				INSERT INTO TrxDetail  
				(  
					[Version], TrxID,LineNumber,ItemCode,  
					DESCRIPTION,Quantity,VALUE,EposDiscount,  
					Points, PromotionId, PromotionalValue,PromotionItemId,  
					Anal1,Anal2,Anal3,Anal4  
				)  
				VALUES   
				(  
					'1',@NewTrxId,1,
					CASE   
						WHEN ISNULL(@PromotionId,0)> 0   
						THEN 
							CASE 
								WHEN @AnalysisCode1 = 'Referral_Refer Friend_Activity' 
								THEN @ItemCode 
								ELSE NULL 
							END --@NewTrxId (VOY-474-ItemCode is setting as null instead of TrxId)   
						ELSE    
							CASE    
								WHEN LEN(ISNULL(@ItemCode,'')) > 0    
								THEN @ItemCode  
								ELSE CAST(@NewTrxId AS VARCHAR(100)) 
							END  
					END ,  
					@ActivityDescription,@Quantity,  
					0, --@PromotionOfferValue, -- (VOY-474 - setting the value as 0 instead of PromotionOfferValue)   
					0,  
					@PromotionOfferValue, @PromotionId, @PromotionOfferValue,NULL,  
					@AnalysisCode1,@AnalysisCode2,@AnalysisCode3,@AnalysisCode4  
				)  

				SET @TrxDetailId = SCOPE_IDENTITY();  

		   END  
  
			IF @PromotionId IS NOT NULL   
			BEGIN  
				---INSERT INTO PromotionRedemptionCount
				INSERT PromotionRedemptionCount (MemberId, PromotionId, LastRedemptionDate,TrxId) 
				VALUES (@UserId,@PromotionId,GETDATE(),@NewTrxId)
			END  
			IF @IsTrxFromPromotion = 1  AND @TrxDetailId IS NOT NULL
			BEGIN 
				/*--------------------------------------  
				Insert the promotion hit details.  
				--------------------------------------*/   
				INSERT INTO TrxDetailPromotion([Version], PromotionId, TrxDetailId , ValueUsed)   
				VALUES (1, @PromotionId, @TrxDetailId, @PromotionOfferValue)  
			END  
  
		   /*--------------------------------------  
			Update the Account Balance  
		   ---------------------------------------*/  
			IF @IsAccountBalanceUpdateRequired = 1  
			BEGIN    
     
				IF (SELECT [Value] FROM ClientConfig WITH (NOLOCK) WHERE [Key]='EnablePointsAgingProcess' AND ISNULL([VALUE],'') <> '' AND ClientId = @ClientId) = 'True'  
				BEGIN  
					EXEC [EPOS_UpdatePointsAgeWithTrx] @UserId, @NewTrxId  
				END      
				UPDATE	Account   
				SET		PointsBalance = (ISNULL(PointsBalance,0) + ISNULL(@PromotionOfferValue,0))   
				WHERE	AccountId= @AccountId   
				AND		UserId = @UserId   
    
				SELECT	@CurrentPoint = ISNULL(PointsBalance,0)   
				FROM	Account   
				WHERE	AccountId= @AccountId   
				AND		UserId = @UserId  

			END  
  
		   /*---------------------------------------------------------  
			If the Promotion hit is Reward, create a reward entry   
			and link it with the Transaction entry done at first,   
			check @NewTrxId = Scope_identity()  
		   ---------------------------------------------------------*/  
		   IF ISNULL(@RewardId,0) > 0     
		   BEGIN  
				DECLARE @trxstatusStarted INT,  
						@NewRewardTrxId  INT  
  
				SELECT	@TrxTypeId= TrxTypeId   
				FROM	TrxType   
				WHERE	Name='Reward'   
				AND		ClientId=@ClientId  
  
  
				SELECT	@TrxStatusId = TrxStatusId   
				FROM	TrxStatus   
				WHERE	Name ='Started'   
				AND		ClientId = @ClientId  
       
				INSERT INTO TrxHeader  
				(  
					ClientId,DeviceId,TrxTypeId,TrxDate,  
					SiteId,TerminalId,TerminalDescription,Reference,  
					OpId,TrxStatusTypeId,InitialTransaction,OLD_TrxId,TrxCommitDate  
				)  
				VALUES        
				(  
					@ClientId,@DeviceId,@TrxTypeId,@TrxdateTime,  
					@SiteId,'','', @PosTxnId,'',@TrxStatusId,@NewTrxId,@NewTrxId,GETDATE()
				)
		  
				SELECT @NewRewardTrxId = Scope_identity();  
		 
				INSERT INTO TrxDetail  
				(  
					[Version], TrxID,LineNumber,ItemCode,DESCRIPTION,  
					Quantity,VALUE,EposDiscount,Points,   
					PromotionId, PromotionalValue,PromotionItemId,AuthorisationNr  
				)  
				SELECT	TOP 1  [Version], @NewRewardTrxId,LineNumber,ItemCode,DESCRIPTION,  
						Quantity,VALUE,EposDiscount,Points,   
						PromotionId,PromotionalValue,PromotionItemId,@RewardId  
				FROM	TrxDetail   
				WHERE	TrxID=@NewTrxId  
    
		   END  
		   /*------------------------------------------------------  
		   -- Audit Account Balance update  
		   ------------------------------------------------------*/  
			DECLARE @Message NVARCHAR(250)='',@ChangeBy INT;  
			SET @Message = 'Success, Point Applied for '+ @ActivityDescription + ',PromotionId-'+  
																	CASE   
																		WHEN ISNULL(@PromotionId,0)= 0 
																		THEN 'NOT SUPPLIED'   
																		ELSE CAST(ISNULL(@PromotionId,0) AS VARCHAR(10))  
																	END  

			EXEC TriggerActionsBasedOnTransactionHit @ClientId, @UserId, @NewTrxId

			INSERT INTO AUDIT   
			(  
				[Version], UserId, FieldName,   
				NewValue,OldValue,ChangeDate,  
				ChangeBy,Reason,ReferenceType,  
				OperatorId,SiteId  
			)  
			VALUES  
			(  
				1,@UserId,'Point Balance',   
				(@CurrentPoint + ISNULL(@PromotionOfferValue,0)) , @CurrentPoint,   
				GETDATE(), NULL,@Message,'Account',  
				null,@SiteId  
			)  
  
		   SET @Res = '1'  
		   SET @CurrentPointBalance = @CurrentPoint  
		   SET @TransactionId = @NewTrxId
	  END  
END
