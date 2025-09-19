-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2020-10-20
-- Description:	Include / Exclude
-- Modified Date: 2021-10-06
--ALTER DATABASE DB  SET COMPATIBILITY_LEVEL = 140;
-- =============================================
CREATE PROCEDURE [dbo].[Epos_ApplyStampCardOffer]
	-- Add the parameters for the stored procedure here
	(@TrxId INT,@DeviceId NVARCHAR(25),@ServiceCall INT=0)
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--DECLARE @NEWLOGIC INT=1
	
DECLARE @UserId INT,@CurrentQuantity decimal(18,2) = 0,@DeviceIdentifier INT,@ClientId INT
SELECT @UserId = D.UserId,@DeviceIdentifier = D.Id,@ClientId = ds.ClientId FROM DEVICE d  INNER JOIN DeviceStatus ds  on d.DeviceStatusId = ds.DevicestatusId WHERE DeviceId = @DeviceId

SET @UserId  = ISNULL(@UserId,0)

DROP TABLE IF EXISTS #StampCardVoucherAssgined
CREATE TABLE #StampCardVoucherAssgined(DeviceAssginId INT,DeviceId INT,DeviceNumber NVARCHAR(25),UsageType NVARCHAR(25),VoucherProfile NVARCHAR(250),PromotionId INT,ProfileId INT)
						
--BEGIN TRAN
IF  ISNULL (@DeviceIdentifier,0) > 0 --ISNULL (@UserId,0) > 0 OR
BEGIN
	--TEMP TABLES
	DROP TABLE IF EXISTS #VirtualStampCard
	CREATE TABLE #VirtualStampCard(Id INT, PromotionId int,VoucherId varchar(50),TrxId int,LineNumber int,PromotionValue decimal(18,2),Quantity decimal(18,2),NetValue decimal(18,2),
	StampCardType nvarchar(25),PromotionOfferType nvarchar(25),PromotionType nvarchar(20),ChildPromotionId INT,ChildPunch float,TrxDetailId INT,Stamps float,StampCardMultiplier float,
	QualifyingProductQuantity float,TrxDetailStamps float,ActualQuantity decimal(18,2),SingleNetValue decimal(18,2))

	DROP TABLE IF EXISTS #PromotionStampCounter
	CREATE TABLE #PromotionStampCounter([Id] INT,[Version] INT,[UserId] INT,[PromotionId] INT,[TrxId] INT,[CounterDate] DATETIME,[BeforeValue] INT,[AfterValue] DECIMAL(18,2),
	[PreviousStampCount] DECIMAL(18,2),OnTheFlyQuantity INT,[DeviceIdentifier] INT,PromotionName NVARCHAR(500),QualifyingProductQuantity float,QualifyingStampCount float,StampReward float,
	PromotionOfferType NVARCHAR(25),PromotionCategory  NVARCHAR(25),VoucherProfileId INT,QualifyiedTrxDetailId INT,StampCardMultiplier float,VoucherIds NVARCHAR(1000),VoucherName NVARCHAR(250),
	RewardName NVARCHAR(250),ValidLineNumbers NVARCHAR(2500),Reward NVARCHAR(500),RewardId INT,AnonymizeAfterValue DECIMAL(18,2),DefaultVoucherCount INT,TrxDetailStampsBeforeValue float,StampCardType NVARCHAR(25))

	INSERT INTO #VirtualStampCard(Id,PromotionId,VoucherId,TrxId,LineNumber,PromotionValue,Quantity,NetValue,StampCardType,PromotionOfferType,PromotionType,ChildPromotionId,ChildPunch)
	SELECT Id,PromotionId,VoucherId,TrxId,LineNumber,PromotionValue,Quantity,NetValue,StampCardType,PromotionOfferType,PromotionType,ChildPromotionId,ChildPunch
	FROM VirtualStampCard with(nolock) Where TrxId = @TrxId
	DECLARE @DefaultVoucher NVARCHAR(25)
	SET @DefaultVoucher = 'IMMEDIATE' --<<TODO>> SELECT  [Value] FROM ClientConfig  Where [Key] = 'StampcardDefaultVoucher' AND ClientId =1
	--SELECT @DefaultVoucher = [Value] FROM ClientConfig  Where [Key] = 'StampcardDefaultVoucher' AND ClientId =@ClientId

IF EXISTS (SELECT 1 FROM #VirtualStampCard)
BEGIN
	--IF Voucher is already used with line item then exclude line item for further calculation

	----TEMP TABLES
	--DROP TABLE IF EXISTS #VirtualStampCard
	--CREATE TABLE #VirtualStampCard(Id INT, PromotionId int,VoucherId varchar(50),TrxId int,LineNumber int,PromotionValue decimal(18,2),Quantity decimal(18,2),NetValue decimal(18,2),
	--StampCardType nvarchar(25),PromotionOfferType nvarchar(25),PromotionType nvarchar(20),ChildPromotionId INT,ChildPunch float,TrxDetailId INT,Stamps float,StampCardMultiplier float,
	--QualifyingProductQuantity float,TrxDetailStamps float,ActualQuantity decimal(18,2),SingleNetValue decimal(18,2))

	--DROP TABLE IF EXISTS #PromotionStampCounter
	--CREATE TABLE #PromotionStampCounter([Id] INT,[Version] INT,[UserId] INT,[PromotionId] INT,[TrxId] INT,[CounterDate] DATETIME,[BeforeValue] INT,[AfterValue] DECIMAL(18,2),
	--[PreviousStampCount] DECIMAL(18,2),OnTheFlyQuantity INT,[DeviceIdentifier] INT,PromotionName NVARCHAR(500),QualifyingProductQuantity float,QualifyingStampCount float,StampReward float,
	--PromotionOfferType NVARCHAR(25),PromotionCategory  NVARCHAR(25),VoucherProfileId INT,QualifyiedTrxDetailId INT,StampCardMultiplier float,VoucherIds NVARCHAR(1000),VoucherName NVARCHAR(250),
	--RewardName NVARCHAR(250),ValidLineNumbers NVARCHAR(250),Reward NVARCHAR(500),RewardId INT,AnonymizeAfterValue DECIMAL(18,2),DefaultVoucherCount INT,TrxDetailStampsBeforeValue float)

	DROP TABLE IF EXISTS #TrxDetail
	CREATE TABLE #TrxDetail(TrxId INT,TrxDetailId INT ,LineNumber INT,Points float,BonusPoints float,NetValue float,UpdatePoints float,UpdateBonusPoints float,ItemCode NVARCHAR(50) )

	DROP TABLE IF EXISTS #TrxVoucherdetail
	CREATE TABLE #TrxVoucherdetail(TrxDetailId INT ,TrxVoucherId NVARCHAR(30) collate SQL_Latin1_General_CP1_CI_AS,PromotionId INT,TrxVoucherDetailId INT)
	
	DROP TABLE IF EXISTS #usedVouchers
	DROP TABLE IF EXISTS #usedDefaultVouchers
	DROP TABLE IF EXISTS #StampVoucherPromotions

	DROP TABLE IF EXISTS #updateVirtualStampCard
	CREATE TABLE #updateVirtualStampCard (Id INT Identity (1,1),TrxVoucherId NVARCHAR(25) collate SQL_Latin1_General_CP1_CI_AS,Linenumber INT,VoucherProfileId INT,PromotionId INT,QualifyingProductQuantity float,
	StampCardMultiplier float,ChildPromotionId INT,ChildPunch float,UsageType NVARCHAR(25),TrxDetailId INT,OriginalVoucher NVARCHAR(25),DeviceId INT,TrxVoucherDetailId INT)
	
	DROP TABLE IF EXISTS #TEMPTrxHeaderRewardPromo
	CREATE TABLE #TEMPTrxHeaderRewardPromo (TrxId INT, PromotionId INT)

	--TEMP TABLES
	INSERT INTO #TrxDetail (TrxId,TrxDetailId ,LineNumber ,Points ,BonusPoints,NetValue,UpdatePoints,UpdateBonusPoints,ItemCode)
	SELECT TrxId,TrxDetailId,LineNumber,Points,BonusPoints,Value,0,0,ItemCode FROM TrxDetail  with(nolock) Where TrxId = @TrxId

	--SELECT CHARINDEX('2', '122222')

	--INSERT INTO #TrxVoucherdetail(TrxDetailId ,TrxVoucherId, PromotionId) 
	--SELECT tv.TrxDetailId ,tv.TrxVoucherId , 
	--CASE WHEN CHARINDEX(tv.TrxVoucherId, @DefaultVoucher) > 0 THEN REPLACE(tv.TrxVoucherId, @DefaultVoucher, '') ELSE null END
	--  AS PromotionId 
	--FROM TrxVoucherdetail tv 
	--INNER JOIN #TrxDetail td ON tv.TrxDetailId  = td.TrxDetailID 

	INSERT INTO #TrxVoucherdetail(TrxDetailId ,TrxVoucherId,TrxVoucherdetailId) 
	SELECT tv.TrxDetailId ,tv.TrxVoucherId ,tv.Id
	FROM TrxVoucherdetail tv  
	INNER JOIN #TrxDetail td ON tv.TrxDetailId  = td.TrxDetailID 

	UPDATE #TrxVoucherdetail SET PromotionId = REPLACE(TrxVoucherId, @DefaultVoucher, '') 
	WHERE TrxVoucherId LIKE(@DefaultVoucher+'%')

	--SELECT * FROM TrxVoucherdetail

	--INSERT INTO #VirtualStampCard(Id,PromotionId,VoucherId,TrxId,LineNumber,PromotionValue,Quantity,NetValue,StampCardType,PromotionOfferType,PromotionType,ChildPromotionId,ChildPunch)
	--SELECT Id,PromotionId,VoucherId,TrxId,LineNumber,PromotionValue,Quantity,NetValue,StampCardType,PromotionOfferType,PromotionType,ChildPromotionId,ChildPunch
	--FROM VirtualStampCard Where TrxId = @TrxId

	UPDATE vs SET vs.TrxDetailId = td.TrxDetailId, vs.NetValue = CASE ISNULL(Quantity,0) WHEN 0 THEN  0 ELSE td.NetValue END
	FROM #VirtualStampCard vs INNER JOIN #TrxDetail td ON vs.LineNumber = td.LineNumber

	INSERT INTO #PromotionStampCounter(Id,Version,UserId,PromotionId,TrxId,CounterDate,BeforeValue,AfterValue,PreviousStampCount,OnTheFlyQuantity,DeviceIdentifier,PromotionName,
	QualifyingProductQuantity,VoucherProfileId,StampCardMultiplier,Reward,StampCardType)--,QualifyiedTrxDetailId,PromotionOfferType,PromotionCategory,AnonymizeAfterValue
	SELECT DISTINCT PSC.Id,PSC.Version,PSC.UserId,PSC.PromotionId,PSC.TrxId,CounterDate,BeforeValue,AfterValue,AfterValue,OnTheFlyQuantity,DeviceIdentifier,P.Name,
	P.QualifyingProductQuantity,P.VoucherProfileId,ISNULL(P.StampCardMultiplier,1),P.Reward,v.StampCardType
	FROM [PromotionStampCounter] PSC 
	INNER JOIN #VirtualStampCard v ON PSC.PromotionId = V.PromotionId 
	INNER JOIN Promotion P ON PSC.PromotionId = P.Id
	where DeviceIdentifier = @DeviceIdentifier  

	UPDATE vs SET vs.StampCardMultiplier = pc.StampCardMultiplier,vs.QualifyingProductQuantity = pc.QualifyingProductQuantity,
	Stamps = CASE vs.StampCardType WHEN 'StampCardQuantity' THEN ISNULL(vs.Quantity,0) ELSE ISNULL(vs.NetValue,0) END,
	TrxDetailStamps = CASE vs.StampCardType WHEN 'StampCardQuantity' THEN ISNULL(vs.Quantity,0) ELSE ISNULL(vs.NetValue,0) END
	FROM #VirtualStampCard vs INNER JOIN #PromotionStampCounter pc ON vs.PromotionId = pc.PromotionId

	--SELECT 1
	/*
	IF EXISTS (SELECT 1 FROM #TrxDetail WHERE NetValue = 0 AND ItemCode NOT IN ('04237517','04237525','08219255','08219263') 
				--AND trxdetailid not in (SELECT trxdetailid FROM #TrxVoucherdetail WHERE TrxVoucherId LIKE '%DF%')
			   )
	BEGIN
		--SELECT 1
		PRINT 'StampCardQuantity Value becomes 0'
		UPDATE vs SET Stamps = 0
		FROM #VirtualStampCard vs 
		INNER JOIN #TrxDetail td ON vs.LineNumber = td.LineNumber 
		WHERE td.NetValue = 0 AND ItemCode NOT IN ('04237517','04237525','08219255','08219263')
		--AND td.trxdetailid not in (SELECT trxdetailid FROM #TrxVoucherdetail WHERE TrxVoucherId LIKE '%DF%')

		UPDATE PSC SET BeforeValue = ((ISNULL((SELECT SUM(Stamps) FROM #VirtualStampCard Where PromotionId =PSC.PromotionId),0) + CASE ISNULL(PSC.UserId,0) WHEN 0 THEN  0 ELSE ISNULL(PSC.AfterValue,0) END)
		/CONVERT(INT, QualifyingProductQuantity))
		FROM #PromotionStampCounter PSC WHERE StampCardType = 'StampCardQuantity' AND ISNULL(QualifyingProductQuantity,0) > 0
		
		UPDATE PSC SET BeforeValue = 0
		FROM #PromotionStampCounter PSC WHERE StampCardType = 'StampCardQuantity' AND ISNULL(QualifyingProductQuantity,0) > 0  AND BeforeValue < 0

		UPDATE PSC SET BeforeValue = BeforeValue * (QualifyingProductQuantity * -1)
		FROM #PromotionStampCounter PSC WHERE StampCardType = 'StampCardQuantity' AND ISNULL(QualifyingProductQuantity,0) > 0

		--SELECT * FROM #TrxVoucherdetail
		--SELECT * FROM #VirtualStampCard
		--SELECT * FROM #PromotionStampCounter
	END
	*/
	UPDATE PSC SET BeforeValue = ((ISNULL((SELECT SUM(Stamps) FROM #VirtualStampCard Where PromotionId =PSC.PromotionId),0) + CASE ISNULL(PSC.UserId,0) WHEN 0 THEN  0 ELSE ISNULL(PSC.AfterValue,0) END)
	/CONVERT(INT, QualifyingProductQuantity))
	FROM #PromotionStampCounter PSC WHERE StampCardType = 'StampCardValue' AND ISNULL(QualifyingProductQuantity,0) > 0

	UPDATE PSC SET BeforeValue = 0
	FROM #PromotionStampCounter PSC WHERE StampCardType = 'StampCardValue' AND ISNULL(QualifyingProductQuantity,0) > 0  AND BeforeValue < 0

	UPDATE PSC SET BeforeValue = BeforeValue * (QualifyingProductQuantity * -1)
	FROM #PromotionStampCounter PSC WHERE StampCardType = 'StampCardValue' AND ISNULL(QualifyingProductQuantity,0) > 0

	--SELECT * FROm #VirtualStampCard
	--UPDATE #VirtualStampCard SET Quantity = Quantity / (StampCardMultiplier + ChildPunch) WHERE StampCardType = 'StampCardQuantity' AND Quantity > 0
	--UPDATE #VirtualStampCard SET NetValue = NetValue / (StampCardMultiplier + ChildPunch) WHERE StampCardType = 'StampCardValue'  AND Quantity > 0

	UPDATE #VirtualStampCard SET ActualQuantity = ABS(FLOOR((ABS(ISNULL(Quantity,0)) - ABS(ISNULL(ChildPunch,0)))/ISNULL(StampCardMultiplier,1))) WHERE Quantity <> 0-- StampCardType = 'StampCardQuantity' AND Quantity <> 0
	UPDATE #VirtualStampCard SET SingleNetValue = NetValue / ISNULL(ActualQuantity,1) WHERE NetValue <> 0 --WHERE StampCardType = 'StampCardValue'  AND Quantity > 0

	UPDATE #VirtualStampCard SET ActualQuantity = 0 WHERE Quantity = 0
	UPDATE #VirtualStampCard SET SingleNetValue = 0 WHERE NetValue = 0

	--UNIQUE VOUCHER
	--Select Default voucher if it is used
	select DISTINCT TrxVoucherId,td.Linenumber ,dp.DeviceProfileId AS VoucherProfileId ,tv.trxDetailID,ISNULL(d.Id,0) AS DeviceId,ISNULL(vdpt.ClassicalVoucher,0) ClassicalVoucher,tv.TrxVoucherdetailId
	INTO #usedVouchers 
	from #TrxVoucherdetail tv 
	inner join #TrxDetail td on tv.trxdetailid  = td.trxdetailid 
	inner join Device d on tv.TrxVoucherId   = d.DeviceId --collate database_default
	inner join DeviceProfile dp on d.id=dp.DeviceId 
	inner join VoucherDeviceProfileTemplate vdpt on dp.DeviceProfileId = vdpt.Id
	--inner join DeviceProfileTemplate dpt  on dp.DeviceProfileId = dpt.Id
	where TrxVoucherId NOT LIKE (@DefaultVoucher+'%') --td.trxid = @TrxId AND
	--Select VoucherPromotion if it is used
	SELECT DISTINCT P.VoucherProfileId,P.PromotionId PromotionId,P.QualifyingProductQuantity,P.StampCardMultiplier
	INTO #StampVoucherPromotions 
	FROM #PromotionStampCounter p
	INNER JOIN #VirtualStampCard vs on p.PromotionId = vs.PromotionId
	INNER JOIN #usedVouchers uvp on p.VoucherProfileId = uvp.VoucherProfileId
	Where  p.VoucherProfileId IS NOT NULL AND vs.NetValue >= 0 --vs.TrxId = @TrxId AND

	INSERT INTO #updateVirtualStampCard (TrxVoucherId,Linenumber,VoucherProfileId,PromotionId,QualifyingProductQuantity,StampCardMultiplier,UsageType,trxDetailID,DeviceId,TrxVoucherdetailId)
	SELECT DISTINCT TrxVoucherId,Linenumber,uv.VoucherProfileId,PromotionId,QualifyingProductQuantity,StampCardMultiplier ,'UNIQUE' AS UsageType,trxDetailID,uv.DeviceId,TrxVoucherdetailId
	FROM #usedVouchers uv INNER JOIN #StampVoucherPromotions sv on uv.VoucherProfileId = sv.VoucherProfileId
	
	IF EXISTS (SELECT 1 FROM #usedVouchers Where ISNULL(DeviceId,0) > 0 AND ClassicalVoucher = 0)
	BEGIN
		DECLARE @DeviceStatusIdInactive INT,@ProfileStatusIdInactive INT
		SET @DeviceStatusIdInactive= 1 --<<TODO>>  select  DeviceStatusId from DeviceStatus  where Name='Inactive' and ClientId=1
		--select @DeviceStatusIdInactive= DeviceStatusId from DeviceStatus  where Name='Inactive' and ClientId=@ClientId
		SET @ProfileStatusIdInactive= 4 --<<TODO>>  select DeviceProfileStatusId from DeviceProfileStatus  where Name='Inactive' and ClientId=1
		--select @ProfileStatusIdInactive= DeviceProfileStatusId from DeviceProfileStatus  where Name='Inactive' and ClientId=@ClientId
		
		UPDATE D set DeviceStatusId = @DeviceStatusIdInactive
		FROM Device D INNER JOIN #usedVouchers ud on D.Id = ud.DeviceId
		Where ISNULL(ud.DeviceId,0) > 0 AND ClassicalVoucher = 0

		UPDATE D set StatusId = @ProfileStatusIdInactive
		FROM DeviceProfile D INNER JOIN #usedVouchers ud on D.DeviceId = ud.DeviceId
		Where ISNULL(ud.DeviceId,0) > 0 AND ClassicalVoucher = 0
		
	END
	--UNIQUE VOUCHER
	--DEFAULT VOUCHER 
	select DISTINCT TrxVoucherId,td.Linenumber ,tv.PromotionId ,StampCardMultiplier,p.VoucherProfileId,p.QualifyingProductQuantity,tv.trxDetailID,tv.TrxVoucherDetailId
	INTO #usedDefaultVouchers 
	from #TrxVoucherdetail tv 
	inner join #TrxDetail td  on tv.trxdetailid = td.trxdetailid 
	inner join #PromotionStampCounter p on tv.PromotionId = P.PromotionId
	where  td.trxid = @TrxId AND TrxVoucherId LIKE (@DefaultVoucher+'%') AND tv.PromotionId IS NOT NULL

	INSERT INTO #updateVirtualStampCard (TrxVoucherId,Linenumber,VoucherProfileId,PromotionId,QualifyingProductQuantity,StampCardMultiplier,UsageType,trxDetailID,DeviceId,TrxVoucherdetailId)
	SELECT TrxVoucherId,Linenumber,VoucherProfileId,PromotionId,QualifyingProductQuantity,StampCardMultiplier,'IMMEDIATE' AS UsageType,trxDetailID,0,TrxVoucherdetailId AS DeviceId FROM #usedDefaultVouchers
	--END DEFAULT VOUCHER 
	--UPDATE CHILD DETAILS

	update uvs
	set ChildPromotionId = vs.ChildPromotionId,ChildPunch =  ISNULL(vs.ChildPunch,0) / ((ISNULL(vs.Quantity,0) - ISNULL(vs.ChildPunch,0))/ISNULL(uvs.StampCardMultiplier,1))
	from #updateVirtualStampCard uvs 
	inner join #VirtualStampCard vs ON uvs.PromotionId = vs.PromotionId AND uvs.LineNumber = vs.LineNumber 
	and ISNULL(vs.ChildPromotionId,0) > 0
	--UPDATE CHILD DETAILS

	DECLARE @CurrentQty DECIMAL(18,2),@AfterValue DECIMAL(18,2),@BeforeValue DECIMAL(18,2),@CalBeforeValue INT,@OnTheFlyQuantity INT,@CalOnTheFlyQuantity INT
	DECLARE @VsPromotionStampCounterId INT = 0
	DECLARE @vsVoucherProfileId INT,@vsPromotionId INT, @vsLinenumber INT,@vsQualifyingProductQuantity decimal(18,2) = 0,@vsBeforeValue decimal(18,2),@vsStampCardMultiplier float,@vsUsageType NVARCHAR(20)
	
	--SELECT * FROM #updateVirtualStampCard
	
	--SELECT * FROM #VirtualStampCard Where Quantity > 0
	--SELECt * FROM #PromotionStampCounter

	DECLARE @WhileLimtDefaultVoucher INT
	SELECT @WhileLimtDefaultVoucher = MIN(Id) FROM #updateVirtualStampCard

	While @WhileLimtDefaultVoucher is not null
	BEGIN 
			SELECT TOP 1 @vsVoucherProfileId = VoucherProfileId ,@vsPromotionId = PromotionId ,@vsLinenumber= Linenumber,
			@vsQualifyingProductQuantity = ISNULL(QualifyingProductQuantity,0),
			@vsStampCardMultiplier = ISNULL(StampCardMultiplier,1) + ISNULL(ChildPunch,0) ,@vsUsageType = UsageType
			FROM #updateVirtualStampCard   WHERE Id = @WhileLimtDefaultVoucher
			
			--select @vsStampCardMultiplier

			SELECT @CalOnTheFlyQuantity = Count(PromotionId) FROM #updateVirtualStampCard WHERE PromotionId = @vsPromotionId AND UsageType = 'IMMEDIATE'
			IF(ISNULL(@vsUsageType,'UNIQUE') = 'UNIQUE')
			BEGIN
				UPDATE #VirtualStampCard SET Stamps = ISNULL(Stamps,0) - (@vsStampCardMultiplier * CASE StampCardType WHEN 'StampCardQuantity' THEN 1 ELSE 0 END) --SingleNetValue
				Where trxid = @TrxId AND VoucherId = @vsVoucherProfileId AND PromotionId = @vsPromotionId AND Linenumber = @vsLinenumber  AND PromotionOfferType  = 'Voucher' AND Quantity > 0 --AND UsageType = 'UNIQUE'
			END
			ELSE
			BEGIN
				UPDATE #VirtualStampCard SET Stamps = ISNULL(Stamps,0) - (@vsStampCardMultiplier * CASE StampCardType WHEN 'StampCardQuantity' THEN 1 ELSE 0 END) --SingleNetValue--(@vsStampCardMultiplier * (@vsQualifyingProductQuantity+1)) 
				Where trxid = @TrxId AND VoucherId = @vsVoucherProfileId AND PromotionId = @vsPromotionId AND Linenumber = @vsLinenumber  AND PromotionOfferType  = 'Voucher' AND Quantity > 0 --AND UsageType = 'UNIQUE'
			END

			SET @CurrentQty =0
			SET @AfterValue = 0

			SELECT @CurrentQty = SUM(Stamps) FROM #VirtualStampCard Where trxid = @TrxId AND PromotionId = @vsPromotionId  AND PromotionOfferType  = 'Voucher' --AND Quantity > 0
			--SELECT @CurrentQty
			IF ISNULL(@UserId,0) > 0 
			BEGIN
				SELECT @AfterValue = AfterValue,@BeforeValue = BeforeValue,@OnTheFlyQuantity = OnTheFlyQuantity,@VsPromotionStampCounterId = Id FROM #PromotionStampCounter  where UserId = @UserId AND PromotionId =@vsPromotionId
			END
			ELSE IF ISNULL (@DeviceIdentifier,0) > 0
			BEGIN
				SELECT @AfterValue = AfterValue,@BeforeValue = BeforeValue,@OnTheFlyQuantity = OnTheFlyQuantity,@VsPromotionStampCounterId = Id FROM #PromotionStampCounter  where UserId = 0 AND DeviceIdentifier = @DeviceIdentifier  AND PromotionId =@vsPromotionId
			END

			IF(ISNULL(@CurrentQty,0)+ISNULL(@AfterValue,0) > 0 AND ISNULL(@vsQualifyingProductQuantity,0) > 0)
			BEGIN
				SET @CalBeforeValue = (ISNULL(@CurrentQty,0) + ISNULL(@AfterValue,0)) - ((ISNULL(@CurrentQty,0) + ISNULL(@AfterValue,0)) % @vsQualifyingProductQuantity)
			END

			IF ISNULL(@CurrentQty,0)+ISNULL(@AfterValue,0) < @vsQualifyingProductQuantity
			BEGIN
				UPDATE #PromotionStampCounter SET BeforeValue = 0,OnTheFlyQuantity = 0 where Id = @VsPromotionStampCounterId
			END
			ELSE
			BEGIN
				UPDATE #PromotionStampCounter SET BeforeValue = ISNULL(@CalBeforeValue,0) * -1,OnTheFlyQuantity = ISNULL(@CalOnTheFlyQuantity,0) where Id = @VsPromotionStampCounterId
			END

		SELECT @WhileLimtDefaultVoucher = MIN(Id) FROM #updateVirtualStampCard WHERE Id > @WhileLimtDefaultVoucher
	END     
			
	--SELECT * FROM #VirtualStampCard-- Where Quantity > 0
	--SELECt * FROM #PromotionStampCounter

	--DELETE FROM #VirtualStampCard WHERE ISNULL(Stamps,0) < 0 AND trxid = @TrxId AND NetValue >= 0

	UPDATE PSC SET QualifyingStampCount = (SELECT SUM(Stamps) FROM #VirtualStampCard Where PromotionId =PSC.PromotionId),
	StampReward = FLOOR(ABS(ISNULL(BeforeValue,0)) / QualifyingProductQuantity),
	DefaultVoucherCount = (SELECT Count(Id) FROM #updateVirtualStampCard Where PromotionId = PSC.PromotionId AND UsageType = 'IMMEDIATE'),
	RewardId = (SELECT Case ISJSON (ISNULL(Reward,'')) when '' then null else (SELECT RewardId FROM OpenJson(Reward)WITH (RewardId INT '$.Id')) end),
	RewardName = (SELECT Case ISJSON (ISNULL(Reward,'')) when '' then null else (SELECT RewardName FROM OpenJson(Reward)WITH (RewardName NVARCHAR(150) '$.Name'))  end),
	QualifyiedTrxDetailId = (SELECT TOP 1 TrxDetailId FROM #VirtualStampCard Where PromotionId = PSC.PromotionId ORDER BY NetValue DESC),
	PromotionOfferType = (SELECT TOP 1 PromotionOfferType FROM #VirtualStampCard Where PromotionId =PSC.PromotionId),
	PromotionCategory = (SELECT TOP 1 StampCardType FROM #VirtualStampCard Where PromotionId =PSC.PromotionId),
	AnonymizeAfterValue = (SELECT Case (ISNULL(@UserId,0)) when 0 then AfterValue else 0 end)
	FROM #PromotionStampCounter PSC

	--UPDATE #PromotionStampCounter SET StampReward = ISNULL(StampReward,0) + ISNULL(DefaultVoucherCount,0) WHERE PromotionOfferType = 'Voucher'

	--SELECT * FROM #PromotionStampCounter
	--REWARD PROMO
		/*SELECT * INTO #VirtualStampCardRewardPromo FROM #VirtualStampCard WHERE PromotionOfferType  = 'Reward' AND Promotionvalue > 0  AND TrxDetailId IS NOT NULL --AND PromotionOfferValue > 0 
		--SELECT * FROM #VirtualStampCardRewardPromo
		IF EXISTS (SELECT 1 FROM #VirtualStampCardRewardPromo)
		BEGIN
			--SELECT * FROM #VirtualStampCardPointPromo
			--SELECT * FROM #PromotionStampCounter
			--PRINT 'Reward Promotion'
			DECLARE @trxTypeReward INT,@trxTypePoint INT,@SiteId INT,@reference NVARCHAR(50),@TrxdateTime DATETIMEOFFSET(7),@ApplicationNumber nvarchar(50),@trxstatusStarted INT
			SELECT @trxTypeReward = TrxTypeId FROM TrxType Where ClientId = @ClientId And Name = 'Reward'
			SELECT @trxstatusStarted = TrxStatusId FROM TrxStatus Where  ClientId = @ClientId And Name = 'Started'
			
			IF ISNULL(@SiteId,0) = 0
			BEGIN
				SELECT @SiteId=siteid,@reference=Reference,@TrxdateTime = TrxDate,@ApplicationNumber = ImportUniqueId from trxheader where trxid=@TrxId
			END
			INSERT INTO TrxHeader(ClientId,DeviceId,TrxTypeId,TrxDate,CreateDate,SiteId,Reference,OpId,TrxStatusTypeId,OLD_TrxId,ImportUniqueId,TerminalExtra,TerminalExtra2)
			OUTPUT Inserted.TrxId,Inserted.TerminalExtra INTO #TEMPTrxHeaderRewardPromo
			SELECT DISTINCT @ClientId,@DeviceId,@trxTypeReward,@TrxdateTime,GETDATE(),@SiteId, @reference,'0',@trxstatusStarted,@TrxId,@ApplicationNumber,PromotionId,'RewardPromotion'
			FROM #VirtualStampCardRewardPromo GROUP BY PromotionId

			--SELECT * FROM #TEMPTrxHeader
			----Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardId FROM OpenJson(Reward)WITH (RewardId INT '$.Id'))  end AS RewardId,
			----Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardName FROM OpenJson(Reward)WITH (RewardName NVARCHAR(150) '$.Name'))  end AS RewardName,
			----Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT ProductId FROM OpenJson(Reward)WITH (ProductId NVARCHAR(150) '$.RewardId'))  end AS ProductId,
			----Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardValue FROM OpenJson(Reward)WITH (RewardValue decimal(18,2) '$.Value'))  end AS RewardValue

			INSERT INTO TrxDetail(Version,TrxID,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE, PromotionId,AuthorisationNr,Points,Anal16)
			select 0 Version, th.TrxId,ROW_NUMBER() OVER (ORDER BY vr.Id) LineNumber,'RewardPromotion' ItemCode,PSC.PromotionName,1 Quantity,
			Case ISJSON (ISNULL(PSC.Reward,'')) when 0 then null else (SELECT RewardValue FROM OpenJson(Reward)WITH (RewardValue decimal(18,2) '$.Value'))  end AS RewardValue,
			vr.PromotionId,
			Case ISJSON (ISNULL(PSC.Reward,'')) when 0 then null else  (SELECT RewardId FROM OpenJson(Reward)WITH (RewardId NVARCHAR(150) '$.RewardId')) +'/'+ (SELECT Id FROM OpenJson(Reward)WITH (Id NVARCHAR(150) '$.Id'))  end AS AuthorisationNr
			,0 Points,LineNumber  Anal16
			FROM #TEMPTrxHeaderRewardPromo  th 
			INNER JOIN #VirtualStampCardRewardPromo vr on th.PromotionId = vr.PromotionId
			INNER JOIN #PromotionStampCounter PSC on th.PromotionId = PSC.PromotionId
			--SELECT * FROM TrxHeader WHERE TrxId IN (SELECT TrxId FROM #TEMPTrxHeaderRewardPromo)
			--SELECT * FROM TrxDetail WHERE TrxId IN (SELECT TrxId FROM #TEMPTrxHeaderRewardPromo)
		END*/
		--REWARD PROMO

	--Voucher PROMO
	--SELECT * FROM #PromotionStampCounter
	--SELECT * FROM #VirtualStampCard
	--UPDATE #PromotionStampCounter SET StampReward = StampReward + DefaultVoucherCount ,BeforeValue = BeforeValue +  (DefaultVoucherCount  * (QualifyingProductQuantity * -1))
	--WHERE PromotionCategory = 'StampCardValue' AND DefaultVoucherCount > 0 AND StampReward > 0 
	
	----SELECT * FROM #PromotionStampCounter

	--UPDATE #PromotionStampCounter SET StampReward = DefaultVoucherCount ,BeforeValue = (DefaultVoucherCount  * (QualifyingProductQuantity * -1))
	--WHERE PromotionCategory = 'StampCardValue' AND StampReward = 0 AND DefaultVoucherCount > 0 AND BeforeValue = 0
	--SELECT * FROM #PromotionStampCounter
	

	IF EXISTS (SELECT 1 FROM #PromotionStampCounter Where PromotionOfferType = 'Voucher' AND StampReward > 0)
	BEGIN
		--PRINT 'Voucher Promotion'
		DECLARE @WhileVoucherPromotionId INT,@ProfileId INT,@StampQuantity INT
		SELECT @WhileVoucherPromotionId = MIN(PromotionId) FROM #PromotionStampCounter Where PromotionOfferType = 'Voucher' AND StampReward > 0
		WHILE  @WhileVoucherPromotionId IS NOT NULL
		BEGIN
			--DECLARE @ResultVoucher VARCHAR(500) = '', @ResultQty INT = 0,@ResultVoucherProfile NVARCHAR(250) = '',
			DECLARE @DefaultVoucherCount INT = 0;
			
			DROP TABLE IF EXISTS #IMMVoucher

			SELECT *,ROW_NUMBER() OVER (ORDER BY Id) AS RowNumber INTO #IMMVoucher FROM #updateVirtualStampCard Where PromotionId = @WhileVoucherPromotionId AND UsageType = 'IMMEDIATE'

			SELECT @DefaultVoucherCount = Count(Id) FROM #IMMVoucher

			SET @DefaultVoucherCount = ISNULL(@DefaultVoucherCount,0)
			

			SELECT @ProfileId =VoucherProfileId,@StampQuantity = StampReward FROM #PromotionStampCounter WHERE PromotionOfferType = 'Voucher' AND StampReward > 0 AND PromotionId = @WhileVoucherPromotionId
			
			--SET @StampQuantity = @StampQuantity + @DefaultVoucherCount;

			INSERT INTO #StampCardVoucherAssgined
			EXEC EPOS_AssignNextAvilableStampCardVoucher @ClientId,@ProfileId,@StampQuantity,@UserId,@DeviceIdentifier,@Trxid,@WhileVoucherPromotionId,@DefaultVoucherCount --,@ResultVoucher OUTPUT,@ResultQty OUTPUT,@ResultVoucherProfile OUTPUT
			
			--SELECT * FROM #PromotionStampCounter
			--SELECT @DefaultVoucherCount,@StampQuantity,* FROM #IMMVoucher
			--SELECT * FROM #StampCardVoucherAssgined	

			DECLARE @IMMCount INT = 0
			SELECT @IMMCount = Count(DeviceNumber) FROM #StampCardVoucherAssgined WHERE PromotionID = @WhileVoucherPromotionId AND ProfileId = @ProfileId AND UsageType = 'IMMEDIATE'

			IF ISNULL(@DefaultVoucherCount,0) > 0 AND ISNULL(@IMMCount,0) > 0
			BEGIN
				UPDATE #IMMVoucher SET OriginalVoucher = DeviceNumber
				FROM #IMMVoucher IMM Inner Join #StampCardVoucherAssgined sa on IMM.RowNumber = sa.DeviceAssginId
				WHERE sa.PromotionID = @WhileVoucherPromotionId AND sa.ProfileId = @ProfileId

				UPDATE vs SET vs.OriginalVoucher = IMM.OriginalVoucher		
				FROM #updateVirtualStampCard vs 
				INNER JOIN #IMMVoucher IMM ON vs.PromotionId = IMM.PromotionId AND vs.TrxDetailId = IMM.TrxDetailID AND vs.Id = IMM.Id

			END
			SELECT @WhileVoucherPromotionId = MIN(PromotionId) FROM #PromotionStampCounter Where PromotionOfferType = 'Voucher' AND StampReward > 0 AND PromotionId > @WhileVoucherPromotionId
		END

		--SELECT * FROM #StampCardVoucherAssgined	
		--SELECT * FROM #IMMVoucher
		--SELECT * FROM #updateVirtualStampCard

		UPDATE TrxVoucherDetail SET TrxVoucherId = OriginalVoucher 
		FROM TrxVoucherDetail tv INNER JOIN #updateVirtualStampCard vs on 
		tv.TrxDetailId = vs.TrxDetailId AND tv.TrxVoucherId = vs.TrxVoucherId  --collate database_default --AND tv.PromotionId = vs.PromotionId
		And vs.OriginalVoucher IS NOT NULL AND vs.UsageType = 'IMMEDIATE'		
		AND tv.Id = vs.TrxVoucherDetailId

		--SELECT tv.TrxVoucherId,vs.TrxVoucherId,OriginalVoucher
		--FROM TrxVoucherDetail tv INNER JOIN #updateVirtualStampCard vs on 
		--tv.TrxDetailId = vs.TrxDetailId AND --tv.TrxVoucherId = vs.TrxVoucherId  collate database_default AND --AND tv.PromotionId = vs.PromotionId
		-- vs.OriginalVoucher IS NOT NULL AND vs.UsageType = 'IMMEDIATE'		
		--AND tv.Id = vs.TrxVoucherDetailId
	END
	--Vucher PROMO

	--UPDATE  td
 --   SET td.PromotionId = (
	--		SELECT TOP 1 vs.PromotionId
	--		FROM #VirtualStampCard vs
	--		WHERE vs.TrxDetailId = td.TrxDetailId
	--		ORDER BY vs.PromotionId ASC
	--	)
	--FROM TrxDetail td
	SELECT TrxDetailId,MIN(PromotionId) PromotionId INTO #TempVirtualStampCard FROM #VirtualStampCard Group By TrxDetailId

	UPDATE td SET td.PromotionId = vs.PromotionId--,td.PromotionalValue = isnull(vs.Stamps,0) 
	FROM TrxDetail td inner join #TempVirtualStampCard vs on td.TrxDetailId = vs.TrxDetailId AND td.PromotionId IS NULL 
	
	UPDATE #VirtualStampCard SET ChildPunch = 0 WHERE isnull(Stamps,0) <= 0
	--SELECT * FROM #PromotionStampCounter
	--SELECT * FROM #StampCardVoucherAssgined
	IF EXISTS (SELECT 1 FROM #StampCardVoucherAssgined)
	BEGIN
		DROP TABLE IF EXISTS #CalculateBeforeValue
		DROP TABLE IF EXISTS #CalculateBeforeValueConsolidated
		CREATE TABLE #CalculateBeforeValue (PromotionId INT,UsageType NVARCHAR(25),QualifyingProductQuantity float,UsageCount INT,TrxDetailStampsBeforeValue INT)
		CREATE TABLE #CalculateBeforeValueConsolidated (PromotionId INT,TrxDetailStampsBeforeValue INT)
		INSERT INTO #CalculateBeforeValue
		SELECT SA.PromotionId,SA.UsageType,P.QualifyingProductQuantity,count(SA.PromotionId) UsageCount,0 AS BeforeValue
		FROM #StampCardVoucherAssgined SA 
		INNER JOIN #PromotionStampCounter P ON SA.PromotionId = P.PromotionId
		WHERE PromotionOfferType = 'Voucher'
		GROUP BY SA.PromotionId,UsageType,QualifyingProductQuantity

		UPDATE #CalculateBeforeValue SET TrxDetailStampsBeforeValue = (QualifyingProductQuantity*UsageCount) WHERE UsageType = 'IMMEDIATE'
		UPDATE #CalculateBeforeValue SET TrxDetailStampsBeforeValue = (QualifyingProductQuantity*UsageCount) WHERE UsageType <> 'IMMEDIATE'

		INSERT INTO #CalculateBeforeValueConsolidated
		SELECT PromotionId,SUM(ISNULL(TrxDetailStampsBeforeValue,0)) TrxDetailStampsBeforeValue 
		FROM #CalculateBeforeValue Group By PromotionId

		UPDATE PSC SET PSC.TrxDetailStampsBeforeValue = ISNULL(CB.TrxDetailStampsBeforeValue,0) * -1
		FROM #PromotionStampCounter  PSC INNER JOIN #CalculateBeforeValueConsolidated CB ON PSC.PromotionId = CB.PromotionId
	END

	--insert into TrxDetailStampCard(PromotionId,TrxDetailId,ValueUsed,PunchTrXType,ChildPromotionId,ChildPunch)
	--select DISTINCT PromotionId,TrxDetailId,isnull(TrxDetailStamps,0) ValueUsed,1 AS PunchTrXType,ChildPromotionId,ChildPunch
	--from #VirtualStampCard Where ISNULL(TrxDetailId,0) > 0  And TrxDetailStamps <> 0 
	--UNION 
	--SELECT PromotionId,QualifyiedTrxDetailId, TrxDetailStampsBeforeValue,3 AS PunchTrXType,null,null 
	--FROM #PromotionStampCounter WHERE StampReward > 0 AND ISNULL(QualifyiedTrxDetailId,0) > 0

	IF @UserId > 0
	BEGIN
		insert into PromotionRedemptionCount (MemberId,PromotionId,LastRedemptionDate,TrxId,ItemCode)
		SELECT @UserId,PromotionId,GETDATE(),@TrxId,'SKU-NA' FROM #VirtualStampCard Where PromotionValue > 0 
	END

	--UPDATE PSC SET ValidLineNumbers = (SELECT STRING_AGG([LineNumber],',') FROM #VirtualStampCard Where PromotionId =PSC.PromotionId AND ISNULL(Stamps,0) >= 0),
	--VoucherIds = (SELECT STRING_AGG(DeviceNumber,',') FROM #StampCardVoucherAssgined Where PromotionId =PSC.PromotionId),
	--VoucherName = (SELECT TOP 1 VoucherProfile FROM #StampCardVoucherAssgined Where PromotionId =PSC.PromotionId),
	--OnTheFlyQuantity = (SELECT Count(DeviceNumber) FROM #StampCardVoucherAssgined WHERE PromotionId =PSC.PromotionId AND UsageType = 'IMMEDIATE')
	--FROM #PromotionStampCounter PSC

	--SELECT * FROM #PromotionStampCounter
	--SELECT * FROM #VirtualStampCard
	--SELECT * FROM #updateVirtualStampCard
	--SELECT * FROM #StampCardVoucherAssgined

	--select DISTINCT PromotionId,TrxDetailId,isnull(TrxDetailStamps,0) ValueUsed,1 AS PunchTrXType,ChildPromotionId,ChildPunch
	--from #VirtualStampCard Where ISNULL(TrxDetailId,0) > 0  And TrxDetailStamps <> 0 
	--UNION 
	--SELECT PromotionId,QualifyiedTrxDetailId, BeforeValue,3 AS PunchTrXType,null,null 
	--FROM #PromotionStampCounter WHERE StampReward > 0 AND ISNULL(QualifyiedTrxDetailId,0) > 0

	--UPDATE PS
	--SET PS.PreviousStampCount = PS.AfterValue ,
	--PS.AfterValue = CASE WHEN  ISNULL(PS.AfterValue,0) +ISNULL(TPS.BeforeValue,0)  + ISNULL(TPS.QualifyingStampCount,0) <= 0 THEN 0 ELSE ISNULL(PS.AfterValue,0) +ISNULL(TPS.BeforeValue,0)  + ISNULL(TPS.QualifyingStampCount,0) END, --CASE WHEN ISNULL(ISNULL(PS.AfterValue,0) + ISNULL(TPS.BeforeValue,0) + ISNULL(TPS.QualifyingStampCount,0),0) <= 0 THEN 0 ELSE ISNULL(ISNULL(PS.AfterValue,0) + ISNULL(TPS.BeforeValue,0) + ISNULL(TPS.QualifyingStampCount,0),0) END,
	--PS.BeforeValue = 0,Ps.OnTheFlyQuantity = 0
	--FROM PromotionStampCounter PS INNER JOIN #PromotionStampCounter TPS ON PS.Id = TPS.Id

	UPDATE #PromotionStampCounter SET AfterValue = ISNULL(AfterValue,0) + ISNULL(BeforeValue,0) + ISNULL(QualifyingStampCount,0) 
	--WHERE PromotionCategory = 'StampCardQuantity'

	--UPDATE #PromotionStampCounter SET AfterValue = ISNULL(AfterValue,0) + ISNULL(BeforeValue,0) + ISNULL(QualifyingStampCount,0) 
	--WHERE PromotionCategory = 'StampCardValue' AND QualifyingStampCount > 0
	
	IF ISNULL(@UserId,0) = 0
	BEGIN
		DROP TABLE IF EXISTS #CreateVoucher
		SELECT ISNULL(FLOOR(ISNULL(AfterValue,0)/ISNULL(QualifyingProductQuantity,1)),0) StampReward,PromotionId ,VoucherProfileId
		INTO #CreateVoucher
		FROM #PromotionStampCounter WHERE PromotionOfferType = 'Voucher'

		IF EXISTS (SELECT 1 FROM #CreateVoucher Where StampReward > 0)
		BEGIN
			
			DECLARE @WhileCreateVoucherPromotionId INT,@CreateVoucherStampQuantity INT,@CreateVoucherProfileId INT
			SELECT @WhileCreateVoucherPromotionId = MIN(PromotionId) FROM #CreateVoucher Where StampReward > 0
			WHILE  @WhileCreateVoucherPromotionId IS NOT NULL
			BEGIN
				SELECT @CreateVoucherProfileId =VoucherProfileId,@CreateVoucherStampQuantity = StampReward 
				FROM #CreateVoucher WHERE PromotionId = @WhileCreateVoucherPromotionId
				
				INSERT INTO #StampCardVoucherAssgined
				EXEC EPOS_AssignNextAvilableStampCardVoucher @ClientId,@CreateVoucherProfileId,@CreateVoucherStampQuantity,@UserId,@DeviceIdentifier,@Trxid,@WhileCreateVoucherPromotionId,0 --,@ResultVoucher OUTPUT,@ResultQty OUTPUT,@ResultVoucherProfile OUTPUT
				--DECLARE TrxDetailStampCardId INT

				---SELECT TrxDetailStampCardId = Id FROM TrxDetailStampCard WHERE 

				--insert into TrxDetailStampCard(PromotionId,TrxDetailId,ValueUsed,PunchTrXType,ChildPromotionId,ChildPunch)
				--SELECT PromotionId,QualifyiedTrxDetailId, (ISNULL(QualifyingProductQuantity,0) * @CreateVoucherStampQuantity) * -1 ,3 AS PunchTrXType,null,null 
				--FROM #PromotionStampCounter WHERE PromotionId = @WhileCreateVoucherPromotionId

				UPDATE #PromotionStampCounter SET AfterValue = AfterValue - (@CreateVoucherStampQuantity * ISNULL(QualifyingProductQuantity,0)) ,
				TrxDetailStampsBeforeValue = (ABS(ISNULL(TrxDetailStampsBeforeValue,0)) + (@CreateVoucherStampQuantity * ISNULL(QualifyingProductQuantity,0))) * -1,
				StampReward = ISNULL(StampReward,0) + ISNULL(@CreateVoucherStampQuantity,0)
				WHERE PromotionId = @WhileCreateVoucherPromotionId
				--SELECT * FROM #StampCardVoucherAssgined
				SELECT @WhileCreateVoucherPromotionId = MIN(PromotionId) FROM #CreateVoucher Where StampReward > 0 AND PromotionId > @WhileCreateVoucherPromotionId
			END
		END

	END
	--SELECT * FROm #PromotionStampCounter

	--SELECT PromotionId,QualifyiedTrxDetailId, TrxDetailStampsBeforeValue,3 AS PunchTrXType,null,null 
	--FROM #PromotionStampCounter WHERE StampReward > 0 AND ISNULL(QualifyiedTrxDetailId,0) > 0

	--SELECT * FROM #VirtualStampCard
	--PunchTrXType 1 is Purchase , PunchTrXType 2 is Return, PunchTrXType 3 is burned for reward (GenerateReward), PunchTrXType 4 if there is any PreviousStampCount and 5 ReturnAdjustment
	insert into TrxDetailStampCard(Version,PromotionId,TrxDetailId,ValueUsed,PunchTrXType,ChildPromotionId,ChildPunch)
	select DISTINCT 0 AS Version, PromotionId,TrxDetailId,isnull(Stamps,0) ValueUsed,1 AS PunchTrXType,ChildPromotionId,ChildPunch
	from #VirtualStampCard Where ISNULL(TrxDetailId,0) > 0  And Quantity <> 0 AND isnull(Stamps,0) >=0
	UNION 
	select DISTINCT 0 AS Version, PromotionId,TrxDetailId,isnull(Stamps,0) ValueUsed,2 AS PunchTrXType,ChildPromotionId,ChildPunch
	from #VirtualStampCard Where ISNULL(TrxDetailId,0) > 0  And Quantity <> 0 AND isnull(Stamps,0) <0
	UNION 
	SELECT 0 AS Version, PromotionId,QualifyiedTrxDetailId, TrxDetailStampsBeforeValue,3 AS PunchTrXType,null,null 
	FROM #PromotionStampCounter WHERE StampReward > 0 AND ISNULL(QualifyiedTrxDetailId,0) > 0
	--UNION 
	--SELECT distinct 2 AS Version, PromotionId,QualifyiedTrxDetailId,ISNULL(PreviousStampCount,0), 4 AS PunchTrXType ,null,null  
	--FROM #PromotionStampCounter where isnull(PreviousStampCount,0) >= 0 and isnull(QualifyiedTrxDetailId,0) > 0
	--UNION 
	--SELECT 2 AS Version, PromotionId,QualifyiedTrxDetailId, ABS(ISNULL(AfterValue,0)),5 AS PunchTrXType,null,null 
	--FROM #PromotionStampCounter WHERE ISNULL(AfterValue,0) < 0

	UPDATE PSC SET ValidLineNumbers = (SELECT STRING_AGG([LineNumber],',') FROM #VirtualStampCard Where PromotionId =PSC.PromotionId AND ISNULL(Stamps,0) >= 0),
	VoucherIds = (SELECT STRING_AGG(DeviceNumber,',') FROM #StampCardVoucherAssgined Where PromotionId =PSC.PromotionId),
	VoucherName = (SELECT TOP 1 VoucherProfile FROM #StampCardVoucherAssgined Where PromotionId =PSC.PromotionId),
	OnTheFlyQuantity = (SELECT Count(DeviceNumber) FROM #StampCardVoucherAssgined WHERE PromotionId =PSC.PromotionId AND UsageType = 'IMMEDIATE')
	FROM #PromotionStampCounter PSC

	UPDATE PS
	SET PS.PreviousStampCount = PS.AfterValue ,
	PS.AfterValue = CASE WHEN ISNULL(TPS.AfterValue,0) <= 0 THEN 0 ELSE ISNULL(TPS.AfterValue,0) END,
	PS.BeforeValue = 0,Ps.OnTheFlyQuantity = 0
	FROM PromotionStampCounter PS INNER JOIN #PromotionStampCounter TPS ON PS.Id = TPS.Id

	--SELECT * FROM #PromotionStampCounter

	DELETE FROM VirtualStampCard WHERE trxid = @TrxId
END
ELSE --NEED THIS ONLY WHEN Point Promotion SP is not in Use
BEGIN

	DROP TABLE IF EXISTS #TrxDetailData
	CREATE TABLE #TrxDetailData(TrxId INT,TrxDetailId INT)
	
	INSERT INTO #TrxDetailData (TrxId,TrxDetailId)
	SELECT TrxId,TrxDetailId FROM TrxDetail  with(nolock) Where TrxId = @TrxId
	
	DROP TABLE IF EXISTS #TrxVoucherdetailData
	CREATE TABLE #TrxVoucherdetailData(TrxDetailId INT ,TrxVoucherId NVARCHAR(30) collate SQL_Latin1_General_CP1_CI_AS,PromotionId INT,TrxVoucherDetailId INT)

	INSERT INTO #TrxVoucherdetailData(TrxDetailId ,TrxVoucherId,TrxVoucherdetailId) 
	SELECT tv.TrxDetailId ,tv.TrxVoucherId ,tv.Id
	FROM TrxVoucherdetail tv  with(nolock)
	INNER JOIN #TrxDetailData td ON tv.TrxDetailId  = td.TrxDetailID 
	
	IF EXISTS (SELECT 1 FROM #TrxVoucherdetailData)
	BEGIN
		DECLARE @EDeviceStatusIdActive INT
		SET @EDeviceStatusIdActive = 2 --<<TODO>>  select  DeviceStatusId from DeviceStatus  where Name='Active' and ClientId=1
		--select @EDeviceStatusIdActive= DeviceStatusId from DeviceStatus  where Name='Active' and ClientId=@ClientId

		select DISTINCT ISNULL(d.Id,0) AS DeviceId,ISNULL(vdpt.ClassicalVoucher,0) ClassicalVoucher
		INTO #VouchersUsed 
		from #TrxVoucherdetailData tv 
		inner join #TrxDetailData td on tv.trxdetailid  = td.trxdetailid 
		inner join Device d WITH(NOLOCK) on tv.TrxVoucherId = d.DeviceId --collate database_default
		inner join DeviceProfile dp WITH(NOLOCK) on d.id=dp.DeviceId 
		inner join VoucherDeviceProfileTemplate vdpt WITH(NOLOCK) on dp.DeviceProfileId = vdpt.Id
		where tv.TrxVoucherId NOT LIKE (@DefaultVoucher+'%') AND d.DeviceStatusId = @EDeviceStatusIdActive

		IF EXISTS (SELECT 1 FROM #VouchersUsed Where ISNULL(DeviceId,0) > 0 AND ClassicalVoucher = 0)
		BEGIN
			DECLARE @EDeviceStatusIdInactive INT,@EProfileStatusIdInactive INT
			SET @EDeviceStatusIdInactive= 1 --<<TODO>>  select  DeviceStatusId from DeviceStatus  where Name='Inactive' and ClientId=1
			--select @EDeviceStatusIdInactive= DeviceStatusId from DeviceStatus  where Name='Inactive' and ClientId=@ClientId
			SET @EProfileStatusIdInactive= 4 --<<TODO>>  select DeviceProfileStatusId from DeviceProfileStatus  where Name='Inactive' and ClientId=1
			--select @EProfileStatusIdInactive= DeviceProfileStatusId from DeviceProfileStatus  where Name='Inactive' and ClientId=@ClientId
		
			UPDATE D set DeviceStatusId = @EDeviceStatusIdInactive
			FROM Device D INNER JOIN #vouchersUsed ud on D.Id = ud.DeviceId
			Where ISNULL(ud.DeviceId,0) > 0 AND ClassicalVoucher = 0

			UPDATE D set StatusId = @EProfileStatusIdInactive
			FROM DeviceProfile D INNER JOIN #vouchersUsed ud on D.DeviceId = ud.DeviceId
			Where ISNULL(ud.DeviceId,0) > 0 AND ClassicalVoucher = 0

		END
	END
END
--ELSE
--BEGIN
--	IF ISNULL(@DeviceIdentifier,0) > 0
--	BEGIN
--		UPDATE PromotionStampCounter SET BeforeValue = 0,OnTheFlyQuantity = 0 WHERE DeviceIdentifier = @DeviceIdentifier
--	END
--END

	IF ISNULL(@ServiceCall,0) = 0
	BEGIN
		SELECT ValidLineNumbers LineNumber,PromotionId,PromotionName,RewardId,RewardName,StampReward Quantity,VoucherIds ,VoucherName 
		FROM #PromotionStampCounter Where  StampReward > 0 AND userid is not null and userid > 0--AND PromotionOfferType = 'Voucher'
	END
END



--TEMP TABLES
DROP TABLE IF EXISTS #VirtualStampCard
DROP TABLE IF EXISTS #PromotionStampCounter
DROP TABLE IF EXISTS #usedVouchers
DROP TABLE IF EXISTS #StampVoucherPromotions
DROP TABLE IF EXISTS #updateVirtualStampCard
DROP TABLE IF EXISTS #usedDefaultVouchers
DROP TABLE IF EXISTS #usedDefaultVouchersPromotion
--TEMP TABLES
END
