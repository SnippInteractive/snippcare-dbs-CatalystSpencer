-- =============================================
-- Modified by : Binu Jacob Scaria
-- Date: 2021-10-06
-- Description:	Assign Next Avilable StampCardVoucher 
-- Modified Date: 2021-10-06
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_AssignNextAvilableStampCardVoucher] ( 
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
	  
	  SET @DeviceStatusId= 6--<<TODO>> select  DeviceStatusId,name from DeviceStatus  where Name='Ready' and ClientId=1
	  --select @DeviceStatusId= DeviceStatusId from DeviceStatus  where Name='Ready' and ClientId=@ClientId
	  SET @ProfileStatusId= 1--<<TODO>> select DeviceProfileStatusId,name from DeviceProfileStatus  where Name='Created' and ClientId=1
	  --select @ProfileStatusId= DeviceProfileStatusId from DeviceProfileStatus  where Name='Created' and ClientId=@ClientId

	  SET @DeviceStatusIdActive = 2--<<TODO>> select DeviceStatusId,name from DeviceStatus  where Name='Active' and ClientId=1
	  --select @DeviceStatusIdActive= DeviceStatusId from DeviceStatus  where Name='Active' and ClientId=@ClientId
	  SET @ProfileStatusIdActive= 2--<<TODO>>select  DeviceProfileStatusId,name from DeviceProfileStatus  where Name='Active' and ClientId=1
	  --select @ProfileStatusIdActive= DeviceProfileStatusId from DeviceProfileStatus  where Name='Active' and ClientId=@ClientId

	   IF ISNULL(@DefaultVoucherCount,0) > 0
	   BEGIN
			SET  @DeviceStatusIdInactive=1--<<TODO>> select DeviceStatusId,name from DeviceStatus  where Name='Inactive' and ClientId=1
			 --select @DeviceStatusIdInactive= DeviceStatusId from DeviceStatus  where Name='Inactive' and ClientId=@ClientId
			 SET @ProfileStatusIdInactive= 4--<<TODO>> select DeviceProfileStatusId,name from DeviceProfileStatus  where Name='Inactive' and ClientId=1
			 --select @ProfileStatusIdInactive= DeviceProfileStatusId from DeviceProfileStatus  where Name='Inactive' and ClientId=@ClientId
	  END

	  --DROP TABLE IF EXISTS #NewStampCardVoucherAssgined
	  --CREATE TABLE #NewStampCardVoucherAssgined(DeviceAssginId INT IDENTITY(1,1),DeviceId INT,DeviceNumber NVARCHAR(25),UsageType NVARCHAR(25))

	  DECLARE @DeviceId VARCHAR(50),@DId INT,@AccountId INT--,@QuantityCounter INT = 0
	  IF @expirypolicyId > 0
	  BEGIN
	  select @nodaystoExpire = NumberDaysUntilExpire from DeviceExpirationPolicy where Id=@expirypolicyId
	  SET @expiryDate = DATEADD(day,@nodaystoExpire, DATEADD(day, DATEDIFF(day, 0, GETDATE()), '23:59:00')) ; 
	  END
		
		/* UAT
		DeviceProfileId	DeviceProfileName	DeviceLotid
		1050	Free Tee(s)	1082
		1051	Free Piece(s) of Jewelry	1084
		1066	$10 Off -Segment	1101
		1067	$15 Off - Segment	1102
		1068	$20 Off -Segment	1103
		1069	$50 Off -Segment	1104
		*/
		DECLARE @DeviceLotId INT = 0
		IF @ProfileTypeId = 1050
		BEGIN
			SET @DeviceLotId = 1082
		END
		ELSE IF @ProfileTypeId = 1051
		BEGIN
			SET @DeviceLotId = 1084
		END
		ELSE IF @ProfileTypeId = 1066
		BEGIN
			SET @DeviceLotId = 1101
		END
		ELSE IF @ProfileTypeId = 1067
		BEGIN
			SET @DeviceLotId = 1102
		END
		ELSE IF @ProfileTypeId = 1068
		BEGIN
			SET @DeviceLotId = 1103
		END
		ELSE IF @ProfileTypeId = 1069
		BEGIN
			SET @DeviceLotId = 1104
		END
		/*ELSE
		BEGIN
			Select top 1 @DeviceLotId = devicelotid 
			from devicelotdeviceprofile WITH(NOLOCK)
			where deviceprofileid =@ProfileTypeId ORDER BY devicelotid DESC
		END*/


		/*PROD
		Free Tee(s)-Profileid 1050 - lotid 1082
		Free Piece(s) of Jewelry -profileid 1051 -lotid 1084
 
		Spend X Get Y $5 Off -profileid 1071 -lotid 1106
		Spend X Get Y $10 Off -profileid 1072 -lotid 1107
		Spend X Get Y $15 Off -profileid 1073 -lotid 1108
		Spend X Get Y $20 Off -profileid 1074 -lotid 1109

		DeviceProfileId	DeviceProfileName	DeviceLotid
		1067	$5 Off Internal Segment V2	1102
		1068	$10 Off Internal Segment V2	1103
		1069	$15 Off Internal Segment V2	1104
		1070	$20 Off Internal Segment V2	1105
		*/
		/*
		DECLARE @DeviceLotId INT = 0
		IF @ProfileTypeId = 1050
		BEGIN
			SET @DeviceLotId = 1082
		END
		ELSE IF @ProfileTypeId = 1051
		BEGIN
			SET @DeviceLotId = 1084
		END
		ELSE IF @ProfileTypeId = 1071
		BEGIN
			SET @DeviceLotId = 1106
		END
		ELSE IF @ProfileTypeId = 1072
		BEGIN
			SET @DeviceLotId = 1107
		END
		ELSE IF @ProfileTypeId = 1073
		BEGIN
			SET @DeviceLotId = 1108
		END
		ELSE IF @ProfileTypeId = 1074
		BEGIN
			SET @DeviceLotId = 1109
		END

		ELSE IF @ProfileTypeId = 1067
		BEGIN
			SET @DeviceLotId = 1102
		END
		ELSE IF @ProfileTypeId = 1068
		BEGIN
			SET @DeviceLotId = 1103
		END
		ELSE IF @ProfileTypeId = 1069
		BEGIN
			SET @DeviceLotId = 1104
		END
		ELSE IF @ProfileTypeId = 1070
		BEGIN
			SET @DeviceLotId = 1105
		END
		*/
		/*ELSE
		BEGIN
			Select top 1 @DeviceLotId = devicelotid
			from devicelotdeviceprofile WITH(NOLOCK)
			where deviceprofileid =@ProfileTypeId ORDER BY devicelotid DESC
		END*/


		DROP TABLE IF EXISTS #TempDevice
		CREATE TABLE #TempDevice (DeviceAssginId INT IDENTITY(1,1),Id INT,DeviceId NVARCHAR(25),AccountId INT,DeviceStatusId INT,EmbossLine3 NVARCHAR(50),UserId INT,ExtraInfo NVARCHAR(100),ProfileStatusId INT,UsageType NVARCHAR(25))
		
		IF ISNULL(@DeviceLotId,0) > 0
		BEGIN
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
			where dv.userid is null and ExtraInfo is null and dv.DeviceStatusId = @DeviceStatusId and [Owner] is null AND dv.Devicelotid = @DeviceLotId--([Owner]!='-1' or [Owner] is null)
			and (ABS(CAST((BINARY_CHECKSUM (dv.Id, NEWID())) as int))  % 100) < 10
			) x on x.id=d.id
		END
		ELSE 
		BEGIN
				
			Drop table if exists #DL
			CREATE TABLE #DL (DevicelotId INT)

			INSERT INTO #DL
			Select DISTINCT devicelotid --into #DL 
			from devicelotdeviceprofile 
			where deviceprofileid = @ProfileTypeId 
			
			Update d set  d.[Owner]='-1',
			StartDate = getdate(),
			ExpirationDate=@expiryDate,
			EmbossLine2 = 'STAMP-' +CONVERT(VARCHAR(15),@TrxId),
			EmbossLine4 = CONVERT(VARCHAR(15), @DeviceIdentifier),
			OLD_AccountID = @DeviceIdentifier
			output  inserted.Id,inserted.DeviceId,inserted.AccountId,inserted.DeviceStatusId,inserted.EmbossLine3,NULL UserId,inserted.ExtraInfo,NULL ProfileStatusId,NULL UsageType  into #TempDevice
			from device d join (
			select top (@Quantity) dv.id
			from device dv join #DL dl on dv.devicelotid=dl.devicelotid
			where dv.userid is null and ExtraInfo is null and dv.DeviceStatusId = @DeviceStatusId and [Owner] is null--([Owner]!='-1' or [Owner] is null)
			and (ABS(CAST((BINARY_CHECKSUM (dv.Id, NEWID())) as int))  % 100) < 10
			) x on x.id=d.id
		END

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
		UPDATE DP SET StatusId = TD.ProfileStatusId FROM DeviceProfile DP INNER JOIN #TempDevice TD ON DP.DeviceId = TD.Id 
		WHERE DP.DeviceId IN (SELECT Id FROM #TempDevice) AND TD.ProfileStatusId IS NOT NULL

		UPDATE D SET DeviceStatusId = TD.DeviceStatusId,UserId = TD.UserId, ExtraInfo = TD.ExtraInfo,EmbossLine3 = TD.EmbossLine3
		FROM Device D INNER JOIN #TempDevice TD ON D.ID = TD.Id WHERE D.Id IN (SELECT Id FROM #TempDevice) --TD.DeviceStatusId IS NOT NULL
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
