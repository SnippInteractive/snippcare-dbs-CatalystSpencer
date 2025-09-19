

 CREATE PROCEDURE [dbo].[Epos_VoidFinalizedTransaction]
	-- Add the parameters for the stored procedure here
	(@TrxId INT,@SiteId INT,@TrxDate DateTime =null,@IsAnonymous bit=false,@IsCancelPaymentRefund bit=false)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ClientId INT
	DECLARE @TrxStatusId INT
	DECLARE @Completed INT
	DECLARE @Started INT
	DECLARE @NewVoidPointTrxId INT,@DeviceStatusIdInactive INT 
	SET @ClientId=(select clientid from TrxHeader where TrxId=@TrxId)
    SET @TrxStatusId=(select TrxStatusId from TrxStatus where name='Cancelled' and ClientId=@ClientId)
	SET @Started=(select TrxStatusId from TrxStatus where name='Started' and ClientId=@ClientId)
	SET @Completed=(select TrxStatusId from TrxStatus where name='Completed' and ClientId=@ClientId)
	DECLARE @TrxType INT,@TrxTypeReceipt INT,@TrxTypePurchase INT,@TrxTypeReward INT,@TrxTypePosTransaction INT
	SET @TrxType=(select TrxTypeId from TrxType where name='Void' and clientId=@ClientId)
	SET @TrxTypeReceipt=(select TrxTypeId from TrxType where name='Receipt' and clientId=@ClientId)
	SET @TrxTypePurchase=(select TrxTypeId from TrxType where name='Purchase' and clientId=@ClientId)
	SET @TrxTypePosTransaction=(select TrxTypeId from TrxType where name='PosTransaction' and clientId=@ClientId)
	SET @TrxTypeReward=(select TrxTypeId from TrxType where name='Reward' and clientId=@ClientId)
	select @DeviceStatusIdInactive = DeviceStatusId from DeviceStatus With(nolock) where Name='Inactive' and ClientId=@ClientId

	IF EXISTS(select 1 from TrxHeader where TrxStatusTypeId=@Completed and TrxId=@TrxId)
	BEGIN
	DECLARE @BonusPointsEarned DECIMAL(18,2)
	DECLARE @LoyaltyDevice VARCHAR(50)
	DECLARE @AccountId INT
	SET @BonusPointsEarned=(select sum(points) from TrxDetail where TrxId=@TrxId)
	SET @LoyaltyDevice=(select deviceid from TrxHeader where TrxStatusTypeId=@Completed and TrxId=@TrxId)

	DECLARE @OldTrxId INT
	IF ISNULL(@LoyaltyDevice,'') != ''
	BEGIN
		--PRINT @TrxId
		--PRINT @LoyaltyDevice
		SELECT @OldTrxId = TrxId FROM TrxHeader with(nolock) Where DeviceId = @LoyaltyDevice AND OLD_TrxId = @TrxId ---AND OLD_TrxId IS NOT NULL
	
		IF ISNULL(@OldTrxId,0) > 0
		BEGIN
			DECLARE @BonusPointsEarnedTrxPromo DECIMAL(18,2)
			SET @BonusPointsEarnedTrxPromo=(select sum(points) from TrxDetail where TrxId=@OldTrxId)

			IF ISNULL(@BonusPointsEarnedTrxPromo,0) > 0
			BEGIN
				--DECLARE @NewVoidPointTrxId INT
				INSERT INTO TrxHeader (ClientId,DeviceId,TrxTypeId,TrxDate,SiteId,TerminalId,TerminalDescription,Reference,OpId,TrxStatusTypeId,TrxCommitDate,Old_TrxID)
				SELECT ClientId,DeviceId,@TrxType,getdate() AS TrxDate,SiteId,TerminalId,TerminalDescription,Reference,OpId,TrxStatusTypeId,getdate() AS TrxCommitDate,@OldTrxId AS Old_TrxID 
				FROM TrxHeader with(nolock) 
				Where TrxId = @OldTrxId

				SELECT @NewVoidPointTrxId = Scope_identity();

				INSERT INTO TrxDetail ([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,PromotionItemId)
				SELECT '1' AS [Version], @NewVoidPointTrxId,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,ISNULL(Points,0) * -1 AS Points , PromotionId, PromotionalValue,PromotionItemId
				FROM TrxDetail with(nolock)
				Where TrxId = @OldTrxId AND ISNULL(Points,0) > 0

				SET @BonusPointsEarned = ISNULL(@BonusPointsEarned,0) + ISNULL(@BonusPointsEarnedTrxPromo,0)
				
			END
			--Cancel the second transaction created by first transaction EG- Reward trx created by a valid Receipt 
			IF NOT EXISTS (SELECT 1 FROM TrxHeader with(nolock) Where  TrxId=@OldTrxId AND TrxStatusTypeId = @Completed AND TrxTypeId = @TrxTypeReward)
			BEGIN
				update TrxHeader set TrxStatusTypeId = @TrxStatusId where TrxId=@OldTrxId --AND TrxStatusTypeId != @Completed-- @OldTrxId is the trxid of second transaction
			END
		END
	END

	DECLARE @Userid INT
	DECLARE @NewTrxId INT
	SET @Userid=(select userid from device where deviceid=@LoyaltyDevice)
	DECLARE @ParentLoyaltyDeviceId VARCHAR(50)
	DECLARE @CurrentBalance decimal(18,2)
	if exists(select 1 from memberlink m inner join 
	memberlinktype mt on m.linktype=mt.MemberLinkTypeId where name='Community' and MemberId2=@Userid and CommunityId is not null)
	begin
		Declare @ParentUserId INT
		SET @ParentUserId=(select MemberId1 from memberlink m inner join 
		memberlinktype mt on m.linktype=mt.MemberLinkTypeId where name='Community' and MemberId2=@Userid and CommunityId is not null)
		select top 1 @AccountId=d.AccountId,@ParentLoyaltyDeviceId=d.DeviceId from device d with(nolock)inner join devicestatus ds on d.devicestatusid=ds.DeviceStatusId
							   inner join deviceprofile dp on d.id=dp.DeviceId
							   inner join DeviceProfileTemplate dpt on dp.deviceprofileid=dpt.id
							   inner join DeviceProfileTemplateType dptp on dpt.DeviceProfileTemplateTypeId=dptp.Id where dptp.Name='Loyalty' and d.userid=@ParentUserId


    UPDATE Account SET PointsBalance=PointsBalance-@BonusPointsEarned where AccountId=@AccountId	
	SET @CurrentBalance=(select PointsBalance from Account where AccountId=@AccountId)

		IF(isnull(@AccountId,0)>0)
	BEGIN	
	
	
	insert into trxheader ([Version]
           ,[DeviceId]
           ,[TrxTypeId]
           ,[TrxDate]
           ,[ClientId]
           ,[SiteId]
           ,[TerminalId]
           ,[Reference]
           ,[OpId]
           ,[TrxStatusTypeId]
           ,[CreateDate]
           ,[TerminalDescription]
           ,[BatchId]
           ,[Batch_Urn]
           ,[TrxCommitDate]
           ,[InitialTransaction]
           ,[DeviceIdentity]
           ,[CallContextId]
           ,[TerminalExtra]
           ,[AccountCashBalance]
           ,[AccountPointsBalance]
           ,[ImportUniqueId]
           ,[EposTrxId]
           ,[TerminalExtra2]
           ,[TerminalExtra3]
           ,[MemberId]
           ,[TotalPoints]
           ,[OLD_TrxId]
           ,[LastUpdatedDate]
           ,[IsAnonymous]
           ,[ReservationId],[IsTransferred])
    select [Version]
           ,@ParentLoyaltyDeviceId
           ,@TrxType
           ,@TrxDate
           ,[ClientId]
           ,@SiteId
           ,[TerminalId]
           ,[Reference]
           ,[OpId]
           ,[TrxStatusTypeId]
           ,@TrxDate
           ,[TerminalDescription]
           ,[BatchId]
           ,[Batch_Urn]
           ,@TrxDate
           ,[InitialTransaction]
           ,[DeviceIdentity]
           ,[CallContextId]
           ,[TerminalExtra]
           ,[AccountCashBalance]
           ,@CurrentBalance
           ,[ImportUniqueId]
           ,[EposTrxId]
           ,[TerminalExtra2]
           ,[TerminalExtra3]
           ,[MemberId]
           ,[TotalPoints]
           ,isnull(@TrxId,1)
           ,[LastUpdatedDate],@IsAnonymous,[ReservationId],[IsTransferred] from Trxheader where trxId=@TrxId


      SELECT @NewTrxId=SCOPE_IDENTITY()

	  INSERT INTO [dbo].[TrxDetail]
           ([Version]
           ,[TrxID]
           ,[LineNumber]
           ,[ItemCode]
           ,[Description]
           ,[Anal1]
           ,[Anal2]
           ,[Anal3]
           ,[Anal4]
           ,[Quantity]
           ,[Value]
           ,[Points]
           ,[PromotionID]
           ,[PromotionalValue]
           ,[EposDiscount]
           ,[LoyaltyDiscount]
           ,[AuthorisationNr]
           ,[status]
           ,[BonusPoints]
           ,[PromotionItemId]
           ,[VAT]
           ,[VATPercentage]
           ,[OriginalTrxDetailId]
           ,[Anal5]
           ,[Anal6]
           ,[Anal7]
           ,[Anal8]
           ,[Anal9]
           ,[Anal10]
           ,[HomeCurrencyCode]
           ,[ConvertedNetValue]
           ,[Anal11]
           ,[Anal12]
           ,[Anal13]
           ,[Anal14]
           ,[Anal15]
           ,[Anal16])

      SELECT [Version]
      ,@NewTrxId
      ,[LineNumber]
      ,[ItemCode]
      ,[Description]
      ,[Anal1]
      ,[Anal2]
      ,[Anal3]
      ,[Anal4]
      ,[Quantity]
      ,-[Value]
      ,-[Points]
      ,[PromotionID]
      ,-[PromotionalValue]
      ,-[EposDiscount]
      ,-[LoyaltyDiscount]
      ,[AuthorisationNr]
      ,[status]
      ,-[BonusPoints]
      ,[PromotionItemId]
      ,-[VAT]
      ,[VATPercentage]
      ,[OriginalTrxDetailId]
      ,[Anal5]
      ,[Anal6]
      ,[Anal7]
      ,[Anal8]
      ,[Anal9]
      ,[Anal10]
      ,[HomeCurrencyCode]
      ,[ConvertedNetValue]
      ,[Anal11]
      ,[Anal12]
      ,[Anal13]
      ,[Anal14]
      ,[Anal15]
      ,[Anal16]
      FROM [dbo].[TrxDetail] where trxid=@TrxId


	  INSERT INTO [dbo].[TrxPayment]
           ([Version]
           ,[TrxID]
           ,[TenderTypeId]
           ,[TenderAmount]
           ,[Currency]
           ,[TenderDeviceId]
           ,[AuthNr]
           ,[TenderProcessFlags]
           ,[ExtraInfo])
		   SELECT [Version]
      ,@NewTrxId
      ,[TenderTypeId]
      ,-[TenderAmount]
      ,[Currency]
      ,[TenderDeviceId]
      ,[AuthNr]
      ,[TenderProcessFlags]
      ,[ExtraInfo]
       FROM [dbo].[TrxPayment] where TrxId=@TrxId

	END

	end
	else
	begin	
	SET @AccountId=(select isnull(accountId,0) from device where deviceid=@LoyaltyDevice)
	UPDATE Account SET PointsBalance=PointsBalance-@BonusPointsEarned where AccountId=@AccountId	
	SET @CurrentBalance=(select PointsBalance from Account where AccountId=@AccountId)
	IF ISNULL(@NewVoidPointTrxId,0) > 0
	BEGIN
		UPDATE TrxHeader SET AccountPointsBalance = ISNULL(@CurrentBalance,0) WHERE TrxId = @NewVoidPointTrxId AND ISNULL(AccountPointsBalance,0) = 0
	END
	end

	IF(isnull(@AccountId,0)>0)
	BEGIN	
	

	insert into trxheader ([Version]
           ,[DeviceId]
           ,[TrxTypeId]
           ,[TrxDate]
           ,[ClientId]
           ,[SiteId]
           ,[TerminalId]
           ,[Reference]
           ,[OpId]
           ,[TrxStatusTypeId]
           ,[CreateDate]
           ,[TerminalDescription]
           ,[BatchId]
           ,[Batch_Urn]
           ,[TrxCommitDate]
           ,[InitialTransaction]
           ,[DeviceIdentity]
           ,[CallContextId]
           ,[TerminalExtra]
           ,[AccountCashBalance]
           ,[AccountPointsBalance]
           ,[ImportUniqueId]
           ,[EposTrxId]
           ,[TerminalExtra2]
           ,[TerminalExtra3]
           ,[MemberId]
           ,[TotalPoints]
           ,[OLD_TrxId]
           ,[LastUpdatedDate]
           ,[IsAnonymous]
           ,[ReservationId],[IsTransferred])

    select [Version]
           ,[DeviceId]
           ,@TrxType
           ,@TrxDate
           ,[ClientId]
           ,@SiteId
           ,[TerminalId]
           ,[Reference]
           ,[OpId]
           ,[TrxStatusTypeId]
           ,@TrxDate
           ,[TerminalDescription]
           ,[BatchId]
           ,[Batch_Urn]
           ,@TrxDate
           ,[InitialTransaction]
           ,[DeviceIdentity]
           ,[CallContextId]
           ,[TerminalExtra]
           ,[AccountCashBalance]
           ,@CurrentBalance
           ,[ImportUniqueId]
           ,[EposTrxId]
           ,[TerminalExtra2]
           ,[TerminalExtra3]
           ,[MemberId]
           ,[TotalPoints]
           ,@TrxId
           ,[LastUpdatedDate],@IsAnonymous,[ReservationId],[IsTransferred] from Trxheader where trxId=@TrxId


      SELECT @NewTrxId=SCOPE_IDENTITY()

	 INSERT INTO [dbo].[TrxDetail]
           ([Version]
           ,[TrxID]
           ,[LineNumber]
           ,[ItemCode]
           ,[Description]
           ,[Anal1]
           ,[Anal2]
           ,[Anal3]
           ,[Anal4]
           ,[Quantity]
           ,[Value]
           ,[Points]
           ,[PromotionID]
           ,[PromotionalValue]
           ,[EposDiscount]
           ,[LoyaltyDiscount]
           ,[AuthorisationNr]
           ,[status]
           ,[BonusPoints]
           ,[PromotionItemId]
           ,[VAT]
           ,[VATPercentage]
           ,[OriginalTrxDetailId]
           ,[Anal5]
           ,[Anal6]
           ,[Anal7]
           ,[Anal8]
           ,[Anal9]
           ,[Anal10]
           ,[HomeCurrencyCode]
           ,[ConvertedNetValue]
           ,[Anal11]
           ,[Anal12]
           ,[Anal13]
           ,[Anal14]
           ,[Anal15]
           ,[Anal16])

      SELECT [Version]
      ,@NewTrxId
      ,[LineNumber]
      ,[ItemCode]
      ,[Description]
      ,[Anal1]
      ,[Anal2]
      ,[Anal3]
      ,[Anal4]
      ,[Quantity]
      ,-[Value]
      ,-[Points]
      ,[PromotionID]
      ,-[PromotionalValue]
      ,-[EposDiscount]
      ,-[LoyaltyDiscount]
      ,[AuthorisationNr]
      ,[status]
      ,-[BonusPoints]
      ,[PromotionItemId]
      ,-[VAT]
      ,[VATPercentage]
      ,[OriginalTrxDetailId]
      ,[Anal5]
      ,[Anal6]
      ,[Anal7]
      ,[Anal8]
      ,[Anal9]
      ,[Anal10]
      ,[HomeCurrencyCode]
      ,[ConvertedNetValue]
      ,[Anal11]
      ,[Anal12]
      ,[Anal13]
      ,[Anal14]
      ,[Anal15]
      ,[Anal16]
      FROM [dbo].[TrxDetail] where trxid=@TrxId


	  INSERT INTO [dbo].[TrxPayment]
           ([Version]
           ,[TrxID]
           ,[TenderTypeId]
           ,[TenderAmount]
           ,[Currency]
           ,[TenderDeviceId]
           ,[AuthNr]
           ,[TenderProcessFlags]
           ,[ExtraInfo])

		   SELECT [Version]
      ,@NewTrxId
      ,[TenderTypeId]
      ,-[TenderAmount]
      ,[Currency]
      ,[TenderDeviceId]
      ,[AuthNr]
      ,[TenderProcessFlags]
      ,[ExtraInfo]
       FROM [dbo].[TrxPayment] where TrxId=@TrxId

	END
	
	-- Activate Vouchers
	select TrxVoucherId into #vouchers from TrxDetail td join TrxVoucherDetail tv on td.trxdetailid=tv.trxdetailid where td.trxid=@TrxId
	DECLARE @DeviceStatus INT
	DECLARE @DeviceProfileStatus INT
	SET @DeviceStatus=(select DeviceStatusid from Devicestatus where name='Active' and ClientId=@ClientId)
	SET @DeviceProfileStatus=(select DeviceProfileStatusId from DeviceProfileStatus where name='Active' and ClientId=@ClientId)

	Update Device SEt DeviceStatusId=@DeviceStatus where DeviceId in(select * from #vouchers)
	UPDATE DeviceProfile Set Statusid=@DeviceProfileStatus where deviceid in (select id from device where deviceid in(select * from #vouchers))


	-- Activate giftcards to do

	if(@IsCancelPaymentRefund=0)
	begin
	select TenderAmount,TenderDeviceId 
	into #FinancialVoucher 
	from TrxPayment p inner join 
	TenderType tp on p.TenderTypeId=tp.TenderTypeId 
	where tp.Name='FinancialVoucher' and TrxId=@TrxId

	DECLARE @TenderId VARCHAR(50)
	DECLARE @TenderAmount Decimal(18,2)
	DECLARE @TAccountId INT
	DECLARE db_cursor CURSOR FOR  
	SELECT TenderAmount,TenderDeviceId
	FROM #FinancialVoucher

	OPEN db_cursor  
	FETCH NEXT FROM db_cursor INTO @TenderAmount,@TenderId  

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		   SET @TAccountId=(select accountid from device where deviceid=@TenderId)
		   update account set MonetaryBalance=MonetaryBalance+ isnull(@TenderAmount,0)  where accountid=@TAccountId

		   FETCH NEXT FROM db_cursor INTO @TenderAmount,@TenderId   
	END  

	CLOSE db_cursor  
	DEALLOCATE db_cursor 
	end
	-- Change Trxstatus
	UPDATE TrxHeader SET TrxStatusTypeId=@TrxStatusId,IsAnonymous=@IsAnonymous WHERE TrxId=@TrxId

--*****************************************************************************************************---
--STAMPCARD AFTER VALE UPDATE - Handiled only StampCardValue Reward AND VOUCHER
	SELECT Id,DeviceId,EmbossLine3 AS PromotionId INTO #SampVoucher FROM Device WHERE EmbossLine2 = 'STAMP-' +CONVERT(NVARCHAR(15),@TrxId)
	IF EXISTS (SELECT 1 FROM #SampVoucher)
	BEGIN
		UPDATE Device SET DeviceStatusId = @DeviceStatusIdInactive WHERE Id IN(SELECT Id FROM #SampVoucher)

		--SELECT top 1 dpt.Id, 
		--from Device d inner join DeviceProfile dp on d.id=dp.DeviceId 
		--inner join DeviceProfileTemplate dpt on dp.DeviceProfileId = dpt.Id
		--inner join #SampVoucher sv on d.DeviceId = sv.DeviceId
	
	END

	IF ISNULL(@Userid,0) > 0
	BEGIN

	SELECT PromotionId,TrxDetailId,Points INTO #TEMPPoints FROM TrxDetail with(nolock) WHERE  TrxId=@TrxId AND PromotionId IS NOT NULL
	
	select pc.Name,tp.PromotionId,tp.TrxDetailId,ISNULL(tp.Points,0)Points,ISNULL(p.QualifyingProductQuantity,0) QualifyingProductQuantity INTO #StampPoints from promotion p with(nolock)
	inner join PromotionCategory pc with(nolock) on p.PromotionCategoryId = pc.id 
	INNER JOIN #TEMPPoints tp on p.id = tp.PromotionId
	INNER JOIN PromotionOfferType pf on p.PromotionOfferTypeId = pf.id
	WHERE pc.Name IN('StampCardQuantity','StampCardValue') AND pf.Name IN('Reward')

	IF EXISTS (SELECT 1 FROM #StampPoints)
	BEGIN

		SELECT MAX(PromotionId)PromotionId,SUM(Points)Points,MAX(Name) Name,MAX(QualifyingProductQuantity)QualifyingProductQuantity INTO #StampPointsPerPromotion 
		FROM #StampPoints GROUP BY PromotionId
		
		DECLARE @PromotionId INT, @StampCardType NVARCHAR(50),@QualifyingProductQuantity DECIMAL(18,2),@Points Decimal(18,2)
		SELECT TOP 1 @PromotionId = PromotionId,@StampCardType =  Name,@QualifyingProductQuantity = QualifyingProductQuantity,@Points = Points FROM #StampPointsPerPromotion
		
		DECLARE @ActualRewardCount INT,@ActualStartedRewardCount INT,@CancelRewardFLAG INT = 0; 
			
		SELECT DISTINCT ISNULL(Points,0) Points,td.TrxDetailId,td.TrxId, th.TrxStatusTypeId, th.TrxTypeId,td.Quantity,th.TerminalDescription,td.PromotionId,Old_TrxId,LineNumber 
		INTO #FullTrxDetails FROM TrxDetail td  with(nolock)
		Inner Join TrxHeader th with(nolock) on td.TrxId = th.TrxId 
		Inner Join Device D with(nolock) on th.DeviceId = D.DeviceId 
		WHERE D.UserId =  @Userid 

		select @ActualRewardCount =  SUM(Quantity) from #FullTrxDetails WHERE
				TrxStatusTypeId IN (@Completed,@Started) AND TrxTypeId=@TrxTypeReward AND ISNULL(TerminalDescription,'') != 'Fulfilment Partner'

		select @ActualStartedRewardCount =  SUM(Quantity) from #FullTrxDetails WHERE
				TrxStatusTypeId IN (@Started) AND TrxTypeId=@TrxTypeReward AND ISNULL(TerminalDescription,'') != 'Fulfilment Partner'
		
		DECLARE @AfterValue DECIMAL(18,2),@PreviousStampCount DECIMAL(18,2)
		SELECT TOP 1  @AfterValue = ISNULL(AfterValue,0),@PreviousStampCount = isnull(PreviousStampCount,0) from PromotionStampCounter with(nolock) WHERE UserId = @Userid AND PromotionId =  @PromotionId
		DECLARE @AfterValueUpdated DECIMAL(18,2) = 0;
		DECLARE @PointsNotAvilableForDeduct Decimal(18,2),@DeactivateStartedReward INT
		DECLARE @RewardTrxId INT,@Quantity Decimal(18,2),@TrxDetailId INT,@Old_TrxIdReward INT,@RewardLineNumber INT

		IF ISNULL(@StampCardType,'') = 'StampCardValue' AND ISNULL(@Points,0) > 0
		BEGIN
			IF EXISTS(SELECT 1 FROM PromotionRedemptionCount with(nolock) WHERE TrxId = @TrxId AND PromotionId =  @PromotionId)
			BEGIN
				PRINT 'Transaction with reward'
				DECLARE @RewardCount INT,@PointsUsed DECIMAL(18,2);
				SELECT @RewardCount = Count(PromotionId) FROM PromotionRedemptionCount with(nolock) WHERE TrxId = @TrxId AND PromotionId =  @PromotionId
				SET @PointsUsed = ISNULL(@RewardCount,0) * @QualifyingProductQuantity
				IF @PointsUsed <= @Points
				BEGIN
					PRINT 'Assigned reward/Voucher with out previous value'
					SET @AfterValueUpdated = @Points - @PointsUsed;
					IF @AfterValue >= @AfterValueUpdated
					BEGIN
						SET @AfterValue = @AfterValue - @AfterValueUpdated
					END
					ELSE
					BEGIN
					IF ISNULL(@ActualStartedRewardCount,0) > 0
					BEGIN
						SET @CancelRewardFLAG = 1;
					END
					ELSE
					BEGIN
						SET @AfterValue = 0;
					END
					
				END
				END
				ELSE
				BEGIN
					PRINT 'Assigned reward/Voucher with previous value'
					SET @AfterValueUpdated = @PointsUsed - @Points;
						SET @AfterValue = @AfterValueUpdated + @AfterValue;
				END
			END
			ELSE
			BEGIN
				PRINT 'Transaction without reward'
				IF @AfterValue >= @Points
				BEGIN
					SET @AfterValue = @AfterValue - @Points
				END
				ELSE
				BEGIN
					IF ISNULL(@ActualStartedRewardCount,0) > 0
					BEGIN
						SET @CancelRewardFLAG = 1;
						--some other transactions are used some points from this transaction for assign reward 
					END
					ELSE
					BEGIN
					SET @AfterValue = 0;
					END
					
				END				
			END
		END

		IF ISNULL(@CancelRewardFLAG,0) = 1 AND ISNULL(@ActualStartedRewardCount,0) > 0
		BEGIN
			--some other transactions are used some points from this transaction for assign reward 
						PRINT 'StartedRewardCount--------------------'
						SET @PointsNotAvilableForDeduct = @Points - @AfterValue
						SET @DeactivateStartedReward = CEILING(@PointsNotAvilableForDeduct / @QualifyingProductQuantity )
						IF ISNULL(@DeactivateStartedReward,0) > 0
						BEGIN
							SET @AfterValueUpdated = 0;
							DECLARE RewardCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
							SELECT Distinct TrxId,Quantity,TrxDetailId,Old_TrxId,LineNumber from #FullTrxDetails WHERE TrxStatusTypeId IN (@Started) AND TrxTypeId=@TrxTypeReward AND ISNULL(TerminalDescription,'') != 'Fulfilment Partner' ORDER BY Quantity
							OPEN RewardCursor                                                  
								FETCH NEXT FROM RewardCursor           
								INTO @RewardTrxId,@Quantity ,@TrxDetailId,@Old_TrxIdReward ,@RewardLineNumber                             
								WHILE @@FETCH_STATUS = 0 
								BEGIN 
									PRINT @RewardTrxId
									PRINT @Old_TrxIdReward
									IF ISNULL(@DeactivateStartedReward,0) >0 
									BEGIN
										IF isnull(@Quantity,0) = ISNULL(@DeactivateStartedReward,0) 
										BEGIN
											PRINT 'A'
											SET @AfterValueUpdated = @AfterValueUpdated + (@Quantity * @QualifyingProductQuantity)
											UPDATE TrxHeader SET TrxStatusTypeId = @TrxStatusId,TerminalDescription =ISNULL(TerminalDescription,'')+' Void' Where Trxid =@RewardTrxId AND TrxStatusTypeId = @Started
											DELETE [PromotionRedemptionCount] WHERE TrxId =  @Old_TrxIdReward
											UPDATE TrxDetailPromotion SET ValueUsed = 0  where TrxDetailId IN (SELECT top 1 TrxDetailId FROM #FullTrxDetails WHERE TrxId = @Old_TrxIdReward AND LineNumber = @RewardLineNumber)
											SET @DeactivateStartedReward = 0
										END
										ELSE IF isnull(@Quantity,0) > ISNULL(@DeactivateStartedReward,0) 
										BEGIN	
											PRINT 'B'
											SET @AfterValueUpdated = @AfterValueUpdated + (@DeactivateStartedReward * @QualifyingProductQuantity)
											UPDATE TrxHeader SET TerminalDescription =ISNULL(TerminalDescription,'')+' Void' Where Trxid =@RewardTrxId AND TrxStatusTypeId = @Started
											UPDATE TrxDetail SET Quantity = Quantity - @DeactivateStartedReward  Where Trxid =@RewardTrxId AND TrxDetailId = @TrxDetailId
											
											DELETE  top (@DeactivateStartedReward) FROM [PromotionRedemptionCount] WHERE TrxId =  @Old_TrxIdReward
											SET @DeactivateStartedReward =  @Quantity - @DeactivateStartedReward
											UPDATE TrxDetailPromotion SET ValueUsed = ((ValueUsed/@Quantity) *@DeactivateStartedReward)  where TrxDetailId IN (SELECT top 1 TrxDetailId FROM #FullTrxDetails WHERE TrxId = @Old_TrxIdReward AND LineNumber = @RewardLineNumber)
											SET @DeactivateStartedReward = 0;
										END
										ELSE IF isnull(@Quantity,0) < ISNULL(@DeactivateStartedReward,0) 
										BEGIN
											PRINT 'C'
											SET @AfterValueUpdated = @AfterValueUpdated + (@Quantity * @QualifyingProductQuantity)
											UPDATE TrxHeader SET TrxStatusTypeId = @TrxStatusId,TerminalDescription =ISNULL(TerminalDescription,'')+' Void' Where Trxid =@RewardTrxId AND TrxStatusTypeId = @Started
											DELETE [PromotionRedemptionCount] WHERE TrxId =  @Old_TrxIdReward
											UPDATE TrxDetailPromotion SET ValueUsed = 0  where TrxDetailId IN (SELECT top 1 TrxDetailId FROM #FullTrxDetails WHERE TrxId = @Old_TrxIdReward AND LineNumber = @RewardLineNumber)
											SET @DeactivateStartedReward = @DeactivateStartedReward - @Quantity;
										END
									END
									ELSE
									BEGIN
										BREAK;
									END
									FETCH NEXT FROM RewardCursor     
									INTO @RewardTrxId,@Quantity  ,@TrxDetailId,@Old_TrxIdReward ,@RewardLineNumber   
								END     
							CLOSE RewardCursor;    
							DEALLOCATE RewardCursor; 

							PRINT @AfterValueUpdated
							PRINT @AfterValue
							PRINT @Points
							SET @AfterValue = (@AfterValue + @AfterValueUpdated) - @Points
						END
						PRINT '----------------------------------'
		END

		DELETE FROM #FullTrxDetails WHERE TrxId >= @TrxId
		DECLARE @RemoveLastTrxId INT
		SELECT @RemoveLastTrxId = MAX(TrxId) FROM #FullTrxDetails  WHERE TrxStatusTypeId = @Completed  AND TrxTypeId IN(@TrxTypeReceipt,@TrxTypePurchase,@TrxTypePosTransaction) AND Points > 0 AND PromotionId =  @PromotionId
		DELETE FROM #FullTrxDetails WHERE TrxId = @RemoveLastTrxId
		SELECT @PreviousStampCount = SUM(Points) FROM #FullTrxDetails  WHERE TrxStatusTypeId = @Completed  AND TrxTypeId IN(@TrxTypeReceipt,@TrxTypePurchase,@TrxTypePosTransaction) AND Points > 0 AND PromotionId =  @PromotionId

		SET @PreviousStampCount = ISNULL(@PreviousStampCount,0) - (@ActualRewardCount * 30)
		IF ISNULL(@PreviousStampCount,0) < 0
		BEGIN
			SET @PreviousStampCount = 0
		END
		IF ISNULL(@AfterValue,0) < 0
		BEGIN
			SET @AfterValue = 0
		END
		PRINT @AfterValue
		PRINT @PreviousStampCount
		UPDATE PromotionStampCounter SET AfterValue = ISNULL(@AfterValue,0),PreviousStampCount = ISNULL(@PreviousStampCount,0) WHERE isnull(UserId,0) > 0 AND UserId = @Userid AND PromotionId =  @PromotionId
	END
	END
--STAMPCARD AFTER VALE UPDATE

	DELETE [PromotionRedemptionCount] WHERE  TrxId=@TrxId

	SELECT 1 AS RESULT
	END
	ELSE IF EXISTS(select 1 from TrxHeader where TrxStatusTypeId=@Started and TrxId=@TrxId)
	BEGIN
	UPDATE TrxHeader SET TrxTypeId=@TrxType,TrxStatusTypeId=@TrxStatusId,IsAnonymous=@IsAnonymous WHERE TrxId=@TrxId

	DELETE [PromotionRedemptionCount] WHERE  TrxId=@TrxId

	SELECT 1 AS RESULT
	END
	else
	begin
	select 0 as RESULT
	end
END
