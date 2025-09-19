
-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2020-10-20
-- Description:	Include / Exclude
-- Modified Date: 2021-10-06
-- Update responce table in PersonalizeStampCard
-- =============================================
CREATE PROCEDURE [dbo].[Epos_StampCardCalculation_bkup26MAY2023]
	-- Add the parameters for the stored procedure here
	(
	@TrxId INT,
	@PromotionId INT,
	@VoucherId NVARCHAR(25),
	@PromotionValue decimal(18,2),
	@LineNumber INT,
	@Quantity decimal(18,2),
	@DeviceId NVARCHAR(25),
	@NetValue decimal (18,2),
	@Type NVARCHAR(25) = 'LineItem',
	@BasketSum decimal(18,2) = 0,
	@PromotionIds NVARCHAR(MAX) = null
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @UserId INT,@CurrentQuantity decimal(18,2) = 0,@QualifyingProductQuantity decimal(18,2) = 0,@VirtualQualifyingProductQuantity decimal(18,2) = 0,@DeviceIdentifier INT,@StampCardMultiplier float
	DECLARE @PromotionCategoryId INT, @PromotionCategoryStampCard NVARCHAR(25),@PromotionOfferTypeId INT,@PromotionOfferType NVARCHAR(25),@ClientId INT
	DECLARE @BeforeValue decimal(18,2) = 0,@AfterValue decimal(18,2) = 0,@VoucherProfileId INT

	SELECT @UserId = ISNULL(UserId,0),@DeviceIdentifier = ISNULL(Id,0) FROM DEVICE with(nolock) WHERE DeviceId = @DeviceId
	select @ClientId = 1 --ClientId from TrxHeader with(nolock) where TrxId = @TrxId AND @TrxId > 0

	DECLARE @RewardId INT = 0,@RewardName NVARCHAR(250),@ProductId NVARCHAR(10)
	DECLARE @Reward NVARCHAR(200)='',@VoucherValue decimal(18,2) = 0,@DefaultVoucher NVARCHAR(25),@OnTheFlyQuantity int = 0,@VoucherSubType NVARCHAR(25)
	
	--PRINT @UserId 
	--PRINT @DeviceId
	--PRINT @ClientId
	--Clear Existing CalculateLoyalty VirtualStampCard Entry
	IF(ISNULL(@Type,'') = 'Clear')
	BEGIN
		PRINT 'Clear'
		delete from [VirtualStampCard] 
		where trxid=@TrxId AND @TrxId > 0
		DECLARE @SQL NVARCHAR(MAX)
		IF ISNULL (@UserId,0) > 0
		BEGIN
			SET @SQL = 'UPDATE PromotionStampCounter SET BeforeValue = 0,OnTheFlyQuantity = 0 WHERE UserId = '+ CONVERT(VARCHAR(20), @UserId) +' AND PromotionId IN (' + @VoucherId + ')'
		END
		ELSE IF ISNULL (@DeviceIdentifier,0) > 0
		BEGIN 
			SET @SQL = 'UPDATE PromotionStampCounter SET BeforeValue = 0,OnTheFlyQuantity = 0 WHERE DeviceIdentifier = '+ CONVERT(VARCHAR(20), @DeviceIdentifier) +' AND PromotionId IN (' + @VoucherId + ')'
		END
		PRINT @SQL
		EXEC (@SQL)
	END
	------------------------------------------------------------
	DECLARE @ExistingQuantity INT = 0
	IF ISNULL (@UserId,0)>0
	BEGIN
		SET @ExistingQuantity = 1
	END
	IF ISNULL(@NetValue,0) < 0
	BEGIN
		SET @Quantity = ISNULL(@Quantity,0) * -1
	END
	IF (ISNULL (@UserId,0)>0 OR ISNULL (@DeviceIdentifier,0)>0) AND ISNULL(@PromotionId,0) != 0
	BEGIN
		PRINT 'USER'
		delete from [VirtualStampCard] 
		where trxid=@TrxId and Linenumber=@LineNumber AND @TrxId > 0

		--,@PromotionThreshold = QualifyingProductQuantity
		IF ISNULL(@PromotionId,0) = 236
		BEGIN
			SET @QualifyingProductQuantity = 4
			SET @PromotionCategoryId = 2
			SET @PromotionOfferTypeId = 6
			SET @Reward = ''
			SET @VoucherProfileId = 1050
			SET @StampCardMultiplier = 1
		END
		ELSE IF ISNULL(@PromotionId,0) = 238
		BEGIN
			SET @QualifyingProductQuantity = 6
			SET @PromotionCategoryId = 2
			SET @PromotionOfferTypeId = 6
			SET @Reward = ''
			SET @VoucherProfileId = 1051
			SET @StampCardMultiplier = 1
		END
		ELSE
		BEGIN
			SELECT @QualifyingProductQuantity = QualifyingProductQuantity,
			@PromotionCategoryId = PromotionCategoryId,
			@PromotionOfferTypeId =PromotionOfferTypeId , 
			@Reward = ISNULL(Reward,''),
			@VoucherProfileId = ISNULL(VoucherProfileId,0),
			@StampCardMultiplier = ISNULL(StampCardMultiplier,1)
			FROM Promotion with(nolock) WHERE Id = @PromotionId
		END
		SET @Quantity = @Quantity * @StampCardMultiplier;

		IF ISNULL(@Reward,'')<>'' AND ISNULL(ISJSON(@Reward),'')<>'' AND ISJSON(@Reward)=1
		BEGIN
			SET @RewardId = JSON_VALUE(@Reward,'$.Id')
			SET @RewardName = JSON_VALUE(@Reward,'$.Name')
			SET @ProductId =JSON_VALUE(@Reward,'$.RewardId')
		END
		ELSE IF ISNULL(@VoucherProfileId,0) > 0
		BEGIN
			--SET @RewardName = 
			
			IF ISNULL(@VoucherProfileId,0) = 1050
			BEGIN
				SET @RewardName = 'Free Tee(s)'
				SET @VoucherValue = 26.99
				SET @VoucherSubType = 'DiscountFixed'
			END
			ELSE IF ISNULL(@VoucherProfileId,0) = 1051
			BEGIN
				SET @RewardName = 'Free Piece(s) of Jewelry'
				SET @VoucherValue = 16.99
				SET @VoucherSubType = 'DiscountFixed'
			END
			ELSE
			BEGIN
				SELECT TOP 1 @RewardName = [Name] FROM DeviceProfileTemplate with(nolock) Where id = @VoucherProfileId
				select TOP 1 @VoucherValue = VD.OfferValue ,@VoucherSubType = VT.Name from VoucherDeviceProfileTemplate VD WITH(NOLOCK) INNER JOIN VoucherSubType VT  WITH(NOLOCK) ON VD.VoucherSubTypeId = VT.VoucherSubTypeId Where VD.id = @VoucherProfileId	
			END

			SET @RewardId = @VoucherProfileId
			
			SET @DefaultVoucher = 'IMMEDIATE'
			--SELECT @DefaultVoucher = [Value] FROM ClientConfig with(nolock) Where [Key] = 'StampcardDefaultVoucher' AND ClientId = @ClientId
			IF ISNULL(@DefaultVoucher,'') != ''
			BEGIN
				SET @DefaultVoucher = @DefaultVoucher + Convert(NVARCHAR(5),@PromotionId)
			END
			IF ISNULL(@VoucherId,'') = ''
			BEGIN
				SET @VoucherId = @VoucherProfileId
			END
		END
		IF @TrxId > 0
		BEGIN
		--PRINT '@QualifyingProductQuantity'
		--PRINT @QualifyingProductQuantity
			
		IF ISNULL(@PromotionCategoryId,0) = 2
		BEGIN
			SET @PromotionCategoryStampCard ='StampCardQuantity'
		END
		ELSE
		BEGIN
			SELECT @PromotionCategoryStampCard = [Name] FROM PromotionCategory with(nolock) WHERE Id = @PromotionCategoryId AND ClientId = @ClientId
		END

		IF ISNULL(@PromotionOfferTypeId,0) = 6
		BEGIN
			SET @PromotionOfferType ='Voucher'
		END
		ELSE 
		BEGIN
			SELECT @PromotionOfferType = [Name] FROM PromotionOfferType with(nolock) WHERE Id = @PromotionOfferTypeId AND ClientId = @ClientId
		END

		INSERT INTO [VirtualStampCard]
			   ([PromotionId]
			   ,[VoucherId]
			   ,[TrxId]
			   ,[LineNumber]
			   ,[PromotionValue]
			   ,[Quantity]
			   ,[NetValue]
			   ,[StampCardType]
			   ,[PromotionOfferType]
			   ,[PromotionType])
		 VALUES
			   (@PromotionId
			   ,@VoucherId
			   ,@TrxId
			   ,@LineNumber
			   ,@PromotionValue
			   ,@Quantity
			   ,@NetValue
			   ,@PromotionCategoryStampCard
			   ,@PromotionOfferType
			   ,@Type)

				IF ISNULL (@UserId,0) > 0 AND NOT EXISTS (SELECT 1 FROM PromotionStampCounter with(nolock) where UserId = @UserId AND  PromotionId = @PromotionId)
				BEGIN
					INSERT INTO [dbo].[PromotionStampCounter] ([Version],[UserId],[PromotionId],[TrxId],[CounterDate],[BeforeValue],[AfterValue],[OnTheFlyQuantity],DeviceIdentifier)
					VALUES(1,@UserId,@PromotionId,@TrxId,getdate(),0,0,@OnTheFlyQuantity,@DeviceIdentifier)
				END
				ELSE IF ISNULL (@UserId,0) = 0 AND ISNULL (@DeviceIdentifier,0) > 0 AND NOT EXISTS (SELECT 1 FROM PromotionStampCounter with(nolock) where ISNULL(UserId,0) = 0 AND ISNULL(DeviceIdentifier,0) = @DeviceIdentifier AND  PromotionId = @PromotionId)
				BEGIN
					INSERT INTO [dbo].[PromotionStampCounter] ([Version],[UserId],[PromotionId],[TrxId],[CounterDate],[BeforeValue],[AfterValue],[OnTheFlyQuantity],DeviceIdentifier)
					VALUES(1,ISNULL(@UserId,0),@PromotionId,@TrxId,getdate(),0,0,@OnTheFlyQuantity,@DeviceIdentifier)
				END

				--IF ISNULL(@Type,'LineItem') = 'LineItem'
				--BEGIN
				--		--PRINT @PromotionCategoryStampCard
				--		IF ISNULL(@PromotionCategoryStampCard,'') = 'StampCardQuantity'
				--		BEGIN
				--			SELECT @VirtualQualifyingProductQuantity = SUM(ISNULL(Quantity,0)) FROM [VirtualStampCard] WHERE PromotionId = @PromotionId AND TrxId = @TrxId
				--			--PRINT 'VirtualQualifyingProductQuantity'
				--			--PRINT @VirtualQualifyingProductQuantity
				--		END
				--		ELSE IF ISNULL(@PromotionCategoryStampCard,'') = 'StampCardValue'
				--		BEGIN
				--			SELECT @VirtualQualifyingProductQuantity = SUM(ISNULL(Quantity,0) * ISNULL(NetValue,0)) FROM [VirtualStampCard] WHERE PromotionId = @PromotionId AND TrxId = @TrxId
				--			--PRINT 'VirtualQualifyingProductQuantity'
				--			--PRINT @VirtualQualifyingProductQuantity
				--		END
				--		SELECT @CurrentQuantity = AfterValue + BeforeValue FROM [PromotionStampCounter] where UserId = @UserId AND  PromotionId = @PromotionId
				--		--PRINT '@CurrentQuantity'
				--		--PRINT @CurrentQuantity

				--		IF(ISNULL(@CurrentQuantity,0) + ISNULL(@VirtualQualifyingProductQuantity,0)  > ISNULL(@QualifyingProductQuantity,0))
				--		BEGIN
				--			UPDATE [PromotionStampCounter] SET BeforeValue = BeforeValue - @QualifyingProductQuantity,TrxId = @TrxId   where UserId = @UserId AND  PromotionId = @PromotionId
				--			UPDATE [VirtualStampCard] SET PromotionValue = -1 WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber AND PromotionOfferType = 'Reward'
				--			SELECT 1 AS Result,@RewardId AS RewardId,@RewardName AS RewardName
				--		END
				--		ELSE
				--		BEGIN
				--			UPDATE [VirtualStampCard] SET PromotionValue = 0 WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber
				--			SELECT 0 AS Result,@RewardId AS RewardId,@RewardName AS RewardName
				--		END

				--END
				--ELSE 
				IF @Type = 'Basket'
				BEGIN
					--PRINT @PromotionCategoryStampCard
					IF ISNULL(@PromotionCategoryStampCard,'') = 'StampCardQuantity'
					BEGIN
						PRINT 'BASKET - StampCardQuantity'
						SELECT @VirtualQualifyingProductQuantity = SUM(ISNULL(Quantity,0)) FROM [VirtualStampCard] with(nolock) WHERE PromotionId = @PromotionId AND TrxId = @TrxId
						--PRINT 'VirtualQualifyingProductQuantity'
						--PRINT @VirtualQualifyingProductQuantity
					END
					ELSE IF ISNULL(@PromotionCategoryStampCard,'') = 'StampCardValue'
					BEGIN
						PRINT 'BASKET - StampCardValue'
						SELECT @VirtualQualifyingProductQuantity = SUM(ISNULL(NetValue,0)) FROM [VirtualStampCard] with(nolock) WHERE PromotionId = @PromotionId AND TrxId = @TrxId
						--PRINT 'VirtualQualifyingProductQuantity'
						--PRINT @VirtualQualifyingProductQuantity
					END
					IF ISNULL (@UserId,0) > 0
					BEGIN
						SELECT @CurrentQuantity = AfterValue + BeforeValue, @AfterValue = AfterValue, @BeforeValue = ISNULL(BeforeValue,0)  FROM [PromotionStampCounter] with(nolock) where UserId = @UserId AND  PromotionId = @PromotionId
					END
					ELSE IF ISNULL (@DeviceIdentifier,0) > 0
					BEGIN 
						SELECT @CurrentQuantity = (AfterValue * @ExistingQuantity) + BeforeValue, @AfterValue = (AfterValue * @ExistingQuantity), @BeforeValue = ISNULL(BeforeValue,0)  FROM [PromotionStampCounter] with(nolock) where ISNULL(DeviceIdentifier,0) = @DeviceIdentifier AND  PromotionId = @PromotionId AND ISNULL(UserId,0) = 0
					END
					
					--PRINT '@CurrentQuantity'
					--PRINT @CurrentQuantity
					PRINT '-----------------A'
					PRINT @CurrentQuantity
					PRINT @VirtualQualifyingProductQuantity
					PRINT @BasketSum
					PRINT @BeforeValue
					PRINT @QualifyingProductQuantity
					PRINT @AfterValue
					PRINT @Quantity
					PRINT @LineNumber
					PRINT '-----------------'


					IF(ISNULL(@BasketSum,0) + ISNULL(@CurrentQuantity,0)   >= ISNULL(@QualifyingProductQuantity,0))
					BEGIN
						PRINT 'BASKET - StampCard - VALID'
						
						--IF(ISNULL(@VirtualQualifyingProductQuantity,0) + ISNULL(@CurrentQuantity,0)   >= ISNULL(@PromotionThreshold,0))

						DECLARE @StampCount INT
						SET  @StampCount = (ISNULL(@BasketSum,0) + ISNULL(@CurrentQuantity,0)) / @QualifyingProductQuantity
						
						IF ISNULL(@StampCount,0) > 0

						SET @OnTheFlyQuantity = (ISNULL(@BasketSum,0) + ISNULL(@CurrentQuantity,0)) / (ISNULL(@QualifyingProductQuantity,0) + 1); 

						IF ISNULL(@OnTheFlyQuantity,0) > 0
						BEGIN
							PRINT 'BASKET - StampCard - OnTheFly VALID'
						END

						PRINT @StampCount
						PRINT @OnTheFlyQuantity

						IF ISNULL (@UserId,0) > 0
						BEGIN
							UPDATE [PromotionStampCounter] SET BeforeValue = BeforeValue - @QualifyingProductQuantity * ISNULL(@StampCount,1),TrxId = @TrxId,OnTheFlyQuantity = @OnTheFlyQuantity   where UserId = @UserId AND  PromotionId = @PromotionId
						END
						ELSE IF ISNULL (@DeviceIdentifier,0) > 0
						BEGIN 
							UPDATE [PromotionStampCounter] SET BeforeValue = BeforeValue - @QualifyingProductQuantity * ISNULL(@StampCount,1),TrxId = @TrxId,OnTheFlyQuantity = @OnTheFlyQuantity   where ISNULL(DeviceIdentifier,0) = @DeviceIdentifier AND  PromotionId = @PromotionId AND ISNULL(UserId,0) = 0
						END
						
						IF ISNULL(@StampCount,1) > 1
						BEGIN
							UPDATE [VirtualStampCard] SET PromotionValue = @PromotionValue * @StampCount  WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber AND PromotionOfferType = 'Voucher'
						END

						--UPDATE [VirtualStampCard] SET PromotionValue = -1 WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber AND PromotionOfferType = 'Reward'

						SELECT ISNULL(@StampCount,1) AS Result,@RewardId AS RewardId,@RewardName AS RewardName,ISNULL(@VoucherValue,0) AS VoucherValue,@DefaultVoucher AS DefaultVoucher,ISNULL(@AfterValue,0) ExistingQuantity,ISNULL(@VoucherSubType,'') VoucherSubType,ISNULL(@StampCardMultiplier,1) StampCardMultiplier
						
						PRINT 'END BASKET - StampCard - VALID'
					END
					ELSE
					BEGIN
						UPDATE [VirtualStampCard] SET PromotionValue = 0 WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber AND PromotionOfferType  = 'Voucher'
						--UPDATE [VirtualStampCard] SET PromotionValue = -1 WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber AND PromotionOfferType  = 'Reward'
						SELECT 0 AS Result,@RewardId AS RewardId,@RewardName AS RewardName,ISNULL(@VoucherValue,0) AS VoucherValue,@DefaultVoucher AS DefaultVoucher,ISNULL(@AfterValue,0) ExistingQuantity,ISNULL(@VoucherSubType,'') VoucherSubType,ISNULL(@StampCardMultiplier,1) StampCardMultiplier
					END
				END
		END
		ELSE
		BEGIN
			SELECT 0 AS Result,@RewardId AS RewardId,@RewardName AS RewardName,ISNULL(@VoucherValue,0) AS VoucherValue,@DefaultVoucher AS DefaultVoucher,ISNULL(@AfterValue,0) ExistingQuantity,ISNULL(@VoucherSubType,'') VoucherSubType,ISNULL(@StampCardMultiplier,1) StampCardMultiplier
		END
	END
	ELSE
	BEGIN
	IF(ISNULL(@Type,'') != 'Clear')
	BEGIN
		SELECT @PromotionCategoryId = PromotionCategoryId,@PromotionOfferTypeId =PromotionOfferTypeId FROM Promotion with(nolock) WHERE Id = @PromotionId

		SELECT @PromotionCategoryStampCard = [Name] FROM PromotionCategory with(nolock) WHERE Id = @PromotionCategoryId AND ClientId = @ClientId
		SELECT @PromotionOfferType = [Name] FROM PromotionOfferType with(nolock) WHERE Id = @PromotionOfferTypeId AND ClientId = @ClientId

		INSERT INTO [VirtualStampCard]
				([PromotionId]
				,[VoucherId]
				,[TrxId]
				,[LineNumber]
				,[PromotionValue]
				,[Quantity]
				,[NetValue]
				,[StampCardType]
				,[PromotionOfferType]
				,[PromotionType])
			VALUES
				(@PromotionId
				,@VoucherId
				,@TrxId
				,@LineNumber
				,@PromotionValue
				,@Quantity
				,@NetValue
				,@PromotionCategoryStampCard
				,@PromotionOfferType
				,@Type)
		END

	SELECT 0 AS Result,isnull(@RewardId,0) AS RewardId,@RewardName AS RewardName,ISNULL(@VoucherValue,0) AS VoucherValue,@DefaultVoucher AS DefaultVoucher,ISNULL(@AfterValue,0) ExistingQuantity,ISNULL(@VoucherSubType,'') VoucherSubType,ISNULL(@StampCardMultiplier,1) StampCardMultiplier
	END
END
