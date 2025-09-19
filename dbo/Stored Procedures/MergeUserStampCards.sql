CREATE PROCEDURE [dbo].[MergeUserStampCards](@SourceUserId int,@DestinationUserId int ,@ClientId	int,@Description nvarchar(1000),@CreatedBy int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- @DestinationUserId = Surviving user after merge (Active user after merge)
	--@SourceUserId = Users whos status will be Merged after merge process

	 DEclare @UserId int,@PromotionId int ,@BeforeValue int,@PreviousCount decimal(18,2),@AfterValue decimal(18,2),@SourceUserSiteId int ,@DestinationUserSiteId int
	 Declare @OldBeforeValue int,@OldPreviousCount decimal(18,2),@OldAfterValue decimal(18,2);
	 Declare @updatedBeforeValue int,@updatedPreviousCount decimal(18,2),@updatedAfterValue decimal(18,2),@reason nvarchar(max);
	 Declare @oldValue nvarchar(50)=''
	 Declare @newValue nvarchar(50)=''
      -- GET ALL Promotions from the source user and iterate thorugh those and update counter on destination user
   SELECT distinct PromotionId,UserId,BeforeValue,AfterValue,PreviousStampCount into #tempMergeStamps from [dbo].[PromotionStampCounter] where userid=@SourceUserId
   DECLARE db_cursor CURSOR FOR  
				SELECT distinct PromotionId,UserId,BeforeValue,AfterValue,PreviousStampCount from  #tempMergeStamps
				-----------------------------------------------------
				OPEN db_cursor  
				FETCH NEXT FROM db_cursor INTO @PromotionId ,@UserId,@BeforeValue, @AfterValue,@PreviousCount
				
				WHILE @@FETCH_STATUS = 0  
				BEGIN  
				print convert(varchar(5),@AfterValue)
				IF ISNULL(@PromotionId,0) > 0 and  ISNULL(@UserId,0) > 0
				BEGIN
				IF EXISTS (SELECT 1 from [PromotionStampCounter] where   UserId=@DestinationUserId and PromotionId = @PromotionId)
				BEGIN
				SELECT @OldBeforeValue = BeforeValue,@OldPreviousCount =PreviousStampCount,@OldAfterValue= AfterValue from [PromotionStampCounter] where   UserId=@DestinationUserId and PromotionId = @PromotionId

				UPDATE [PromotionStampCounter] set @updatedAfterValue =  AfterValue+@AfterValue, AfterValue = AfterValue+@AfterValue,@updatedBeforeValue = BeforeValue+@BeforeValue, BeforeValue = BeforeValue+@BeforeValue ,
						@updatedPreviousCount = PreviousStampCount + @PreviousCount,PreviousStampCount=PreviousStampCount + @PreviousCount where UserId=@DestinationUserId and PromotionId = @PromotionId
				--Audit destination stamp counter chnages
				SET @reason = 'AfterValueOld-' + convert(varchar(5),@OldAfterValue) + ',AfterValueNew-'+ convert(varchar(5),@updatedAfterValue) + ',BeforeValueOld -'+convert(varchar(5),@OldBeforeValue)+',BeforeValueNew- '+convert(varchar(5),@updatedBeforeValue)+'
				,PreviousStampCountOld-'+convert(varchar(5),@OldPreviousCount)+',PreviousStampCountNew-'+ convert(varchar(5),@updatedPreviousCount);

				 SET @oldValue = CAST(@OldAfterValue AS nvarchar(10))
				 SET @newValue = CAST(@updatedAfterValue AS nvarchar(10))

				 EXEC Insert_Audit '', @DestinationUserId, NULL, '[PromotionStampCounter]', 'StampCount',@newValue,@oldValue ,@reason
				 
				 SELECT @OldBeforeValue = BeforeValue,@OldPreviousCount =PreviousStampCount,@OldAfterValue= AfterValue from [PromotionStampCounter] where   UserId=@UserId and PromotionId = @PromotionId				
				UPDATE [PromotionStampCounter] set  AfterValue = 0, BeforeValue = 0 ,PreviousStampCount=0 
								where UserId=@UserId and PromotionId = @PromotionId
				--Audit source user stamp counter chnages
				SET @reason = 'AfterValueOld-' + convert(varchar(5),@OldAfterValue) + ',AfterValueNew-'+ convert(varchar(5),0) + ',BeforeValueOld -'+convert(varchar(5),@OldBeforeValue)+',BeforeValueNew- '+convert(varchar(5),0)+'
				,PreviousStampCountOld-'+convert(varchar(5),@OldPreviousCount)+',PreviousStampCountNew-'+ convert(varchar(5),0);

				  SET @oldValue = CAST(@OldAfterValue AS nvarchar(10))
				  SET @newValue = CAST(0 AS nvarchar(10))

				 EXEC Insert_Audit '', @UserId, NULL, '[PromotionStampCounter]', 'StampCount',@newValue,@oldValue,@reason

				END
				ELSE
				BEGIN
				print 'do not exist'
				--IF Promotion exist on source userid and doesn't exist on destination user ,add a new entry for destination and update source values to 0
				INSERT INTO [PromotionStampCounter] SELECT [Version],@DestinationUserId,[PromotionId],[TrxId],GETDATE(),[BeforeValue]
					 ,[AfterValue],[PreviousStampCount],[OnTheFlyQuantity],[DeviceIdentifier]
							FROM [dbo].[PromotionStampCounter] WHERE USERID=@UserId and PromotionId= @PromotionId
				 SELECT @OldBeforeValue = BeforeValue,@OldPreviousCount =PreviousStampCount,@OldAfterValue= AfterValue from [PromotionStampCounter] where   UserId=@UserId and PromotionId = @PromotionId				
				UPDATE [PromotionStampCounter] set  AfterValue = 0, BeforeValue = 0 ,PreviousStampCount=0 
								where UserId=@UserId and PromotionId = @PromotionId
				--Audit source user stamp counter chnages
				SET @reason = 'AfterValueOld-' + convert(varchar(5),@OldAfterValue) + ',AfterValueNew-'+ convert(varchar(5),0) + ',BeforeValueOld -'+convert(varchar(5),@OldBeforeValue)+',BeforeValueNew- '+convert(varchar(5),0)+'
				,PreviousStampCountOld-'+convert(varchar(5),@OldPreviousCount)+',PreviousStampCountNew-'+ convert(varchar(5),0);

				  SET @oldValue = CAST(@OldAfterValue AS nvarchar(10))
				  SET @newValue = CAST(0 AS nvarchar(10))

				 EXEC Insert_Audit '', @UserId, NULL, '[PromotionStampCounter]', 'StampCount',@newValue,@oldValue,@reason
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
	AND UserId = @DestinationUserId

	DECLARE @Result VARCHAR(500) = '', @ResultQty INT = 0,@VoucherProfile NVARCHAR(250),@ApplicableQuantity INT
	--@AfterValue DECIMAL(18,2), @PromotionId INT
	SET @AfterValue = 0;
	SET @PromotionId = 0;
	DECLARE @QualifyingProductQuantity DECIMAL(18,2),@PromotionCategory NVARCHAR(100),@PromotionOfferType NVARCHAR(100),@VoucherProfileId INT,@DeviceIdentifier INT,@TrxId INT
	DECLARE PromotionStampCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
	SELECT DISTINCT AfterValue,PromotionId,QualifyingProductQuantity,PromotionCategory,PromotionOfferType,VoucherProfileId,DeviceIdentifier,TrxId  FROM #PromotionStampCounter                             
	OPEN PromotionStampCursor                                                  
		FETCH NEXT FROM PromotionStampCursor           
		INTO @AfterValue , @PromotionId ,@QualifyingProductQuantity ,@PromotionCategory ,@PromotionOfferType,@VoucherProfileId, @DeviceIdentifier ,@TrxId                              
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
				EXEC EPOS_AssignNextAvilableStampCardVoucher @ClientId, @VoucherProfileId,@ApplicableQuantity,@DestinationUserId,@Result OUTPUT,@ResultQty OUTPUT,@VoucherProfile OUTPUT,@DeviceIdentifier,@TrxId,@PromotionId
				PRINT @Result 
				PRINT @ResultQty 
				PRINT @VoucherProfile
		
				IF ISNULL(@ResultQty,0) > 0
				BEGIN
					UPDATE PromotionStampCounter SET AfterValue = AfterValue - (@QualifyingProductQuantity * @ResultQty),BeforeValue = 0,OnTheFlyQuantity =0 WHERE UserId = @DestinationUserId AND PromotionId = @PromotionId
				END
				--SET @AfterValue =0 ;

			END
			FETCH NEXT FROM PromotionStampCursor     
			INTO @AfterValue , @PromotionId ,@QualifyingProductQuantity ,@PromotionCategory ,@PromotionOfferType ,@VoucherProfileId , @DeviceIdentifier ,@TrxId       
		END     
	CLOSE PromotionStampCursor;    
	DEALLOCATE PromotionStampCursor; 
--Personalize Stampcard Qty Voucher


END
