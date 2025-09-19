-- =============================================
-- Modified by : Binu Jacob Scaria
-- Date: 2021-10-06
-- Description:	Assign Next Avilable StampCardVoucher 
-- Modified Date: 2021-10-06
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_AssignNextAvilableStampCardVoucher_UAT_BAK03012024] ( 
												@ClientId INT,
												@ProfileTypeId INT,
												@Quantity INT,
												@MemberId INT,
												@DeviceIdentifier INT = 0,
												@TrxId INT = 0,
												@rewardPromoId INT = 0,
												@DefaultVoucherCount INT = 0
                                             )
                                              
                                              
AS
  BEGIN
  
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
--PRINT '------------------------'
--PRINT @ClientId
--PRINT @ProfileTypeId
--PRINT @Quantity 
--PRINT @MemberId 
--PRINT @DeviceIdentifier 
--PRINT @TrxId
--PRINT @rewardPromoId
--PRINT @DefaultVoucherCount
--PRINT '------------------------'
     SET NOCOUNT ON;
	 --SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	  BEGIN TRY
      --BEGIN TRAN  
	  
	  --PRINT 'SP [EPOS_AssignNextAvilableStampCardVoucher]'
	  --PRINT @ProfileTypeId
	  --DECLARE @ProfileTypeId INT
	  --SET @ProfileTypeId= --(select dp.Id from DeviceProfileTemplate dp join DeviceProfileTemplateType dptp on dp.DeviceProfileTemplateTypeId=dptp.Id  where dptp.Name='EShopLoyalty' and dptp.ClientId=@ClientId)
	  DECLARE @DeviceStatusId INT,@ProfileStatusId INT,@DeviceStatusIdActive INT,@ProfileStatusIdActive INT,@DeviceStatusIdInactive INT = 0,@ProfileStatusIdInactive INT = 0
	  
	  DECLARE @Result NVARCHAR(500) ,	@ResultQty INT = 0,@VoucherProfile NVARCHAR(250) = ''


	  Declare @expirypolicyId int,@expiryDate datetime=DATEADD(day,365, DATEADD(day, DATEDIFF(day, 0, GETDATE()), '23:59:00')),@nodaystoExpire int;
	  select TOP 1 @VoucherProfile = Name ,@expirypolicyId =ExpirationPolicyId from DeviceProfileTemplate where  ID = @ProfileTypeId
	  

	  select @DeviceStatusId= DeviceStatusId from DeviceStatus  where Name='Ready' and ClientId=@ClientId
	  select @ProfileStatusId= DeviceProfileStatusId from DeviceProfileStatus  where Name='Created' and ClientId=@ClientId

	  select @DeviceStatusIdActive= DeviceStatusId from DeviceStatus  where Name='Active' and ClientId=@ClientId
	  select @ProfileStatusIdActive= DeviceProfileStatusId from DeviceProfileStatus  where Name='Active' and ClientId=@ClientId

	   IF ISNULL(@DefaultVoucherCount,0) > 0
	   BEGIN
			 select @DeviceStatusIdInactive= DeviceStatusId from DeviceStatus  where Name='Inactive' and ClientId=@ClientId
			 select @ProfileStatusIdInactive= DeviceProfileStatusId from DeviceProfileStatus  where Name='Inactive' and ClientId=@ClientId
	  END

	  --DROP TABLE IF EXISTS #NewStampCardVoucherAssgined
	  --CREATE TABLE #NewStampCardVoucherAssgined(DeviceAssginId INT IDENTITY(1,1),DeviceId INT,DeviceNumber NVARCHAR(25),UsageType NVARCHAR(25))

	  DECLARE @DeviceId VARCHAR(50),@DId INT,@AccountId INT--,@QuantityCounter INT = 0
	  IF @expirypolicyId > 0
	  BEGIN
	  select @nodaystoExpire = NumberDaysUntilExpire from DeviceExpirationPolicy where Id=@expirypolicyId
	  SET @expiryDate = DATEADD(day,@nodaystoExpire, DATEADD(day, DATEDIFF(day, 0, GETDATE()), '23:59:00')) ; 
	  END

		Drop table if exists #DL
		Select devicelotid into #DL 
		from devicelotdeviceprofile 
		where deviceprofileid =@ProfileTypeId 

		DROP TABLE IF EXISTS #TempDevice
		CREATE TABLE #TempDevice (DeviceAssginId INT IDENTITY(1,1),Id INT,DeviceId NVARCHAR(25),AccountId INT,DeviceStatusId INT,EmbossLine3 NVARCHAR(50),UserId INT,ExtraInfo NVARCHAR(100),ProfileStatusId INT,UsageType NVARCHAR(25))
		
		Update d set  d.[Owner]='-1',
		StartDate = getdate(),
		ExpirationDate=@expiryDate,
		EmbossLine2 = 'STAMP-' +CONVERT(VARCHAR(15),@TrxId),
		EmbossLine4 = CONVERT(VARCHAR(15), @DeviceIdentifier),
		OLD_AccountID = @DeviceIdentifier
		output  inserted.Id,inserted.DeviceId,inserted.AccountId,inserted.DeviceStatusId,inserted.EmbossLine3,NULL UserId,inserted.ExtraInfo,NULL ProfileStatusId,NULL UsageType  into #TempDevice
		from device d join (
		select top (@Quantity) dv.id
		from device dv --join #DL dl on dv.devicelotid=dl.devicelotid
		where dv.userid is null and ExtraInfo is null and dv.DeviceStatusId = @DeviceStatusId and dv.Devicelotid in (1102,1082,1083,1084) and  [Owner] is null
		and (ABS(CAST((BINARY_CHECKSUM (dv.Id, NEWID())) as int))  % 100) < 10
		) x on x.id=d.id
		--(1102,1082,1083,1084)
		--Update d set  d.[Owner]='-1',
		--StartDate = getdate(),
		--ExpirationDate=@expiryDate,
		--EmbossLine2 = 'STAMP-' +CONVERT(VARCHAR(15),@TrxId),
		--EmbossLine4 = CONVERT(VARCHAR(15), @DeviceIdentifier)
		--from device d join (
		--select top (@Quantity) dv.id
		--from device dv join #DL dl on dv.devicelotid=dl.devicelotid
		--where dv.userid is null and ExtraInfo is null and dv.DeviceStatusId = @DeviceStatusId and ([Owner]!='-1' or [Owner] is null)
		--and (ABS(CAST((BINARY_CHECKSUM (dv.Id, NEWID())) as int))  % 100) < 10
		--) x on x.id=d.id

		--DROP TABLE IF EXISTS #TempDevice
		--CREATE TABLE #TempDevice (DeviceAssginId INT IDENTITY(1,1),Id INT,DeviceId NVARCHAR(25),AccountId INT,DeviceStatusId INT,EmbossLine3 NVARCHAR(50),UserId INT,ExtraInfo NVARCHAR(100),ProfileStatusId INT,UsageType NVARCHAR(25))
		
		--INSERT INTO #TempDevice(Id,DeviceId,AccountId,DeviceStatusId,EmbossLine3,ExtraInfo)
		--SELECT Id,DeviceId,AccountId,DeviceStatusId,EmbossLine3,ExtraInfo
		--FROM device 
		--Where EmbossLine2 = 'STAMP-' +CONVERT(VARCHAR(15),@TrxId) 
		--AND UserId is null 
		--AND EmbossLine4 = CONVERT(VARCHAR(15), @DeviceIdentifier)

		--SELECT * FROM #TempDevice

		WHILE (@ResultQty < @Quantity)
		BEGIN
			SET @ResultQty  = @ResultQty  + 1

			SET @DeviceId = '';
			select top 1 @DeviceId = DeviceId,@DId = Id from #TempDevice WHERE DeviceAssginId = @ResultQty
			PRINT @DeviceId
			IF ISNULL(@DeviceId,'')!= ''
			BEGIN
				IF ISNULL (@MemberId,0) > 0
				BEGIN
					--UPDATE Account SET userId = @MemberId WHERE AccountId = @AccountId
					IF ISNULL(@DefaultVoucherCount,0) > 0
					BEGIN
						UPDATE #TempDevice SET DeviceStatusId =@DeviceStatusIdInactive,
						UserId = @MemberId,
						EmbossLine3 = CONVERT(VARCHAR(15),@rewardPromoId)+'-IMMEDIATE',
						ProfileStatusId = @ProfileStatusIdInactive,
						UsageType = 'IMMEDIATE'
						WHERE DeviceAssginId = @ResultQty
						--UPDATE Device set Owner='-1',DeviceStatusId =@DeviceStatusIdInactive,UserId = @MemberId, StartDate = getdate(),ExpirationDate=@expiryDate, EmbossLine2 = 'STAMP-' +CONVERT(VARCHAR(15),@TrxId),EmbossLine3 = CONVERT(VARCHAR(15),@rewardPromoId)+'-IMMEDIATE',EmbossLine4 = CONVERT(VARCHAR(15), @DeviceIdentifier)   where DeviceId=@DeviceId
						--UPDATE DeviceProfile SET StatusId = @ProfileStatusIdInactive WHERE DeviceId = @DId
						--INSERT INTO #NewStampCardVoucherAssgined (DeviceId ,DeviceNumber ,UsageType) VALUES(@DId,@DeviceId,'IMMEDIATE')
					END
					ELSE
					BEGIN				
						UPDATE #TempDevice SET DeviceStatusId =@DeviceStatusIdActive
						,UserId = @MemberId,
						EmbossLine3 = CONVERT(VARCHAR(15),@rewardPromoId),
						ProfileStatusId = @ProfileStatusIdActive,
						UsageType = 'UNIQUE'
						WHERE DeviceAssginId = @ResultQty
						--UPDATE Device set Owner='-1',DeviceStatusId =@DeviceStatusIdActive,UserId = @MemberId, StartDate = getdate(),ExpirationDate=@expiryDate, EmbossLine2 = 'STAMP-' +CONVERT(VARCHAR(15),@TrxId),EmbossLine3 = CONVERT(VARCHAR(15),@rewardPromoId),EmbossLine4 = CONVERT(VARCHAR(15), @DeviceIdentifier)   where DeviceId=@DeviceId
						--UPDATE DeviceProfile SET StatusId = @ProfileStatusIdActive WHERE DeviceId = @DId
						--INSERT INTO #NewStampCardVoucherAssgined (DeviceId ,DeviceNumber ,UsageType) VALUES(@DId,@DeviceId,'UNIQUE')
					END
				END
				ELSE IF ISNULL (@DeviceIdentifier,0) > 0 
				BEGIN
					IF ISNULL(@DefaultVoucherCount,0) > 0
					BEGIN
						UPDATE #TempDevice SET DeviceStatusId =@DeviceStatusIdInactive,
						ExtraInfo = 'STAMP-' + CONVERT(VARCHAR(15), @DeviceIdentifier),
						EmbossLine3 = CONVERT(VARCHAR(15),@rewardPromoId)+'-IMMEDIATE',
						ProfileStatusId = @ProfileStatusIdInactive,
						UsageType = 'IMMEDIATE'
						WHERE DeviceAssginId = @ResultQty
						--UPDATE Device set Owner='-1',DeviceStatusId =@DeviceStatusIdInactive,ExtraInfo = 'STAMP-' + CONVERT(VARCHAR(15), @DeviceIdentifier), StartDate = getdate(), ExpirationDate=@expiryDate,EmbossLine2 = 'STAMP-' +CONVERT(VARCHAR(15),@TrxId),EmbossLine3 = CONVERT(VARCHAR(15),@rewardPromoId)+'-IMMEDIATE',EmbossLine4 = CONVERT(VARCHAR(15), @DeviceIdentifier)  where DeviceId=@DeviceId
						--UPDATE DeviceProfile SET StatusId = @ProfileStatusIdInactive WHERE DeviceId = @DId
						--INSERT INTO #NewStampCardVoucherAssgined (DeviceId ,DeviceNumber ,UsageType) VALUES(@DId,@DeviceId,'IMMEDIATE')
					END
					ELSE
					BEGIN
						UPDATE #TempDevice SET DeviceStatusId =@DeviceStatusIdActive,
						ExtraInfo = 'STAMP-' + CONVERT(VARCHAR(15), @DeviceIdentifier),
						EmbossLine3 = CONVERT(VARCHAR(15),@rewardPromoId),
						ProfileStatusId = @DeviceStatusIdActive,
						UsageType = 'UNIQUE'
						WHERE DeviceAssginId = @ResultQty
						--UPDATE Device set Owner='-1',DeviceStatusId =@DeviceStatusIdActive,ExtraInfo = 'STAMP-' + CONVERT(VARCHAR(15), @DeviceIdentifier), StartDate = getdate(), ExpirationDate=@expiryDate,EmbossLine2 = 'STAMP-' +CONVERT(VARCHAR(15),@TrxId),EmbossLine3 = CONVERT(VARCHAR(15),@rewardPromoId),EmbossLine4 = CONVERT(VARCHAR(15), @DeviceIdentifier)  where DeviceId=@DeviceId
						--UPDATE DeviceProfile SET StatusId = @ProfileStatusIdActive WHERE DeviceId = @DId
						--INSERT INTO #NewStampCardVoucherAssgined (DeviceId ,DeviceNumber ,UsageType) VALUES(@DId,@DeviceId,'UNIQUE')
					END
				END
					 
				IF ISNULL(@DefaultVoucherCount,0) > 0
				BEGIN
					PRINT 'DefaultVoucher USED' 
					SET @DefaultVoucherCount = @DefaultVoucherCount -1
				END
			END
		END

	--SELECT * FROM #TempDevice
	IF EXISTS (SELECT 1 FROM #TempDevice)
	BEGIN
		IF ISNULL (@MemberId,0) > 0
		BEGIN
			UPDATE A Set UserId = @MemberId FROM Account A INNER JOIN #TempDevice TD ON A.AccountId = TD.AccountID
		END
		UPDATE DP SET StatusId = TD.ProfileStatusId FROM DeviceProfile DP INNER JOIN #TempDevice TD ON DP.DeviceId = TD.Id WHERE TD.ProfileStatusId IS NOT NULL

		UPDATE D SET DeviceStatusId = TD.DeviceStatusId,UserId = TD.UserId, ExtraInfo = TD.ExtraInfo,EmbossLine3 = TD.EmbossLine3
		FROM Device D INNER JOIN #TempDevice TD ON D.ID = TD.Id WHERE TD.DeviceStatusId IS NOT NULL
	END
	--SELECT * FROM #TempDevice
	SELECT DeviceAssginId,Id AS DeviceId,DeviceId AS DeviceNumber,UsageType,@VoucherProfile VoucherProfile,@rewardPromoId PromotionId,@ProfileTypeId ProfileId FROM #TempDevice
	END TRY
	BEGIN CATCH
		PRINT 'ERROR'      
		PRINT ERROR_NUMBER() 
		PRINT ERROR_SEVERITY()  
		PRINT ERROR_STATE()
		PRINT ERROR_PROCEDURE() 
		PRINT ERROR_LINE()  
		PRINT ERROR_MESSAGE()   
		--ROLLBACK TRAN
		PRINT 'ROLLBACK'
	END CATCH
  END
