
-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2020-10-20
-- Description:	Include / Exclude
-- Modified Date: 2021-10-06
-- Update responce table in PersonalizeStampCard
-- =============================================
CREATE PROCEDURE [dbo].[Epos_StampCardCalculation_BAK_06NOV2024]
	-- Add the parameters for the stored procedure here
	(
	@TrxId INT,
	@PromotionId INT,
	@PromotionValue decimal(18,2),
	@DeviceId NVARCHAR(25),
	@BasketSum decimal(18,2) = 0,
	@PromotionStampCardCalculation NVARCHAR(MAX),
	@TerminalExtra3 NVARCHAR(25),
	@ClientId INT = 8,
	@MemberId INT = 0,
	@ServiceCall INT=0
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	/*
	DECLARE @InValidReceipt INT
	
	SELECT @InValidReceipt = TrxTypeId FROM TrxType WHERE ClientId = @ClientId AND Name = 'InValidReceipt'
	IF EXISTS (SELECT 1 FROM TrxHeader WHERE TrxId = @TrxId AND TrxTypeId =   @InValidReceipt)
	BEGIN
		SET @PromotionStampCardCalculation = ''
	END
	*/
	--IF ISNULL(@PromotionStampCardCalculation,'') = ''
	--BEGIN
	--	delete from [VirtualStampCard] where trxid=@TrxId AND @TrxId > 0
	--	PRINT 'CLEAR'
	--	IF ISNULL(@ServiceCall,0) = 0
	--	BEGIN
	--		SELECT 0 AS Result,0 AS RewardId,'' AS RewardName,0 AS VoucherValue,'' AS DefaultVoucher,0 ExistingQuantity,'' VoucherSubType,0 StampCardMultiplier,0 AS CalculatedBasketSum
	--	END
	--END

	IF ISNULL(@PromotionStampCardCalculation,'') <> '' AND ISNULL(@TrxId,0) > 0
	BEGIN
	--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	DECLARE @UserId INT,@ExistingQuantity decimal(18,2) = 0,@QualifyingProductQuantity decimal(18,2) = 0,@DeviceIdentifier INT,@StampCardMultiplier float,@PromotionName NVARCHAR(100),@StampCardOffers NVARCHAR(MAX)
	--DECLARE @VirtualQualifyingProductQuantity decimal(18,2) = 0
	DECLARE @PromotionCategoryId INT, @PromotionCategoryStampCard NVARCHAR(25),@PromotionOfferTypeId INT,@PromotionOfferType NVARCHAR(25)--,@ClientId INT
	DECLARE @BeforeValue decimal(18,2) = 0,@AfterValue decimal(18,2) = 0,@VoucherProfileId INT,@MisCode NVARCHAR(50), @RewardId INT = 0,@RewardName NVARCHAR(250),@ProductId NVARCHAR(10)
	DECLARE @Reward NVARCHAR(200)='',@VoucherValue decimal(18,2) = 0, @DefaultVoucher NVARCHAR(25),@OnTheFlyQuantity int = 0,@VoucherSubType NVARCHAR(25)
	DECLARE @CurrentVirtualBasketStampValue float = 0,@StampCount INT = 0,@PromotionStampCounterId INT = 0,@ParentPromotionId INT,@ChildPromotionId INT,@ChildPunch float

	DECLARE @LineNumber INT, @Quantity decimal(18,2),@NetValue decimal (18,2),@VoucherId NVARCHAR(25),@ItemCode NVARCHAR(50),@Type NVARCHAR(25) = 'Basket'

	SELECT @UserId = UserId,@DeviceIdentifier = Id  FROM DEVICE  WHERE DeviceId = @DeviceId
	if isnull(@userid,0)=0
	begin
		set @userid = 0
	end
	--select @ClientId = ClientId from TrxHeader where TrxId = @TrxId AND @TrxId > 0
	------------------------------------------------------------
	--IF ISNULL(@PromotionStampCardCalculation,'') <> ''
	--BEGIN
	--PRINT 'NEW Method'	
	DROP TABLE IF EXISTS #Result
	CREATE TABLE #Result (Result INT,  RewardId INT,  RewardName NVARCHAR(250),VoucherValue DECIMAL(18,2),DefaultVoucher NVARCHAR(25),ExistingQuantity decimal(18,2),VoucherSubType NVARCHAR(25),StampCardMultiplier float)

	DROP TABLE IF EXISTS #VirtualStampCard
	CREATE TABLE #VirtualStampCard (Id INT Identity (1,1),PromotionId int,VoucherId varchar(50),TrxId int,	LineNumber int,PromotionValue decimal(18,2),
	Quantity decimal(18,2),NetValue decimal(18,2),StampCardType nvarchar(25),PromotionOfferType nvarchar(25),PromotionType nvarchar(20),ChildPromotionId INT,ChildPunch float)

	--SELECT Promotion Settings --TODO JOIN
	SELECT @QualifyingProductQuantity = QualifyingProductQuantity,
	@PromotionCategoryId = PromotionCategoryId,
	@PromotionOfferTypeId =PromotionOfferTypeId , 
	@Reward = ISNULL(Reward,''),@VoucherProfileId = ISNULL(VoucherProfileId,0),
	@StampCardMultiplier = ISNULL(StampCardMultiplier,1),
	@ParentPromotionId = ISNULL(ParentPromotionId,0),
	@PromotionName = Name
	FROM Promotion WHERE Id = @PromotionId
	
	if isnull(@ParentPromotionId,0) > 0 AND EXISTS (SELECT 1 FROM Promotion WHERE Id = @ParentPromotionId AND Enabled = 1)
	BEGIN
		SET @ChildPromotionId = @PromotionId
		SET @PromotionId = @ParentPromotionId
		SET @ChildPunch = @StampCardMultiplier
		SELECT @StampCardMultiplier = ISNULL(@StampCardMultiplier,0) + ISNULL(StampCardMultiplier,1)
		FROM Promotion WHERE Id = @ParentPromotionId
	END
	ELSE
	BEGIN
		SET @ChildPromotionId = 0
		SET @ParentPromotionId = 0
		SET @ChildPunch = 0
	END
	
	IF ISNULL(@ServiceCall,0) = 1 -- CALL FROM MANUAL CLAIM
	BEGIN
		delete from [VirtualStampCard] where trxid=@TrxId AND PromotionId = @PromotionId
	END

	IF ISNULL (@UserId,0) > 0 --TODO
	BEGIN
		SELECT  @PromotionStampCounterId = Id,@AfterValue = ISNULL(AfterValue,0),@BeforeValue = ISNULL(BeforeValue,0), @OnTheFlyQuantity = ISNULL(OnTheFlyQuantity,0)
		FROM PromotionStampCounter WHERE UserId =  @UserId AND PromotionId = @PromotionId 
	END
	ELSE IF ISNULL (@DeviceIdentifier,0) > 0
	BEGIN 
		SELECT  @PromotionStampCounterId = Id,@AfterValue = ISNULL(AfterValue,0),@BeforeValue = ISNULL(BeforeValue,0), @OnTheFlyQuantity = ISNULL(OnTheFlyQuantity,0)
		FROM PromotionStampCounter WHERE DeviceIdentifier =  @DeviceIdentifier AND PromotionId = @PromotionId
	END

	--Counter have values update to zero
	IF ISNULL(@PromotionStampCounterId,0) > 0 AND (ISNULL(@BeforeValue,0) != 0 OR ISNULL(@OnTheFlyQuantity,0) != 0)
	BEGIN
		UPDATE PromotionStampCounter SET BeforeValue = 0,OnTheFlyQuantity = 0 WHERE Id = @PromotionStampCounterId
		SET @BeforeValue = 0
		SET @OnTheFlyQuantity = 0
	END
	ELSE IF ISNULL(@PromotionStampCounterId,0) = 0 -- NEW ENTRY
	BEGIN
		--PRINT 'NEW ENTRY'
		INSERT INTO [dbo].[PromotionStampCounter] ([Version],[UserId],[PromotionId],[TrxId],[CounterDate],[BeforeValue],[AfterValue],[OnTheFlyQuantity],DeviceIdentifier)
		VALUES(1,ISNULL(@UserId,0),@PromotionId,@TrxId,getdate(),0,0,0,@DeviceIdentifier)
		SET @PromotionStampCounterId = SCOPE_IDENTITY();
		
		SET @AfterValue = 0
		SET @BeforeValue = 0
		SET @OnTheFlyQuantity = 0
		SET @CurrentVirtualBasketStampValue = 0
	END
IF ISNULL (@UserId,0) = 0 -- Anonymize Transactions not considering existing Value
BEGIN
	--SET @ExistingQuantity = 1
	SET @AfterValue = 0
END
SET @CurrentVirtualBasketStampValue =  ISNULL (@AfterValue,0)

IF ISNULL(@PromotionStampCounterId,0) > 0 AND (ISNULL (@UserId,0)>0 OR ISNULL (@DeviceIdentifier,0)>0) AND ISNULL(@PromotionId,0) != 0
BEGIN


	--Category
	SELECT @PromotionCategoryStampCard = [Name] 
	FROM PromotionCategory  WHERE Id = @PromotionCategoryId AND ClientId = @ClientId
	--OfferType
	SELECT @PromotionOfferType = [Name] 
	FROM PromotionOfferType  WHERE Id = @PromotionOfferTypeId AND ClientId = @ClientId

	IF ISNULL(@Reward,'')<>'' AND ISNULL(ISJSON(@Reward),'')<>'' AND ISJSON(@Reward)=1 
	BEGIN
		--Reward Promo
		SET @RewardId = JSON_VALUE(@Reward,'$.Id')
		SET @RewardName = JSON_VALUE(@Reward,'$.Name')
		SET @ProductId =JSON_VALUE(@Reward,'$.RewardId')
	END
	ELSE IF ISNULL(@VoucherProfileId,0) > 0
	BEGIN
		--Voucher Promo --TODO JOIN 
		SELECT TOP 1 @RewardName = [Name] FROM DeviceProfileTemplate Where id = @VoucherProfileId
		--Get Voucher Details
		select TOP 1 @VoucherValue = VD.OfferValue ,@VoucherSubType = VT.Name,@MisCode = VD.MisCode from VoucherDeviceProfileTemplate VD  
		INNER JOIN VoucherSubType VT   ON VD.VoucherSubTypeId = VT.VoucherSubTypeId Where VD.id = @VoucherProfileId

		SET @RewardId = @VoucherProfileId
		--GET Default Voucher based on ClientConfig
		SELECT @DefaultVoucher = [Value] FROM ClientConfig  
		Where [Key] = 'StampcardDefaultVoucher' AND ClientId = @ClientId
		--APPEND Promotion Id To DefaultVoucher
		IF ISNULL(@DefaultVoucher,'') != ''
		BEGIN
			SET @DefaultVoucher = @DefaultVoucher + Convert(NVARCHAR(5),@PromotionId)
		END

		IF ISNULL(@VoucherId,'') = ''
		BEGIN
			SET @VoucherId = @VoucherProfileId
		END
	END

--SET  @BasketSum = @BasketSum * @StampCardMultiplier
	  
SET @PromotionStampCardCalculation  ='[{"L":"' + @PromotionStampCardCalculation +'"}]'
SET @PromotionStampCardCalculation = REPLACE(@PromotionStampCardCalculation, '&', '"},{"L":"')
SET @PromotionStampCardCalculation = REPLACE(@PromotionStampCardCalculation, 'V:', '","V":"')
SET @PromotionStampCardCalculation = REPLACE(@PromotionStampCardCalculation, 'Q:', '","Q":"')
SET @PromotionStampCardCalculation = REPLACE(@PromotionStampCardCalculation, 'I:', '","I":"')

--PRINT @BasketSum

DROP TABLE IF EXISTS #LineItem
DROP TABLE IF EXISTS #ReturnStampCardItemDetails
CREATE TABLE #ReturnStampCardItemDetails (ItemCode NVARCHAR(50),ValueUsed float,Quantity float,NetValue float,TrxId int,TrxDetailId int,ChildPromotionId int,ChildPunch float,StampReturn float)
--SELECT * INTO #LineItem FROM OPENJSON(@PromotionStampCardCalculation);
CREATE TABLE #LineItem (Id INT,LineNumber INT,NetValue float,Quantity float,ItemCode VARCHAR(50),Stamps float)

INSERT INTO #LineItem(Id ,LineNumber ,NetValue ,Quantity ,ItemCode )
SELECT [Key].[key] AS [Id], [Value].LineNumber ,[Value].NetValue ,[Value].Quantity ,[Value].ItemCode 
FROM OPENJSON (@PromotionStampCardCalculation, '$') AS [Key]
CROSS APPLY OPENJSON([Key].value)
    WITH (
        LineNumber INT '$.L', NetValue float '$.V', Quantity float '$.Q', ItemCode VARCHAR(50) '$.I'
    ) AS [Value]

--CREATE TABLE #LineItem (Id INT Identity (1,1),splitdata NVARCHAR(MAX))
--INSERT INTO #LineItem
--SELECT splitdata FROM [dbo].[fnSplitString] (@PromotionStampCardCalculation,'&')

--SELECT * FROM #LineItem
DECLARE @WhileLimt INT ,@splitdata NVARCHAR(MAX),@ChildPunchQty DECIMAL(18,2) ,@ItemCodes NVARCHAR(500),@ReturnStampQuantity float,@ReturnChildPromotionId INT,@ReturnChildPunch float

DECLARE @ValidDate INT 
SELECT @ValidDate = CASE WHEN ISDATE(@TerminalExtra3) = 1 
  AND @TerminalExtra3 LIKE '[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]' 
  THEN 1 ELSE 0 END;

IF ISNULL(@TerminalExtra3,'') <>'' AND @ValidDate != 0
BEGIN
	SELECT @ItemCodes = STUFF(( 
	SELECT DISTINCT ',' + ItemCode FROM #LineItem WHERE NetValue < 0 AND ItemCode != 'NA'
	FOR xml path('')
	),1,1,'')

	IF ISNULL(@ItemCodes,'')<> ''
	BEGIN
		--PRINT 'RETURN SP CALL'

		INSERT INTO #ReturnStampCardItemDetails (ItemCode ,ValueUsed ,Quantity ,NetValue ,TrxId ,TrxDetailId ,ChildPromotionId ,ChildPunch )
		EXEC EPOS_ReturnStampCardItemDetails @TrxId,@DeviceId,@TerminalExtra3,@ItemCodes ,@PromotionId
		
		IF ISNULL(@PromotionCategoryStampCard,'') ='StampCardValue'
		BEGIN
			UPDATE #ReturnStampCardItemDetails SET StampReturn = ValueUsed / NetValue 
		END
		ELSE
		BEGIN
			UPDATE #ReturnStampCardItemDetails SET StampReturn = CEILING(CAST(ValueUsed AS float) / CAST(Quantity AS float))
		END

		--SELECT * FROM #ReturnStampCardItemDetails
	END
END

--DELETE #ReturnStampCardItemDetails

IF ISNULL(@PromotionCategoryStampCard,'') ='StampCardValue'
BEGIN
	UPDATE #LineItem SET Stamps = NetValue * @StampCardMultiplier WHERE NetValue >=0
	--SET @DefaultVoucher = ''
END
ELSE
BEGIN
	UPDATE #LineItem SET Stamps = Quantity * @StampCardMultiplier WHERE NetValue >= 0

	UPDATE li SET Stamps = (Quantity * -1) * ISNULL((SELECT TOP 1 StampReturn FROM #ReturnStampCardItemDetails WHERE ItemCode = li.ItemCode Order BY TrxDetailId DESC),1) 
	FROM #LineItem li WHERE NetValue  < 0
END
--SELECT * FROM #ReturnStampCardItemDetails
--SELECT * FROM #LineItem
--PRINT @PromotionStampCardCalculation
--PRINT @PromotionCategoryStampCard
--PRINT @PromotionOfferType
--print @PromotionId
--print @ItemCodes
DECLARE @ReturnBasketSum decimal(18,2) = 0
SELECT @ReturnBasketSum = SUM(ISNULL(Stamps,0)) FROM #LineItem WHERE NetValue < 0 

SELECT @BasketSum = SUM(ISNULL(Stamps,0)) FROM #LineItem

SET @BasketSum = ISNULL(@BasketSum,0) + ISNULL(@AfterValue,0)
--PRINT @BasketSum

SELECT @WhileLimt = MIN([Id]) FROM #LineItem

While @WhileLimt is not null
BEGIN
		SELECT @LineNumber = LineNumber, @NetValue = NetValue, @Quantity = Quantity,@ItemCode=ItemCode FROM #LineItem Where [Id] = @WhileLimt
		--PRINT '-----------------------------'
		SET @ReturnChildPromotionId = 0;
		SET @ReturnChildPunch = 0;
		IF ISNULL(@NetValue,0) < 0
		BEGIN
			--PRINT 'RETURN'
			SELECT TOP 1 @ReturnStampQuantity = StampReturn,@ReturnChildPromotionId = ISNULL(ChildPromotionId,0),@ReturnChildPunch = ISNULL(ChildPunch,0) 
			FROM #ReturnStampCardItemDetails 
			WHERE ItemCode= @ItemCode ORDER BY TrxDetailId DESC

			IF @ReturnStampQuantity IS NOT NULL
			BEGIN
				--PRINT @ReturnStampQuantity
				SET @Quantity = ISNULL(@Quantity,0) * ISNULL(@ReturnStampQuantity,1)
				--SET @ChildPromotionId = @ReturnChildPromotionId
				--SET @ChildPunchQty = @ReturnChildPunch
			END
			SET @Quantity = ISNULL(@Quantity,0) * -1
		END
		
		IF ISNULL(@Quantity,0) > 0
		BEGIN

			IF @PromotionCategoryStampCard = 'StampCardQuantity'
			BEGIN
				SET @ChildPunchQty = @Quantity * @ChildPunch
				SET @Quantity = @Quantity * @StampCardMultiplier;
				SET @CurrentVirtualBasketStampValue += @Quantity
			END
			ELSE IF @PromotionCategoryStampCard = 'StampCardValue'
			BEGIN
				SET @ChildPunchQty = @NetValue * @ChildPunch
				SET @NetValue = @NetValue * @StampCardMultiplier;
				SET @CurrentVirtualBasketStampValue += @NetValue
			END

			--PRINT 'NOT A RETURN'

		END

		--PRINT @LineNumber
		--PRINT @NetValue
		--PRINT @Quantity
		--PRINT @ItemCode
		--PRINT @ChildPromotionId
		--PRINT @ChildPunchQty

		--IF @TrxId > 0
		--BEGIN

		IF ISNULL(@NetValue,0) < 0
		BEGIN
			INSERT INTO #VirtualStampCard([PromotionId],[VoucherId],[TrxId],[LineNumber],[PromotionValue],[Quantity],[NetValue],[StampCardType],[PromotionOfferType],[PromotionType],[ChildPromotionId],[ChildPunch])
			VALUES(@PromotionId,@VoucherId,@TrxId,@LineNumber,@PromotionValue,@Quantity,@NetValue,@PromotionCategoryStampCard,@PromotionOfferType,@Type,ISNULL(@ReturnChildPromotionId,0),ISNULL(@ReturnChildPunch,0))			
		END
		ELSE
		BEGIN
			INSERT INTO #VirtualStampCard([PromotionId],[VoucherId],[TrxId],[LineNumber],[PromotionValue],[Quantity],[NetValue],[StampCardType],[PromotionOfferType],[PromotionType],[ChildPromotionId],[ChildPunch])
			VALUES(@PromotionId,@VoucherId,@TrxId,@LineNumber,@PromotionValue,@Quantity,@NetValue,@PromotionCategoryStampCard,@PromotionOfferType,@Type,@ChildPromotionId,@ChildPunchQty)
		END
			
			--PRINT 'NEW'
			--PRINT @BasketSum
			--PRINT @CurrentVirtualBasketStampValue
				--IF @Type = 'Basket'
				--BEGIN
					IF(ISNULL(@CurrentVirtualBasketStampValue,0) + ISNULL(@BeforeValue,0) >= ISNULL(@QualifyingProductQuantity,0))
					AND (ISNULL(@BasketSum,0) + ISNULL(@BeforeValue,0) >= ISNULL(@QualifyingProductQuantity,0))
					BEGIN
						--PRINT 'BASKET - StampCard - VALID'
						SET @StampCount =0
						SET  @StampCount =  (ISNULL(@CurrentVirtualBasketStampValue,0)+ ISNULL(@BeforeValue,0) ) / @QualifyingProductQuantity
						
						IF ISNULL(@StampCount,0) > 0
						BEGIN
							SET @OnTheFlyQuantity = (ISNULL(@CurrentVirtualBasketStampValue,0)+ ISNULL(@BeforeValue,0) ) / ((ISNULL(@QualifyingProductQuantity,0) + ISNULL(@StampCardMultiplier,1) + ISNULL(@ChildPunch,0)));  
							--PRINT 'BASKET - OnTheFly - ' + CONVERT(NVARCHAR(10),@OnTheFlyQuantity)
						END
						--IF ISNULL(@OnTheFlyQuantity,0) > 0
						--BEGIN
						--	PRINT 'BASKET - StampCard - OnTheFly VALID'
						--END
						--IF ISNULL (@PromotionStampCounterId,0) > 0
						--BEGIN
							SET @BeforeValue = @BeforeValue - (@QualifyingProductQuantity * ISNULL(@StampCount,1))
							--SET @CurrentQuantity = @CurrentQuantity + @BeforeValue;
						--END
						--IF ISNULL(@StampCount,1) > 1 AND ISNULL(@PromotionOfferType,'Voucher') = 'Voucher'
						--BEGIN
						--	UPDATE #VirtualStampCard SET PromotionValue = @PromotionValue * @StampCount  WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber AND PromotionOfferType = 'Voucher'
						--END
						--IF ISNULL(@PromotionOfferType,'Reward') = 'Reward'
						--BEGIN
						--	UPDATE #VirtualStampCard SET PromotionValue = -1 WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber AND PromotionOfferType = 'Reward'
						--END
							 IF  ISNULL(@StampCount,0) > 1 --AND ISNULL(@PromotionOfferType,'Points') <> 'Points' 
							 BEGIN
								
								UPDATE #VirtualStampCard SET PromotionValue = 1  WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber 
								DECLARE @WhileStampCounter INT = 1 
								WHILE @WhileStampCounter < @StampCount
								BEGIN
									INSERT INTO #VirtualStampCard([PromotionId],[VoucherId],[TrxId],[LineNumber],[PromotionValue],[Quantity],[NetValue],[StampCardType],[PromotionOfferType],[PromotionType])--,[ChildPromotionId],[ChildPunch])
									VALUES(@PromotionId,@VoucherId,@TrxId,@LineNumber,1,0,0,@PromotionCategoryStampCard,@PromotionOfferType ,@Type)--,@ChildPromotionId,@ChildPunchQty)
									SET @WhileStampCounter = @WhileStampCounter +1;
								END
							 END
							 ELSE
							 BEGIN
								UPDATE #VirtualStampCard SET PromotionValue = @StampCount  WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber 
							 END

						INSERT INTO #Result
						SELECT ISNULL(@StampCount,1) AS Result,@RewardId AS RewardId,@RewardName AS RewardName,ISNULL(@VoucherValue,0) AS VoucherValue,@DefaultVoucher AS DefaultVoucher,ISNULL(@AfterValue,0) ExistingQuantity,ISNULL(@VoucherSubType,'') VoucherSubType,ISNULL(@StampCardMultiplier,1) StampCardMultiplier
						--PRINT 'END BASKET - StampCard - VALID'
					END
					ELSE
					BEGIN
						UPDATE #VirtualStampCard SET PromotionValue = 0 WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber --AND PromotionOfferType  = 'Voucher'
						---UPDATE #VirtualStampCard SET PromotionValue = -1 WHERE PromotionId = @PromotionId AND TrxId = @TrxId AND LineNumber = @LineNumber AND PromotionOfferType  = 'Reward'
						--PRINT '2'
						INSERT INTO #Result
						SELECT 0 AS Result,@RewardId AS RewardId,@RewardName AS RewardName,ISNULL(@VoucherValue,0) AS VoucherValue,@DefaultVoucher AS DefaultVoucher,ISNULL(@AfterValue,0) ExistingQuantity,ISNULL(@VoucherSubType,'') VoucherSubType,ISNULL(@StampCardMultiplier,1) StampCardMultiplier
					END
				--END
			--END
		--PRINT '-----------------------------LOOP--'
		SELECT @WhileLimt = MIN([Id]) FROM #LineItem WHERE [Id] >@WhileLimt
		--SELECT @WhileLimt = MIN(Id) FROM #LineItem WHERE Id >@WhileLimt
	END
		--DELETE FROM #Result
		--SELECT  *FROM  #Result
		--SELECT @PromotionCategoryStampCard
		IF EXISTS (SELECT 1 FROM #Result)
		BEGIN
			INSERT INTO VirtualStampCard (PromotionId,VoucherId,TrxId,LineNumber,PromotionValue,Quantity,	NetValue,StampCardType,PromotionOfferType,PromotionType,ChildPromotionId,ChildPunch) 
			SELECT PromotionId,VoucherId,TrxId,LineNumber,PromotionValue,Quantity,	NetValue,StampCardType,PromotionOfferType,PromotionType ,ChildPromotionId,ChildPunch
			FROM #VirtualStampCard
			--SET @StampCardOffers = (SELECT PromotionId,@PromotionName AS PromotionName,LineNumber, CASE WHEN StampCardType = 'StampCardValue' THEN NetValue ELSE Quantity END AS Stamps FROM #VirtualStampCard WHERE Quantity > 0 And NetValue >=0  FOR JSON AUTO)
			UPDATE [PromotionStampCounter] SET BeforeValue = @BeforeValue,TrxId = @TrxId,OnTheFlyQuantity = @OnTheFlyQuantity where Id = @PromotionStampCounterId
			IF ISNULL(@ServiceCall,0) = 0
			BEGIN
				--PRINT '1'
				IF ISNULL(@PromotionCategoryStampCard,'') = 'StampCardQuantity'
				BEGIN
					SELECT SUM(Result) Result,MAX(RewardId)RewardId,MAX(RewardName)RewardName,MAX(VoucherValue)VoucherValue,MAX(DefaultVoucher)DefaultVoucher,MAX(ExistingQuantity)ExistingQuantity,MAX(VoucherSubType)VoucherSubType,MAX(StampCardMultiplier)StampCardMultiplier,ISNULL(@ReturnBasketSum ,0) AS CalculatedBasketSum,@StampCardOffers StampCardOffers,@MisCode AS MisCode
					FROM #Result --WHERE @PromotionCategoryStampCard = 'StampCardQuantity'
				END
				ELSE
				BEGIN
					SELECT 0 AS Result,0 AS RewardId,'' AS RewardName,0 AS VoucherValue,'' AS DefaultVoucher,0 ExistingQuantity,'' VoucherSubType,0 StampCardMultiplier,0 AS CalculatedBasketSum,@StampCardOffers StampCardOffers,@MisCode AS MisCode
				END
			END
		END
		ELSE
		BEGIN
			IF ISNULL(@ServiceCall,0) = 0
			BEGIN
				----PRINT '0'
				--INSERT INTO #Result
				--SELECT 0 AS Result,@RewardId AS RewardId,@RewardName AS RewardName,ISNULL(@VoucherValue,0) AS VoucherValue,@DefaultVoucher AS DefaultVoucher,ISNULL(@AfterValue,0) ExistingQuantity,ISNULL(@VoucherSubType,'') VoucherSubType,ISNULL(@StampCardMultiplier,1) StampCardMultiplier

				--SELECT SUM(Result) Result,MAX(RewardId)RewardId,MAX(RewardName)RewardName,MAX(VoucherValue)VoucherValue,MAX(DefaultVoucher)DefaultVoucher,MAX(ExistingQuantity)ExistingQuantity,MAX(VoucherSubType)VoucherSubType,MAX(StampCardMultiplier)StampCardMultiplier,ISNULL(@ReturnBasketSum ,0) AS CalculatedBasketSum
				--FROM #Result WHERE @PromotionCategoryStampCard = 'StampCardQuantity'
				IF ISNULL(@PromotionCategoryStampCard,'') = 'StampCardQuantity'
				BEGIN
					SELECT 0 AS Result,@RewardId AS RewardId,@RewardName AS RewardName,ISNULL(@VoucherValue,0) AS VoucherValue,@DefaultVoucher AS DefaultVoucher,ISNULL(@AfterValue,0) ExistingQuantity,ISNULL(@VoucherSubType,'') VoucherSubType,ISNULL(@StampCardMultiplier,1) StampCardMultiplier,ISNULL(@ReturnBasketSum ,0) AS CalculatedBasketSum,@StampCardOffers StampCardOffers,@MisCode AS MisCode
				END
				ELSE
				BEGIN
					SELECT 0 AS Result,0 AS RewardId,'' AS RewardName,0 AS VoucherValue,'' AS DefaultVoucher,0 ExistingQuantity,'' VoucherSubType,0 StampCardMultiplier,0 AS CalculatedBasketSum,@StampCardOffers StampCardOffers,@MisCode AS MisCode
				END
			END
		END
	END
	END
	ELSE
	BEGIN
		SELECT 0 AS Result,0 AS RewardId,'' AS RewardName,0 AS VoucherValue,'' AS DefaultVoucher,0 ExistingQuantity,'' VoucherSubType,0 StampCardMultiplier,0 AS CalculatedBasketSum,@StampCardOffers StampCardOffers,@MisCode AS MisCode
	END
DROP TABLE IF EXISTS #LineItem
DROP TABLE IF EXISTS #ReturnStampCardItemDetails
END
