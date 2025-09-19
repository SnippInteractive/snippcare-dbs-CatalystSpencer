
-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2022-02-11
-- Description:	AT-1024 -- Stampcard Reward <<TODO POINT>>
-- Modified Date: 2021-10-06
-- Calling From CATALYST [ApplyPoints]
-- REMOVED Calling From API API_Device_AssignDeviceToUser
-- =============================================
CREATE PROCEDURE [dbo].[PersonalizeStampCard_P_BAK06JULY2023]
	-- Add the parameters for the stored procedure here
	(@UserId INT,@ClientId INT,@Trxid INT)
AS
BEGIN

DECLARE @DeviceId NVARCHAR(25)
DECLARE @BasketSum decimal(18,2) = 0
DECLARE @VirtualStampCardDetails TABLE	(TrxId INT, PromotionId INT,VoucherId VARCHAR(50),PromotionValue DECIMAL(18,2),LineNumber INT,Quantity DECIMAL(18,2),NetValue DECIMAL(18,2),PromotionType NVARCHAR(20))
DECLARE @PromotionId INT,@VoucherId Varchar(50),@PromotionValue decimal(18,2),@LineNumber INT,@Quantity decimal(18,2),@NetValue decimal (18,2),@Type NVARCHAR(25)

---USED FOR REMOVE SP RETUNS -- Cassing and issue in Apply Points SP
DECLARE @Epos_StampCardCalculation TABLE(Result INT,RewardId INT,RewardName NVARCHAR(250),VoucherValue decimal(18,2),DefaultVoucher NVARCHAR(25),ExistingQuantity decimal(18,2),VoucherSubType NVARCHAR(25),StampCardMultiplier float)
DECLARE @Epos_ApplyStampCardOffer TABLE (Result INT)
DECLARE @EPOS_AddRewardOffer TABLE (LineNumber varchar(50),	PromotionId varchar(50),PromotionName varchar(250),RewardId varchar(50),RewardName varchar(250),Quantity varchar(50), VoucherIds varchar(250),VoucherName varchar(250))
---USED FOR REMOVE SP RETUNS -- Cassing and issue in Apply Points SP

IF ISNULL(@TrxId,0) > 0 -- manual Claim Stamp
BEGIN
	
	SELECT @DeviceId = DeviceId FROM TrxHeader With(NOLOCK) Where TrxId  =@TrxId
	IF ISNULL(@DeviceId,'')!= '' AND ISNULL(@UserId,0) = 0
	BEGIN
		SELECT @UserId = UserId From Device Where DeviceId = @DeviceId
	END
	SELECT @BasketSum = SUM(Quantity) FROM VirtualStampCard WHERE TrxId = @Trxid

	INSERT INTO  @VirtualStampCardDetails SELECT TrxId, PromotionId,VoucherId,PromotionValue,LineNumber,Quantity,NetValue,PromotionType 
			FROM VirtualStampCard WHERE TrxId = @Trxid

	delete from [VirtualStampCard] 
	where trxid=@TrxId AND @TrxId > 0

	UPDATE PromotionStampCounter SET BeforeValue = 0 WHERE UserId = @UserId AND PromotionId IN (SELECT PromotionId FROM @VirtualStampCardDetails)

	DECLARE MCStampCardCalculationCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
	SELECT PromotionId,VoucherId,PromotionValue,LineNumber,Quantity,NetValue,PromotionType
			FROM @VirtualStampCardDetails WHERE TrxId = @Trxid Order By TrxId,LineNumber                    
	OPEN MCStampCardCalculationCursor                                                  
		FETCH NEXT FROM MCStampCardCalculationCursor           
		INTO @PromotionId ,@VoucherId ,@PromotionValue ,@LineNumber ,@Quantity ,@NetValue ,@Type                             
		WHILE @@FETCH_STATUS = 0 
			BEGIN 
			PRINT '----------'
			PRINT @Trxid
			PRINT @BasketSum
			PRINT @DeviceId
			PRINT @LineNumber
			PRINT '----------'
			INSERT INTO @Epos_StampCardCalculation
			EXEC [dbo].[Epos_StampCardCalculation] 	@TrxId,	@PromotionId,@VoucherId,@PromotionValue,@LineNumber,@Quantity,@DeviceId,@NetValue,@Type,@BasketSum,	null

		FETCH NEXT FROM MCStampCardCalculationCursor     
		INTO @PromotionId ,@VoucherId ,@PromotionValue ,@LineNumber ,@Quantity ,@NetValue ,@Type         
		END     
	CLOSE MCStampCardCalculationCursor;    
	DEALLOCATE MCStampCardCalculationCursor; 

	INSERT INTO @Epos_ApplyStampCardOffer
	EXEC [dbo].[Epos_ApplyStampCardOffer] @Trxid,@DeviceId

	--EXEC [dbo].[EPOS_PointPromotions] @Trxid,@ClientId,'RoundPointsOnLineItem',1.0
	--PRINT @Trxid 
	--PRINT @ClientId
	INSERT INTO @EPOS_AddRewardOffer
	EXEC [dbo].[EPOS_AddRewardOffer] @Trxid,@ClientId

END
ELSE IF ISNULL(@UserId,0) > 0 AND NOT EXISTS (SELECT 1 FROM [Audit] with(nolock) WHERE UserId = @UserId AND FieldName = 'PersonalizeStampCard' AND ReferenceType = 'PersonalizeStampCard') -- Personalize ALL Transaction
BEGIN
	 
	 EXEC Insert_Audit 'PersonalizeStampCard',@UserId,null,'PersonalizeStampCard','PersonalizeStampCard','','', 'Personalize StampCard'

	--Voucher
	select DISTINCT DeviceDeviceId,'STAMP-' + CONVERT(NVARCHAR(15), DeviceId) StampDeviceId,DeviceId AS DeviceIdentifier  
	INTO #UserLoyaltyDeviceList
	from   [VW_LoyaltyDevice] with(nolock)
	where  DeviceUserId = @UserId AND DeviceProfileTemplateTypeName IN ('Loyalty')

	select DISTINCT d.AccountId,D.Id,D.Deviceid 
	INTO #Voucher
	from Device d with(nolock) 
	INNER JOIN #UserLoyaltyDeviceList ul with(nolock) on d.ExtraInfo collate database_default = ul.StampDeviceId collate database_default 
	WHERE ISNULL(d.UserId,0) = 0

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

	SELECT DISTINCT Vs.PromotionId,dl.DeviceIdentifier INTO #OTFPromotionIdIds 
	FROM TrxHeader th with(nolock) Inner Join [VirtualStampCard] vs with(nolock) on th.TrxId = vs.TrxId 
	INNER JOIN #UserLoyaltyDeviceList dl on th.DeviceId = dl.DeviceDeviceId

	--Updating PromotionStampCounter
	UPDATE PromotionStampCounter
	SET UserId = @UserId
	FROM #OTFPromotionIdIds PD
	INNER JOIN PromotionStampCounter PC
	ON PC.PromotionId = PD.PromotionId AND PC.DeviceIdentifier = PD.DeviceIdentifier
	WHERE ISNULL(PC.UserId,0) = 0

	SELECT DISTINCT th.TrxId,th.DeviceId,vs.PromotionOfferType INTO #TrxIds 
	FROM TrxHeader th with(nolock) Inner Join [VirtualStampCard] vs with(nolock) on th.TrxId = vs.TrxId 
	WHERE th.DeviceId IN (SELECT DeviceDeviceId FROM #UserLoyaltyDeviceList)

	delete from [VirtualStampCard] where PromotionOfferType IN('Voucher') AND TrxId In (Select Distinct TrxId FROM #TrxIds)

	--Voucher Ends
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

	--				SELECT @BasketSum = SUM(NetValue) FROM VirtualStampCard WHERE TrxId = @TrxidCur

	--				--DECLARE @VirtualStampCardDetails TABLE	(TrxId INT, PromotionId INT,VoucherId VARCHAR(50),PromotionValue DECIMAL(18,2),LineNumber INT,Quantity DECIMAL(18,2),NetValue DECIMAL(18,2),PromotionType NVARCHAR(20))

	--				INSERT INTO  @VirtualStampCardDetails SELECT TrxId, PromotionId,VoucherId,PromotionValue,LineNumber,Quantity,NetValue,PromotionType 
	--						FROM VirtualStampCard WHERE TrxId = @TrxidCur AND PromotionOfferType = 'Reward'
					
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
	--						INSERT INTO @Epos_StampCardCalculation
	--						EXEC [dbo].[Epos_StampCardCalculation] 	@TrxidCur,	@PromotionId,@VoucherId,@PromotionValue,@LineNumber,@Quantity,@DeviceId,@NetValue,@Type,@BasketSum,	null

	--					FETCH NEXT FROM StampCardCalculationCursor     
	--					INTO @PromotionId ,@VoucherId ,@PromotionValue ,@LineNumber ,@Quantity ,@NetValue ,@Type         
	--					END     
	--				CLOSE StampCardCalculationCursor;    
	--				DEALLOCATE StampCardCalculationCursor; 
	--				INSERT INTO @Epos_ApplyStampCardOffer
	--				EXEC [dbo].[Epos_ApplyStampCardOffer] @TrxidCur,@DeviceId

	--				--EXEC [dbo].[EPOS_PointPromotions] @TrxidCur,@ClientId,'RoundPointsOnLineItem',1.0
	--				INSERT INTO @EPOS_AddRewardOffer
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
