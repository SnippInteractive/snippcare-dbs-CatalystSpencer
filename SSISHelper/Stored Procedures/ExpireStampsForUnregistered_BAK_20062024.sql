
CREATE Procedure [SSISHelper].[ExpireStampsForUnregistered_BAK_20062024] (@ExpireStampsForUnregistered int=45, @ClientId INT = 1) as 
/*
use catalystspencer
--Exec [SSISHelper].[ExpireStampsForUnregistered]  45,1
Write a new TRXHeader of EXPIRY type

Write a TRXDetail  (dont forget the promotionid)

Update PromotionStampCounter and set the AfterValue to zero BUT the TRXID to the Header just written (LatestTrxheader)

Add TrxDetailStampCard as a negative amount with PunchTrxType of 2 (Return)
*/

Begin
	drop table if exists #Expiration
	drop table if exists #ExpirationData
	--declare @ExpireStampsForUnregistered int=45, @ClientId INT = 1
	DECLARE  @TrxTypeIdExpiryStamps INT,@TrxStatusTypeIdCompleted INT,@TrxStatusTypeIdStarted INT,@SiteId INT,@ChkStartDate DateTime,@chkEndDate DateTime, @DeviceStatus_Active int

	select @TrxTypeIdExpiryStamps = TrxTypeId from TrxType Where name = 'ExpiryStamps' AND ClientId = @ClientId
	select @TrxStatusTypeIdCompleted = TrxStatusId from TrxStatus Where name = 'Completed' AND ClientId = @ClientId
	select @TrxStatusTypeIdStarted = TrxStatusId from TrxStatus Where name = 'Started' AND ClientId = @ClientId
	select @DeviceStatus_Active = DeviceStatusID from DeviceStatus where Name = 'Active' and ClientId = @ClientId

	select TOP 1  @SiteId = SiteId from Site Where SiteId = ParentId

	--select * into #Expiration from (
	--select DISTINCT d.DeviceId,MIN(trxdate) FirstTrx,MIN(th.TrxId) FirstTrxId, AfterValue, P.Id PromotionId,
	--MIN(P.Name) PromotionName, d.ExtraInfo, d.Id as DeviceIdentifier,MIN(PC.Name) PromotionCategory, newid() UniqueID
	--from trxheader th join site s on s.siteid = th.SiteId
	--join trxtype tt  on tt.trxtypeid=th.trxtypeid
	--join Device D  on th.DeviceId = D.DeviceId
	--join PromotionStampCounter psc on D.id=psc.deviceidentifier
	--join promotion P on psc.PromotionId = P.Id
	--join PromotionCategory pc  on p.PromotionCategoryId = pc.Id
	--WHERE th.TrxStatusTypeId = @TrxStatusTypeIdCompleted--ts.Name = 'Completed'
	--and s.clientid = @ClientId
	--and d.userid is null
	--and (psc.userid=0 or psc.userid is null)
	--and d.DeviceStatusId = @DeviceStatus_Active 
	--and AfterValue > 0
	--group by th.clientid,P.ID,d.deviceid,AfterValue, d.extrainfo, P.Description, d.Id) x
	--where datediff(day,FirstTrx ,getdate()) > @ExpireStampsForUnregistered
		
	--SELECT DISTINCT DeviceId,@TrxTypeIdExpiryStamps TrxTypeId,getdate() TrxDate,@ClientId ClientId,@SiteId SiteId,'Stamps Expiry' Reference,
	--@TrxStatusTypeIdCompleted TrxStatusTypeId,getdate() CreateDate,GETDATE() TrxCommitDate,GETDATE() LastUpdatedDate,
	--FirstTrxId InitialTransaction ,0 AS NewTrxId,PromotionName,AfterValue,0 AS Quantity, 0 AS Value,PromotionCategory,0 as NewTrxDetailId,PromotionId,DeviceIdentifier, UniqueID
	--INTO #ExpirationData
	--FROM #Expiration WHERE ISNULL(AfterValue,0) > 0
	
	----drop table if exists #Expiration
	
	--UPDATE #ExpirationData SET Quantity = AfterValue * -1 WHERE PromotionCategory = 'StampCardQuantity'
	--UPDATE #ExpirationData SET Value = AfterValue * -1 WHERE PromotionCategory != 'StampCardQuantity'

	--------- is there any transaction to insert?
	--if (select count(*) from #ExpirationData) >0
	--Begin
	--	Declare @outputTrxHeader table (TrxID int, CallContextID uniqueidentifier,InitialTransaction int );
	--	Declare @outputTrxDetail table (TrxID int, TrxDetailID int)

	--	BEGIN TRAN
	--	BEGIN TRY

	--	INSERT INTO TrxHeader(DeviceId,TrxTypeId,TrxDate,ClientId,SiteId,Reference,TrxStatusTypeId,
	--	CreateDate,TrxCommitDate,CallContextId,LastUpdatedDate,OpId,InitialTransaction)
	--	--OutPut table to get TRXID
	--	output inserted.TrxId, inserted.CallContextId, inserted.OLD_TrxId into @outputTrxHeader (TrxID, CallContextID,InitialTransaction) 
	--	SELECT DeviceId,TrxTypeId,TrxDate,ClientId,SiteId,Reference,TrxStatusTypeId,
	--	CreateDate,TrxCommitDate,UniqueID,LastUpdatedDate,PromotionId,InitialTransaction  
	--	FROM #ExpirationData
		
	--	INSERT INTO TrxDetail ([Version],TrxID,LineNumber,ItemCode,Description,Anal1,Quantity,Value,PromotionID,status,Points) 
	--	output inserted.TrxId, inserted.TrxDetailID  into @outputTrxDetail (TrxID, TrxDetailID) 
	--	SELECT distinct 1, oth.TrxID,1 LineNumber,'Expiry' ItemCode, PromotionName AS Description,'Stamps expiry' Anal1,Quantity,Value,PromotionId,'R' Status,0 AS Points 
	--	FROM #ExpirationData ed join @outputTrxHeader oth on ed.UniqueID=oth.CallContextID
			
	--	INSERT INTO TrxDetailStampCard ([Version], [PromotionId], [TrxDetailId], [ValueUsed], [PunchTrXType])
	--	SELECT DISTINCT 1,PromotionId,otd.TrxDetailID,Quantity,2 FROM #ExpirationData ed 
	--	join @outputTrxHeader oth on ed.UniqueID=oth.CallContextID
	--	join @outputTrxDetail otd on oth.trxid=otd.TrxID
	--	WHERE PromotionCategory = 'StampCardQuantity'

	--	INSERT INTO TrxDetailStampCard ([Version], [PromotionId], [TrxDetailId], [ValueUsed], [PunchTrXType])
	--	SELECT DISTINCT 1,PromotionId,otd.TrxDetailId,Value,2 FROM #ExpirationData ed
	--	join @outputTrxHeader oth on ed.UniqueID=oth.CallContextID
	--	join @outputTrxDetail otd on oth.trxid=otd.TrxID
	--	WHERE PromotionCategory != 'StampCardQuantity'

	--	UPDATE PSC SET 
	--	PSC.BeforeValue = 0, 
	--	PSC.PreviousStampCount =PSC.AfterValue,  
	--	PSC.AfterValue = 0 ,
	--	PSC.TrxId = oth.TrxID
	--	FROM PromotionStampCounter PSC INNER JOIN #ExpirationData ED ON PSC.DeviceIdentifier = ED.DeviceIdentifier
	--	join @outputTrxHeader oth on ed.UniqueID=oth.CallContextID
	--	WHERE ISNULL(PSC.AfterValue,0) > 0 AND  ISNULL(PSC.UserId,0) = 0 AND ISNULL(PSC.DeviceIdentifier,0) > 0 
	
	--	COMMIT TRAN
		

	--	drop table if exists #ExpirationData
	--END TRY  
	--BEGIN CATCH 
	--	ROLLBACK TRAN
	--END CATCH  
	--END
	

End



