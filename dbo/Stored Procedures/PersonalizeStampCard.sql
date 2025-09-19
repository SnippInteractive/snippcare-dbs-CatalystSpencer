
-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2022-02-11
-- Description:	AT-1024 -- Stampcard Reward <<TODO POINT>>
-- Modified Date: 2021-10-06
-- Calling From CATALYST [ApplyPoints]
-- REMOVED Calling From API API_Device_AssignDeviceToUser
-- =============================================
CREATE PROCEDURE [dbo].[PersonalizeStampCard]
	-- Add the parameters for the stored procedure here
	(@UserId INT,@ClientId INT,@Trxid INT)
AS
BEGIN

DECLARE @DeviceId NVARCHAR(25)
DECLARE @BasketSum decimal(18,2) = 0
--DECLARE @VirtualStampCardDetails TABLE	(TrxId INT, PromotionId INT,VoucherId VARCHAR(50),PromotionValue DECIMAL(18,2),LineNumber INT,Quantity DECIMAL(18,2),NetValue DECIMAL(18,2),PromotionType NVARCHAR(20))
DECLARE @PromotionId INT,@VoucherId Varchar(50),@PromotionValue decimal(18,2),@LineNumber INT,@Quantity decimal(18,2),@NetValue decimal (18,2),@Type NVARCHAR(25)

---USED FOR REMOVE SP RETUNS -- Cassing and issue in Apply Points SP
--DROP TABLE IF EXISTS #Epos_StampCardCalculation
--CREATE TABLE #Epos_StampCardCalculation (Result INT,RewardId INT,RewardName NVARCHAR(250),VoucherValue decimal(18,2),DefaultVoucher NVARCHAR(25),ExistingQuantity decimal(18,2),VoucherSubType NVARCHAR(25),StampCardMultiplier float,CalculatedBasketSum float)

--DROP TABLE IF EXISTS #Epos_ApplyStampCardOffer
--CREATE TABLE #Epos_ApplyStampCardOffer (Result INT)

DROP TABLE IF EXISTS #EPOS_AddRewardOffer
CREATE TABLE #EPOS_AddRewardOffer (LineNumber varchar(50),	PromotionId varchar(50),PromotionName varchar(250),RewardId varchar(50),RewardName varchar(250),Quantity varchar(50), VoucherIds varchar(250),VoucherName varchar(250))
---USED FOR REMOVE SP RETUNS -- Cassing and issue in Apply Points SP
DROP TABLE IF EXISTS #VirtualStampCardDetails
CREATE TABLE #VirtualStampCardDetails (TrxId INT, PromotionId INT,VoucherId VARCHAR(50),PromotionValue DECIMAL(18,2),LineNumber INT,Quantity DECIMAL(18,2),NetValue DECIMAL(18,2),PromotionType NVARCHAR(20))

IF ISNULL(@TrxId,0) > 0 -- manual Claim Stamp
BEGIN
	SELECT @DeviceId = DeviceId FROM TrxHeader Where TrxId  =@TrxId

	IF ISNULL(@DeviceId,'')!= '' AND ISNULL(@UserId,0) = 0
	BEGIN
		SELECT @UserId = UserId From Device Where DeviceId = @DeviceId
	END

	INSERT INTO  #VirtualStampCardDetails 
	SELECT TrxId, PromotionId,VoucherId,PromotionValue,ISNULL(LineNumber,0) AS LineNumber,Quantity,NetValue,PromotionType 
	FROM VirtualStampCard WHERE TrxId = @Trxid

	DECLARE @RootPromotionId INT = 0,@promotionStampCardCalculation NVARCHAR(MAX) = '',@PromoLinenumber INT
	SELECT TOP 1 @RootPromotionId = MIN(PromotionId) FROM #VirtualStampCardDetails WHERE  PromotionId IS NOT NULL

	WHILE @RootPromotionId IS NOT NULL
	BEGIN

		SELECT @BasketSum = SUM(Quantity) 
		FROM #VirtualStampCardDetails 
		WHERE TrxId = @Trxid AND PromotionId = @RootPromotionId
		SET @promotionStampCardCalculation = ''
		--PRINT @RootPromotionId
		SELECT @PromoLinenumber = MIN(LineNumber) FROM #VirtualStampCardDetails WHERE TrxId = @Trxid AND PromotionId = @RootPromotionId AND LineNumber > 0
		WHILE @PromoLinenumber IS NOT NULL
		BEGIN

		SELECT TOP 1 @PromotionId = PromotionId,@VoucherId = VoucherId,@PromotionValue = PromotionValue,
		@LineNumber = LineNumber,@Quantity = Quantity,@NetValue = NetValue,@Type = PromotionType
		FROM #VirtualStampCardDetails 
		WHERE TrxId = @Trxid AND PromotionId = @RootPromotionId AND LineNumber = @PromoLinenumber



				IF ISNULL(@promotionStampCardCalculation,'') != ''
				BEGIN
					SET @promotionStampCardCalculation = @promotionStampCardCalculation + '&'
				END
				--lineitemStampCard.LineNumber.ToString() + "V" + lineitemStampCard.NetValue.ToString() + "Q" + lineitemStampCard.Quantity.ToString();
				SET @promotionStampCardCalculation = @promotionStampCardCalculation + CONVERT(NVARCHAR(25), @LineNumber) + 'V:' + CONVERT(NVARCHAR(25), @NetValue)+ 'Q:' +CONVERT(NVARCHAR(25),@Quantity)+'I:NA'


			SELECT @PromoLinenumber = MIN(LineNumber) FROM #VirtualStampCardDetails 
			WHERE TrxId = @Trxid AND PromotionId = @RootPromotionId AND LineNumber > @PromoLinenumber
		END

	PRINT @promotionStampCardCalculation

	--INSERT INTO #Epos_StampCardCalculation
	IF ISNULL(@promotionStampCardCalculation,'') != ''
	BEGIN
		EXEC [dbo].[Epos_StampCardCalculation] 	@TrxId,	@RootPromotionId,@PromotionValue,@DeviceId,@BasketSum,@promotionStampCardCalculation,'',@ClientId,0,1
	END
	--EXEC [dbo].Epos_StampCardCalculation_P_WIP  @TrxId,	@RootPromotionId,@VoucherId,@PromotionValue,@LineNumber,@Quantity,@DeviceId,@NetValue,@Type,@BasketSum,	null,@promotionStampCardCalculation
	SET @promotionStampCardCalculation = ''


SELECT TOP 1 @RootPromotionId = MIN(PromotionId) FROM #VirtualStampCardDetails WHERE PromotionId >@RootPromotionId
END

	--INSERT INTO #Epos_ApplyStampCardOffer
	EXEC [dbo].[Epos_ApplyStampCardOffer] @Trxid,@DeviceId,1

	--INSERT INTO #EPOS_AddRewardOffer
	--EXEC [dbo].[EPOS_AddRewardOffer] @Trxid,@ClientId
	--SELECT @DeviceId = DeviceId FROM TrxHeader With(NOLOCK) Where TrxId  =@TrxId
	--IF ISNULL(@DeviceId,'')!= '' AND ISNULL(@UserId,0) = 0
	--BEGIN
	--	SELECT @UserId = UserId From Device With(NOLOCK) Where DeviceId = @DeviceId
	--END
	--SELECT @BasketSum = SUM(Quantity) FROM VirtualStampCard With(NOLOCK) WHERE TrxId = @Trxid

	--INSERT INTO  @VirtualStampCardDetails SELECT TrxId, PromotionId,VoucherId,PromotionValue,LineNumber,Quantity,NetValue,PromotionType 
	--		FROM VirtualStampCard With(NOLOCK) WHERE TrxId = @Trxid

	--delete from [VirtualStampCard] 
	--where trxid=@TrxId AND @TrxId > 0

	--UPDATE PromotionStampCounter SET BeforeValue = 0 WHERE UserId = @UserId AND PromotionId IN (SELECT PromotionId FROM @VirtualStampCardDetails)

	--DECLARE MCStampCardCalculationCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
	--SELECT PromotionId,VoucherId,PromotionValue,LineNumber,Quantity,NetValue,PromotionType
	--		FROM @VirtualStampCardDetails WHERE TrxId = @Trxid Order By TrxId,LineNumber                    
	--OPEN MCStampCardCalculationCursor                                                  
	--	FETCH NEXT FROM MCStampCardCalculationCursor           
	--	INTO @PromotionId ,@VoucherId ,@PromotionValue ,@LineNumber ,@Quantity ,@NetValue ,@Type                             
	--	WHILE @@FETCH_STATUS = 0 
	--		BEGIN 
	--		PRINT '----------'
	--		PRINT @Trxid
	--		PRINT @BasketSum
	--		PRINT @DeviceId
	--		PRINT @LineNumber
	--		PRINT '----------'
	--		INSERT INTO @Epos_StampCardCalculation
	--		EXEC [dbo].[Epos_StampCardCalculation] 	@TrxId,	@PromotionId,@VoucherId,@PromotionValue,@LineNumber,@Quantity,@DeviceId,@NetValue,@Type,@BasketSum,	null

	--	FETCH NEXT FROM MCStampCardCalculationCursor     
	--	INTO @PromotionId ,@VoucherId ,@PromotionValue ,@LineNumber ,@Quantity ,@NetValue ,@Type         
	--	END     
	--CLOSE MCStampCardCalculationCursor;    
	--DEALLOCATE MCStampCardCalculationCursor; 

	--INSERT INTO @Epos_ApplyStampCardOffer
	--EXEC [dbo].[Epos_ApplyStampCardOffer] @Trxid,@DeviceId

	----EXEC [dbo].[EPOS_PointPromotions] @Trxid,@ClientId,'RoundPointsOnLineItem',1.0
	----PRINT @Trxid 
	----PRINT @ClientId
	--INSERT INTO @EPOS_AddRewardOffer
	--EXEC [dbo].[EPOS_AddRewardOffer] @Trxid,@ClientId

END
ELSE IF ISNULL(@UserId,0) > 0 AND NOT EXISTS (SELECT 1 FROM [Audit] With(NOLOCK) WHERE UserId = @UserId AND FieldName = 'PersonalizeStampCard' AND ReferenceType = 'PersonalizeStampCard') -- Personalize ALL Transaction
BEGIN
	 
	 EXEC Insert_Audit 'PersonalizeStampCard',@UserId,null,'PersonalizeStampCard','PersonalizeStampCard','','', 'Personalize StampCard'

	--Voucher
	DROP TABLE IF EXISTS #UserLoyaltyDeviceList
	--select DISTINCT DeviceDeviceId,'STAMP-' + CONVERT(NVARCHAR(15), DeviceId) StampDeviceId,DeviceId AS DeviceIdentifier  
	--INTO #UserLoyaltyDeviceList
	--from   [VW_LoyaltyDevice] with(nolock)
	--where  DeviceUserId = @UserId AND DeviceProfileTemplateTypeName IN ('Loyalty')

	SELECT DISTINCT D.DeviceId,D.Id AS DeviceIdentifier--,'STAMP-' + CONVERT(NVARCHAR(15), D.Id) StampDeviceId
	INTO #UserLoyaltyDeviceList
	FROM Device D 
	INNER JOIN DeviceLotDeviceProfile DP ON D.DeviceLotId = DP.DeviceLotId 
	WHERE DP.DeviceProfileId = 1 AND UserId = @UserId

	DECLARE @DeviceListID NVARCHAR(25)
	SELECT TOP 1 @DeviceListID = DeviceId FROM #UserLoyaltyDeviceList

	UPDATE PC
	SET PC.UserId = @UserId
	FROM PromotionStampCounter PC
	INNER JOIN #UserLoyaltyDeviceList UL ON PC.DeviceIdentifier = UL.DeviceIdentifier
	WHERE ISNULL(PC.UserId,0) = 0

	SET @DeviceListID = ISNULL(@DeviceListID,'')
	EXEC Insert_Audit 'PersonalizeSCCounter',@UserId,null,'PersonalizeSCCounter','PersonalizeSCCounter',@DeviceListID,'', 'PersonalizeSCCounter'

	select DISTINCT d.AccountId,D.Id,D.Deviceid 
	INTO #Voucher
	from Device d --with(nolock) 
	INNER JOIN #UserLoyaltyDeviceList ul on d.OLD_AccountID = ul.DeviceIdentifier
	--with(nolock) on d.ExtraInfo collate database_default = ul.StampDeviceId collate database_default 
	WHERE ISNULL(d.UserId,0) = 0 AND d.ExtraInfo IS NOT NULL AND d.OLD_AccountID IS NOT NULL

	IF EXISTS (SELECT 1 FROM #Voucher) 
	BEGIN
		--Updating Device
		UPDATE Device
		SET UserId = @UserId
		FROM #Voucher v
		INNER JOIN Device D
		ON v.Id = D.Id
		WHERE ISNULL(d.UserId,0) = 0

		--Updating Account
		UPDATE Account
		SET UserId = @UserId
		FROM #Voucher v
		INNER JOIN Account A
		ON v.AccountId = A.AccountId
		WHERE ISNULL(A.UserId,0) = 0
	END

	EXEC Insert_Audit 'PersonalizeStampCard',@UserId,null,'PersonalizeStampCard','PersonalizeStampCard','','', 'Personalize StampCard Success'
	--SELECT tv.TrxVoucherId ,V.Id
	--INTO #UsedVoucher 
	--FROM TrxVoucherDetail tv with(nolock) INNER JOIN #Voucher V with(nolock) ON tv.TrxVoucherId = V.Deviceid

	--IF EXISTS (SELECT 1 FROM #UsedVoucher) 
	--BEGIN
	--	DECLARE @DeviceStatusIdInactive INT 
	--	select @DeviceStatusIdInactive = DeviceStatusId from DeviceStatus With(nolock) where Name='Inactive' and ClientId=@ClientId
	--	--Updating Device
	--	UPDATE Device
	--	SET DeviceStatusId = @DeviceStatusIdInactive
	--	FROM #UsedVoucher uv
	--	INNER JOIN Device D
	--	ON uv.Id = D.Id
	--	WHERE D.UserId = @UserId AND DeviceStatusId != @DeviceStatusIdInactive
	--END

	--SELECT DISTINCT Vs.PromotionId,dl.DeviceIdentifier INTO #OTFPromotionIdIds 
	--FROM TrxHeader th with(nolock) Inner Join [VirtualStampCard] vs with(nolock) on th.TrxId = vs.TrxId 
	--INNER JOIN #UserLoyaltyDeviceList dl on th.DeviceId = dl.DeviceDeviceId

	----Updating PromotionStampCounter
	--UPDATE PromotionStampCounter
	--SET UserId = @UserId
	--FROM #OTFPromotionIdIds PD
	--INNER JOIN PromotionStampCounter PC
	--ON PC.PromotionId = PD.PromotionId AND PC.DeviceIdentifier = PD.DeviceIdentifier
	--WHERE ISNULL(PC.UserId,0) = 0

	--SELECT DISTINCT th.TrxId,th.DeviceId,vs.PromotionOfferType INTO #TrxIds 
	--FROM TrxHeader th with(nolock) Inner Join [VirtualStampCard] vs with(nolock) on th.TrxId = vs.TrxId 
	--WHERE th.DeviceId IN (SELECT DeviceDeviceId FROM #UserLoyaltyDeviceList)

	--delete from [VirtualStampCard] where PromotionOfferType IN('Voucher') AND TrxId In (Select Distinct TrxId FROM #TrxIds)

	----Voucher Ends
	---- Reward Promotion
	--DECLARE @TrxidCur INT--,@DeviceId NVARCHAR(25)
	--DECLARE TrxCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
	--SELECT  TrxId,DeviceId FROM #TrxIds WHERE PromotionOfferType = 'Reward' ORDER BY TrxId                           
	--OPEN TrxCursor                                                  
	--	FETCH NEXT FROM TrxCursor           
	--	INTO @TrxidCur,@DeviceId                             
	--	WHILE @@FETCH_STATUS = 0 
	--	BEGIN 
	--		PRINT '----------'
	--		--PRINT @TrxidCur
	--				--DECLARE @BasketSum decimal(18,2) = 0

	--				SELECT @BasketSum = SUM(NetValue) FROM VirtualStampCard With(NOLOCK) WHERE TrxId = @TrxidCur

	--				--DECLARE @VirtualStampCardDetails TABLE	(TrxId INT, PromotionId INT,VoucherId VARCHAR(50),PromotionValue DECIMAL(18,2),LineNumber INT,Quantity DECIMAL(18,2),NetValue DECIMAL(18,2),PromotionType NVARCHAR(20))

	--				INSERT INTO  @VirtualStampCardDetails SELECT TrxId, PromotionId,VoucherId,PromotionValue,LineNumber,Quantity,NetValue,PromotionType 
	--						FROM VirtualStampCard With(NOLOCK) WHERE TrxId = @TrxidCur AND PromotionOfferType = 'Reward'
					
	--				delete from [VirtualStampCard] where trxid=@TrxidCur AND @TrxidCur > 0

	--				UPDATE PromotionStampCounter SET BeforeValue = 0 WHERE UserId = @UserId AND PromotionId IN (SELECT PromotionId FROM @VirtualStampCardDetails)

	--				--DECLARE @PromotionId INT,@VoucherId Varchar(50),@PromotionValue decimal(18,2),@LineNumber INT,@Quantity decimal(18,2),@NetValue decimal (18,2),@Type NVARCHAR(25)
	--				DECLARE StampCardCalculationCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
	--				SELECT PromotionId,VoucherId,PromotionValue,LineNumber,Quantity,NetValue,PromotionType
	--						FROM @VirtualStampCardDetails WHERE TrxId = @TrxidCur Order By TrxId,LineNumber                    
	--				OPEN StampCardCalculationCursor                                                  
	--					FETCH NEXT FROM StampCardCalculationCursor           
	--					INTO @PromotionId ,@VoucherId ,@PromotionValue ,@LineNumber ,@Quantity ,@NetValue ,@Type                             
	--					WHILE @@FETCH_STATUS = 0 
	--						BEGIN 
	--						PRINT '----------'
	--						PRINT @TrxidCur
	--						PRINT @BasketSum
	--						PRINT @DeviceId
	--						PRINT @LineNumber
	--						PRINT '----------'
	--						INSERT INTO #Epos_StampCardCalculation
	--						EXEC [dbo].[Epos_StampCardCalculation] 	@TrxidCur,	@PromotionId,@VoucherId,@PromotionValue,@LineNumber,@Quantity,@DeviceId,@NetValue,@Type,@BasketSum,	null

	--					FETCH NEXT FROM StampCardCalculationCursor     
	--					INTO @PromotionId ,@VoucherId ,@PromotionValue ,@LineNumber ,@Quantity ,@NetValue ,@Type         
	--					END     
	--				CLOSE StampCardCalculationCursor;    
	--				DEALLOCATE StampCardCalculationCursor; 
	--				INSERT INTO #Epos_ApplyStampCardOffer
	--				EXEC [dbo].[Epos_ApplyStampCardOffer] @TrxidCur,@DeviceId

	--				--EXEC [dbo].[EPOS_PointPromotions] @TrxidCur,@ClientId,'RoundPointsOnLineItem',1.0
	--				INSERT INTO #EPOS_AddRewardOffer
	--				EXEC [dbo].[EPOS_AddRewardOffer] @TrxidCur,@ClientId
	--		PRINT '----------'
	--		FETCH NEXT FROM TrxCursor     
	--		INTO @TrxidCur,@DeviceId 
	--	END     
	--CLOSE TrxCursor;    
	--DEALLOCATE TrxCursor; 
	---- Reward Promotion END

	--delete from [VirtualStampCard] where TrxId In (Select Distinct TrxId FROM #TrxIds)
END 
END
