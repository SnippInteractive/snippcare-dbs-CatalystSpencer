create PROCEDURE [dbo].[AssignDeviceToMemberAndMergeStamps] (      											                                               
    @ClientId			INT,
	@DeviceId			NVARCHAR(50),
	@MemberId			INT
 )                                                 
AS    
BEGIN    

	Declare @ExistingLoyaltyDeviceId NVARCHAR(50)
	Declare @DeviceStatusIdBlocked INT
	Declare @DeviceIdentifier INT
	Declare @DeviceIdentifierExistsingDeviceId INT
	

	Select top 1 @ExistingLoyaltyDeviceId = d.DeviceId from 
				Device d with(nolock)
				inner join DeviceLotDeviceProfile dl with(nolock) on d.DeviceLotId = dl.DeviceLotId
				inner join DeviceStatus ds with(nolock) on ds.DeviceStatusId = d.DeviceStatusId
				inner join DeviceProfileTemplate dpt with(nolock) on dpt.Id = dl.DeviceProfileId
				inner join DeviceProfileTemplateType dptt with(nolock) on dptt.Id = dpt.DeviceProfileTemplateTypeId
				Where ds.ClientId = @ClientId
				and ds.[Name] = 'Active'
				and dptt.[Name] = 'Loyalty'
				and d.UserId = @MemberId

	IF @ExistingLoyaltyDeviceId is not null
	BEGIN

		SELECT @DeviceStatusIdBlocked = DeviceStatusId FROM DeviceStatus WHERE [Name] = 'Blocked' AND ClientId = @ClientId

		Update Device 
		Set userId = @MemberId,
			DeviceStatusId = @DeviceStatusIdBlocked
		Where DeviceId = @DeviceId

		Select @DeviceIdentifier = Id From Device Where DeviceId = @DeviceId
		Select @DeviceIdentifierExistsingDeviceId = Id From Device Where DeviceId = @ExistingLoyaltyDeviceId

		IF EXISTS (select 1 from [PromotionStampCounter] where DeviceIdentifier = @DeviceIdentifier)
		BEGIN

			DROP TABLE IF EXISTS #TempPromotionStampCounter

			Declare @UserId int,@PromotionId int ,@BeforeValue int,@PreviousCount decimal(18,2),@AfterValue decimal(18,2)
			Declare @OldBeforeValue int,@OldPreviousCount decimal(18,2),@OldAfterValue decimal(18,2);
			Declare @updatedBeforeValue int,@updatedPreviousCount decimal(18,2),@updatedAfterValue decimal(18,2),@reason nvarchar(max), @oldDeviceIdentifier int;
			Declare @oldValue nvarchar(50)=''
			Declare @newValue nvarchar(50)=''

			SELECT distinct PromotionId,UserId,BeforeValue,AfterValue,PreviousStampCount into #TempPromotionStampCounter from [dbo].[PromotionStampCounter] where DeviceIdentifier=@DeviceIdentifier
			DECLARE db_cursor CURSOR FOR  
				SELECT distinct PromotionId,UserId,BeforeValue,AfterValue,PreviousStampCount from  #TempPromotionStampCounter
			-----------------------------------------------------
			OPEN db_cursor  
			FETCH NEXT FROM db_cursor INTO @PromotionId ,@UserId,@BeforeValue, @AfterValue,@PreviousCount
				
				WHILE @@FETCH_STATUS = 0  
				BEGIN  
					IF ISNULL(@PromotionId,0) > 0 
					BEGIN
						IF EXISTS (SELECT 1 from [PromotionStampCounter] where   UserId=@MemberId and PromotionId = @PromotionId)
						BEGIN
							SELECT @OldBeforeValue = BeforeValue,@OldPreviousCount = PreviousStampCount,@OldAfterValue= AfterValue from [PromotionStampCounter] where   UserId=@MemberId and PromotionId = @PromotionId

							UPDATE [PromotionStampCounter] 
							set @updatedAfterValue =  AfterValue+@AfterValue, 
								AfterValue = AfterValue+@AfterValue,
								@updatedBeforeValue = BeforeValue+@BeforeValue, 
								BeforeValue = BeforeValue+@BeforeValue ,
								@updatedPreviousCount = PreviousStampCount + @PreviousCount,
								PreviousStampCount= isnull(PreviousStampCount,0.0) + isnull(@PreviousCount,0.0) 
							where UserId=@MemberId and PromotionId = @PromotionId

							--Audit 
							SET @reason = 'Anonymous Account Merge : AfterValueOld-' + convert(varchar(5),@OldAfterValue) + ',AfterValueNew-'+ convert(varchar(5),@updatedAfterValue) + ',BeforeValueOld -'+convert(varchar(5),@OldBeforeValue)+',BeforeValueNew- '+convert(varchar(5),@updatedBeforeValue)+
							',PreviousStampCountOld-'+convert(varchar(5),@OldPreviousCount)+',PreviousStampCountNew-'+ convert(varchar(5),@updatedPreviousCount) + ',PromotionId-' + convert(varchar(5),@PromotionId);

							 SET @oldValue = CAST(@OldAfterValue AS nvarchar(10))
							 SET @newValue = CAST(@updatedAfterValue AS nvarchar(10))

							 EXEC Insert_Audit '', @MemberId, NULL, '[PromotionStampCounter]', 'StampCount',@newValue,@oldValue ,@reason
				 
							SELECT @OldBeforeValue = BeforeValue,@OldPreviousCount =PreviousStampCount,@OldAfterValue= AfterValue from [PromotionStampCounter] where   DeviceIdentifier=@DeviceIdentifier and PromotionId = @PromotionId				
							UPDATE [PromotionStampCounter] 
							set AfterValue = 0, 
								BeforeValue = 0,
								PreviousStampCount = 0,
								[Version] = 999 -- identify its anonymised
								--,DeviceIdentifier = @DeviceIdentifierExistsingDeviceId
							where DeviceIdentifier=@DeviceIdentifier 
								and PromotionId = @PromotionId

							--Audit 
							SET @reason = 'Anonymous Account Merge : AfterValueOld-' + convert(varchar(5),@OldAfterValue) + ',AfterValueNew-'+ convert(varchar(5),0) + ',BeforeValueOld -'+convert(varchar(5),@OldBeforeValue)+',BeforeValueNew- '+convert(varchar(5),0)+
							',PreviousStampCountOld-'+convert(varchar(5),@OldPreviousCount)+',PreviousStampCountNew-'+ convert(varchar(5),0)+ ',PromotionId-' + convert(varchar(5),@PromotionId)+',DeviceIdentifier-'+convert(varchar(5),@DeviceIdentifier);

							  SET @oldValue = CAST(@OldAfterValue AS nvarchar(10))
							  SET @newValue = CAST(0 AS nvarchar(10))

							 EXEC Insert_Audit '', @MemberId, NULL, '[PromotionStampCounter]', 'StampCount',@newValue,@oldValue,@reason

						END
						ELSE
						BEGIN
							print 'not exist with promotionid'

							INSERT INTO [PromotionStampCounter] 
							SELECT [Version],@MemberId,[PromotionId],[TrxId],GETDATE(),[BeforeValue],[AfterValue],[PreviousStampCount],[OnTheFlyQuantity],@DeviceIdentifierExistsingDeviceId
							FROM [dbo].[PromotionStampCounter] WHERE DeviceIdentifier=@DeviceIdentifier and PromotionId= @PromotionId

							--Audit 
							SET @reason = 'Anonymous Account Merge : copied stampcounter data for PromotionId-'+convert(varchar(10),@PromotionId) + ',DeviceIdentifier-'+convert(varchar(10),@DeviceIdentifier);
							SET @oldValue = CAST(0 AS nvarchar(10))
							SET @newValue = CAST(@MemberId AS nvarchar(10))
							EXEC Insert_Audit '', @MemberId, NULL, '[PromotionStampCounter]', 'StampCount',@newValue,@oldValue,@reason


							SELECT @OldBeforeValue = BeforeValue,@OldPreviousCount =PreviousStampCount,@OldAfterValue= AfterValue from [PromotionStampCounter] where   DeviceIdentifier=@DeviceIdentifier and PromotionId = @PromotionId				
							
							UPDATE [PromotionStampCounter] 
							set AfterValue = 0, 
								BeforeValue = 0,
								PreviousStampCount = 0,
								[Version] = 999 -- identify its anonymised
							WHERE PromotionId = @PromotionId
							AND  DeviceIdentifier = @DeviceIdentifier

							--Audit 
							SET @reason = 'Anonymous Account Merge : AfterValueOld-' + convert(varchar(5),@OldAfterValue) + ',AfterValueNew-'+ convert(varchar(5),0) + ',BeforeValueOld -'+convert(varchar(5),@OldBeforeValue)+',BeforeValueNew- '+convert(varchar(5),0)+
							',PreviousStampCountOld-'+convert(varchar(5),@OldPreviousCount)+',PreviousStampCountNew-'+ convert(varchar(5),0)+ ',PromotionId-' + convert(varchar(5),@PromotionId)+',DeviceIdentifier-'+convert(varchar(5),@DeviceIdentifier);

							  SET @oldValue = CAST(@OldAfterValue AS nvarchar(10))
							  SET @newValue = CAST(0 AS nvarchar(10))

							 EXEC Insert_Audit '', @MemberId, NULL, '[PromotionStampCounter]', 'StampCount',@newValue,@oldValue,@reason
							
						END
						END

					FETCH NEXT FROM db_cursor INTO @PromotionId ,@UserId,@BeforeValue, @AfterValue,@PreviousCount
					END
			CLOSE db_cursor 
			DEALLOCATE  db_cursor 



			--Personalize Stampcard Qty Voucher
			DROP TABLE IF EXISTS #PromotionStampCounter
			SELECT PS.AfterValue,PS.PromotionId,p.QualifyingProductQuantity,PC.Name PromotionCategory,POT.Name PromotionOfferType ,P.VoucherProfileId,PS.DeviceIdentifier,PS.TrxId
			INTO #PromotionStampCounter
			FROM PromotionStampCounter PS With(NOLOCK) 
			INNER JOIN Promotion P With(NOLOCK) ON PS.PromotionId = P.Id
			INNER JOIN PromotionCategory PC With(NOLOCK) on p.PromotionCategoryId=PC.Id
			INNER JOIN PromotionOfferType POT With(NOLOCK) on p.PromotionOfferTypeId=POT.Id
			where PC.Name IN  ('StampCardQuantity') 
			AND POT.Name in('Voucher') 
			AND ISNULL(PS.AfterValue,0) >0 AND ISNULL(PS.AfterValue,0) >= ISNULL(p.QualifyingProductQuantity,0)
			AND UserId = @MemberId

			DECLARE @Result VARCHAR(500) = '', @ResultQty INT = 0,@VoucherProfile NVARCHAR(250),@ApplicableQuantity INT
			--@AfterValue DECIMAL(18,2), @PromotionId INT
			SET @AfterValue = 0;
			SET @PromotionId = 0;
			DECLARE @QualifyingProductQuantity DECIMAL(18,2),@PromotionCategory NVARCHAR(100),@PromotionOfferType NVARCHAR(100),@VoucherProfileId INT,@DeviceIdentifier2 INT,@TrxId INT
			DECLARE PromotionStampCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
			SELECT DISTINCT AfterValue,PromotionId,QualifyingProductQuantity,PromotionCategory,PromotionOfferType,VoucherProfileId,DeviceIdentifier,TrxId  FROM #PromotionStampCounter                             
			OPEN PromotionStampCursor                                                  
				FETCH NEXT FROM PromotionStampCursor           
				INTO @AfterValue , @PromotionId ,@QualifyingProductQuantity ,@PromotionCategory ,@PromotionOfferType,@VoucherProfileId, @DeviceIdentifier2 ,@TrxId                              
				WHILE @@FETCH_STATUS = 0 
				BEGIN 
					PRINT @AfterValue
					IF @AfterValue > 0 AND @QualifyingProductQuantity > 0
					BEGIN
						SET @ApplicableQuantity = FLOOR(@AfterValue/@QualifyingProductQuantity)
					END
					IF ISNULL(@ApplicableQuantity,0) > 0
					BEGIN
					set 	@Result = ''
					set 	@ResultQty = 0
					set @VoucherProfile =''
						EXEC EPOS_AssignNextAvilableStampCardVoucher @ClientId, @VoucherProfileId,@ApplicableQuantity,@MemberId,@Result OUTPUT,@ResultQty OUTPUT,@VoucherProfile OUTPUT,@DeviceIdentifier2,@TrxId,@PromotionId
						PRINT @Result 
						PRINT @ResultQty 
						PRINT @VoucherProfile
		
						IF ISNULL(@ResultQty,0) > 0
						BEGIN
							UPDATE PromotionStampCounter SET AfterValue = AfterValue - (@QualifyingProductQuantity * @ResultQty),BeforeValue = 0,OnTheFlyQuantity =0 WHERE UserId = @MemberId AND PromotionId = @PromotionId
						END
						--SET @AfterValue =0 ;

					END
					FETCH NEXT FROM PromotionStampCursor     
					INTO @AfterValue , @PromotionId ,@QualifyingProductQuantity ,@PromotionCategory ,@PromotionOfferType ,@VoucherProfileId , @DeviceIdentifier2 ,@TrxId       
				END     
			CLOSE PromotionStampCursor;    
			DEALLOCATE PromotionStampCursor; 
		--Personalize Stampcard Qty Voucher
			



		END

		SELECT 'success' as Result
	END
	ELSE
	BEGIN
		Update Device Set userId = @MemberId Where DeviceId = @DeviceId
		SELECT 'success' as Result
	END
  
END
