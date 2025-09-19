
CREATE Procedure [SSISHelper].[ExpireStampsForUnregistered] (@ExpireStampsForUnregistered int=45, @ClientId INT = 1) as 
/*

--Exec [SSISHelper].[ExpireStampsForUnregistered]  45,1
Write a new TRXHeader of EXPIRY type

Write a TRXDetail  (dont forget the promotionid)

Update PromotionStampCounter and set the AfterValue to zero BUT the TRXID to the Header just written (LatestTrxheader)

Add TrxDetailStampCard as a negative amount with PunchTrxType of 2 (Return)
*/

Begin
	
	DECLARE  @TrxTypeIdExpiryStamps INT,@TrxStatusTypeIdCompleted INT,@TrxStatusTypeIdStarted INT,@SiteId INT,@ChkStartDate DateTime,@chkEndDate DateTime, @DeviceStatus_Active int
	--DECLARE @DeviceStatus_Expired INT,@DeviceStatusId_Active INT 

	select @TrxTypeIdExpiryStamps = TrxTypeId from TrxType Where name = 'ExpiryStamps' AND ClientId = @ClientId
	select @TrxStatusTypeIdCompleted = TrxStatusId from TrxStatus Where name = 'Completed' AND ClientId = @ClientId
	select @TrxStatusTypeIdStarted = TrxStatusId from TrxStatus Where name = 'Started' AND ClientId = @ClientId
	select @DeviceStatus_Active = DeviceStatusID from DeviceStatus where Name = 'Active' and ClientId = @ClientId
	--select @DeviceStatus_Expired = DeviceStatusID from DeviceStatus where Name = 'Expired' and ClientId = @ClientId
	--SET @DeviceStatusId_Active =  = DeviceStatusID from DeviceStatus where Name = 'Active' and ClientId = @ClientId
	select TOP 1  @SiteId = SiteId from Site Where SiteId = ParentId

	DROP TABLE IF EXISTS #TrxFullData
	DROP TABLE IF EXISTS #TrxData
	DROP TABLE IF EXISTS #RomoveDataIFNoEarnedStamps
	drop table if exists #ExpirationData

	CREATE TABLE #RomoveDataIFNoEarnedStamps(ValueUsed DECIMAL(18,2), DeviceId NVARCHAR(25),DeviceIdentifier INT,TrxDate DATE)
	CREATE TABLE #TrxFullData(DeviceId NVARCHAR(25),DeviceIdentifier INT,TrxId INT,UserID INT,TrxTypeId INT,ValueUsed DECIMAL(18,2),PromotionId INT,PromotionCategory NVARCHAR(250),AfterValue DECIMAL(18,2),PromotionName NVARCHAR(1000),TrxDate DATETIME )
	CREATE TABLE #TrxData(DeviceId NVARCHAR(25),DeviceIdentifier INT,TrxId INT,UserID INT,TrxTypeId INT,ValueUsed DECIMAL(18,2),PromotionId INT,PromotionCategory NVARCHAR(250),AfterValue DECIMAL(18,2),PromotionName NVARCHAR(1000) ,TrxDate DATETIME)

	INSERT INTO #TrxFullData (DeviceId,DeviceIdentifier,TrxId,UserID,TrxTypeId,ValueUsed,PromotionId,TrxDate)
	select Distinct th.DeviceId,D.Id DeviceIdentifier,th.TrxId,D.UserID,th.TrxTypeId,SUM(ts.ValueUsed) ValueUsed,ts.PromotionId,th.TrxDate
	from TrxHeader th 
	inner join Device D  on th.DeviceId = D.DeviceId
	inner join TrxDetail td on th.TrxId = td.TrxID
	inner join TrxDetailStampcard ts on td.TrxDetailId = ts.TrxDetailId
	where th.TrxStatusTypeId  = @TrxStatusTypeIdCompleted
	AND th.TrxTypeId <> @TrxTypeIdExpiryStamps
	AND th.LastUpdatedDate IS NULL
	AND D.UserId IS NULL 
	AND ts.PunchTrXType NOT IN(4) -- 4 PreviousStampCount,3 GenerateReward
	AND datediff(day,trxdate ,getdate()) > @ExpireStampsForUnregistered --45 
	AND datediff(day,trxdate ,getdate()) < @ExpireStampsForUnregistered + 3
	group by th.DeviceId,D.Id,th.TrxId,D.UserID,th.TrxTypeId,ts.PromotionId,th.TrxDate

	
	INSERT INTO #RomoveDataIFNoEarnedStamps
	SELECT SUM(ValueUsed) ValueUsed,DeviceId,DeviceIdentifier,CONVERT(date,TrxDate) TrxDate
	FROM #TrxFullData
	Group BY CONVERT(date,TrxDate),DeviceId,DeviceIdentifier
	
	--SELECT * FROM #RomoveDataIFNoEarnedStamps

	DELETE #RomoveDataIFNoEarnedStamps WHERE ValueUsed >= 0
	
	--SELECT * FROM #RomoveDataIFNoEarnedStamps

	INSERT INTO #TrxData (DeviceId,DeviceIdentifier,TrxId,UserID,TrxTypeId,ValueUsed,PromotionId,TrxDate)
	SELECT tf.DeviceId,tf.DeviceIdentifier,tf.TrxId,tf.UserID,tf.TrxTypeId,tf.ValueUsed,tf.PromotionId ,tf.TrxDate--,rd.*
	FROM #TrxFullData tf 
	left join #RomoveDataIFNoEarnedStamps rd on tf.DeviceId = rd.DeviceId AND CONVERT(date,tf.TrxDate) = CONVERT(date,rd.TrxDate)
	WHERE  rd.DeviceId IS NULL

	--get  PromotionCategory
	UPDATE #TrxData SET PromotionCategory = PC.Name,PromotionName = P.Name
	FROM #TrxData td 
	join promotion P on td.PromotionId = P.Id
	join PromotionCategory pc  on p.PromotionCategoryId = pc.Id

	--get  Curent AfterValue
	UPDATE #TrxData SET AfterValue = psc.AfterValue
	FROM #TrxData td 
	join PromotionStampCounter psc on td.DeviceIdentifier=psc.DeviceIdentifier 
	AND td.PromotionId = psc.PromotionId

	
	
	--<TODO>UPDATE Device SET DeviceStatusId = @DeviceStatus_Expired,ExpirationDate = GETDATE() 
	--where EmbossLine2 LIKE('STAMP-%') AND UserId IS NULL AND datediff(day,StartDate ,getdate()) > @ExpireStampsForUnregistered AND DeviceStatusId = @DeviceStatusId_Active

	--Consolidate Trx Data by DeviceId and PromotionId
	drop table if exists #ExpirationData
	SELECT DISTINCT DeviceId,@TrxTypeIdExpiryStamps TrxTypeId,getdate() TrxDate,@ClientId ClientId,@SiteId SiteId,'Stamps Expiry' Reference,
	@TrxStatusTypeIdCompleted TrxStatusTypeId,getdate() CreateDate,GETDATE() TrxCommitDate,GETDATE() LastUpdatedDate,
	MAX(TrxId) InitialTransaction ,0 AS NewTrxId,MAX(PromotionName) PromotionName,SUM(ValueUsed) ValueUsed,CONVERT(float, 0) AS Quantity,
	CONVERT(money, 0) AS Value,PromotionCategory,0 as NewTrxDetailId,PromotionId,DeviceIdentifier, newid() UniqueID, AfterValue
	INTO #ExpirationData
	FROM #TrxData
	Group BY DeviceId,PromotionId,DeviceIdentifier,PromotionCategory,AfterValue

	--IF AfterValue is <= 0 do nothing
	--DELETE #ExpirationData WHERE AfterValue <=0 

	--IF there is no stamps earned do nothing
	DELETE #ExpirationData WHERE ValueUsed <=0 

	--IF AfterValue is <= 0 and stamps erned/returned need a counter entry for expiry with stamps 0
	UPDATE #ExpirationData SET ValueUsed = 0 Where AfterValue <= 0 AND ValueUsed <> 0

	--IF we dont have enough stamps to deduct then we set  ValueUsed to max avilable stamps
	UPDATE #ExpirationData SET ValueUsed = AfterValue Where ValueUsed > AfterValue

	--StampCard Quantity promotion 
	UPDATE #ExpirationData SET Quantity = ValueUsed * -1 WHERE PromotionCategory = 'StampCardQuantity'
	--StampCard Value promotion
	UPDATE #ExpirationData SET Value = ValueUsed * -1 WHERE PromotionCategory != 'StampCardQuantity'

	--SELECT * FROM #TrxFullData
	--SELECT * FROM #TrxData
	--SELECT * FROM #RomoveDataIFNoEarnedStamps
	--SELECT * FROM #ExpirationData

	BEGIN TRAN
	BEGIN TRY
	--Mark all selected transaction as Expired
	UPDATE th SET th.LastUpdatedDate = GETDATE() 
	FROM TrxHeader th 
	inner join #TrxFullData td on th.TrxId = td.TrxId

	------- is there any transaction to insert?
	if (select count(*) from #ExpirationData) >0
	Begin
		Declare @outputTrxHeader table (TrxID int, CallContextID uniqueidentifier,InitialTransaction int );
		Declare @outputTrxDetail table (TrxID int, TrxDetailID int)

		INSERT INTO TrxHeader(DeviceId,TrxTypeId,TrxDate,ClientId,SiteId,Reference,TrxStatusTypeId,
		CreateDate,TrxCommitDate,CallContextId,LastUpdatedDate,OpId,InitialTransaction)
		--OutPut table to get TRXID
		output inserted.TrxId, inserted.CallContextId, inserted.OLD_TrxId into @outputTrxHeader (TrxID, CallContextID,InitialTransaction) 
		SELECT DeviceId,TrxTypeId,TrxDate,ClientId,SiteId,Reference,TrxStatusTypeId,
		CreateDate,TrxCommitDate,UniqueID,LastUpdatedDate,PromotionId,InitialTransaction 
		FROM #ExpirationData
		
		INSERT INTO TrxDetail ([Version],TrxID,LineNumber,ItemCode,Description,Anal1,Quantity,Value,PromotionID,status,Points) 
		output inserted.TrxId, inserted.TrxDetailID  into @outputTrxDetail (TrxID, TrxDetailID) 
		SELECT distinct 1, oth.TrxID,1 LineNumber,'Expiry' ItemCode, PromotionName AS Description,'Stamps expiry' Anal1,Quantity,Value,PromotionId,'R' Status,0 AS Points
		FROM #ExpirationData ed join @outputTrxHeader oth on ed.UniqueID=oth.CallContextID
			
		INSERT INTO TrxDetailStampCard ([Version], [PromotionId], [TrxDetailId], [ValueUsed], [PunchTrXType])
		SELECT DISTINCT 1,PromotionId,otd.TrxDetailID,Quantity,2 FROM #ExpirationData ed 
		join @outputTrxHeader oth on ed.UniqueID=oth.CallContextID
		join @outputTrxDetail otd on oth.trxid=otd.TrxID
		WHERE PromotionCategory = 'StampCardQuantity'

		INSERT INTO TrxDetailStampCard ([Version], [PromotionId], [TrxDetailId], [ValueUsed], [PunchTrXType])
		SELECT DISTINCT 1,PromotionId,otd.TrxDetailId,Value,2 FROM #ExpirationData ed
		join @outputTrxHeader oth on ed.UniqueID=oth.CallContextID
		join @outputTrxDetail otd on oth.trxid=otd.TrxID
		WHERE PromotionCategory != 'StampCardQuantity'

		UPDATE PSC SET 
		PSC.BeforeValue = 0, 
		PSC.PreviousStampCount =PSC.AfterValue,  
		PSC.AfterValue = CASE WHEN PSC.AfterValue - ED.ValueUsed > 0 THEN PSC.AfterValue - ED.ValueUsed ELSE 0 END,--PSC.AfterValue - ED.ValueUsed,
		PSC.TrxId = oth.TrxID
		FROM PromotionStampCounter PSC 
		INNER JOIN #ExpirationData ED ON PSC.DeviceIdentifier = ED.DeviceIdentifier AND PSC.PromotionId = ED.PromotionId
		INNER JOIN @outputTrxHeader oth on ed.UniqueID=oth.CallContextID
		WHERE ISNULL(PSC.AfterValue,0) > 0 AND  ISNULL(PSC.UserId,0) = 0 AND ISNULL(PSC.DeviceIdentifier,0) > 0 

		--UPDATE PSC SET 
		--PSC.BeforeValue = 0, 
		--PSC.PreviousStampCount =PSC.AfterValue,  
		--PSC.AfterValue = 0 ,
		--PSC.TrxId = oth.TrxID
		--FROM PromotionStampCounter PSC INNER JOIN #ExpirationData ED ON PSC.DeviceIdentifier = ED.DeviceIdentifier
		--join @outputTrxHeader oth on ed.UniqueID=oth.CallContextID
		--WHERE ISNULL(PSC.AfterValue,0) > 0 AND  ISNULL(PSC.UserId,0) = 0 AND ISNULL(PSC.DeviceIdentifier,0) > 0 

	
	END
		COMMIT TRAN
	END TRY  
	BEGIN CATCH 
		ROLLBACK TRAN
	END CATCH  
	

End



