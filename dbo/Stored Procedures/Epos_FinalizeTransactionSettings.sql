-- =============================================
-- Author:		BINU JACOB SCARIA
-- Create date: 10-11-2023
-- Description:	Allways Call from FinalizeTransaction and roll back if any sp failed
-- =============================================
CREATE PROCEDURE [dbo].[Epos_FinalizeTransactionSettings]
	-- Add the parameters for the stored procedure here
	(@TrxId INT,@MemberId INT,@DeviceId nvarchar(25), @Method nvarchar(1000),@ClientId INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS #Method
	SELECT [Value]
	INTO #Method
	FROM STRING_SPLIT(@Method, ',');
	
	/*
		SELECT [Value]
		FROM STRING_SPLIT('', ',');
	*/

	IF  ISNULL(@TrxId,0) > 0 AND EXISTS (SELECT 1 FROM #Method WHERE [Value] = 'TrxStatus') --ISNULL(@Method,'') = 'TrxStatus' AND
	BEGIN
		DECLARE @trxStatusCompleted INT
		SELECT @trxStatusCompleted = TrxStatusId  from TrxStatus  where Name='Completed' AND ClientId = @ClientId;
		UPDATE TrxHeader SET TrxStatusTypeId = @trxStatusCompleted  Where TrxId = @TrxId
	END

	IF ISNULL(@TrxId,0) > 0 AND EXISTS (SELECT 1 FROM #Method WHERE [Value] = 'FinalizeVoucher') -- Call at the end of  FinalizeTransaction--ISNULL(@Method,'') = 'FinalizeVoucher'
	BEGIN
	PRINT 'FinalizeVoucher'
	
		--EPOS POINT PROMO
		DROP TABLE IF EXISTS #UsedClassicalVoucher;
		
		SELECT DISTINCT tv.TrxVoucherId
		INTO #UsedClassicalVoucher
		FROM TrxHeader th
		JOIN TrxDetail td ON td.TrxId = th.TrxId
		JOIN TrxVoucherDetail tv ON tv.TrxDetailId = td.TrxDetailId
		JOIN TrxStatus ts ON th.TrxStatusTypeId = ts.TrxStatusId
		JOIN Device d ON tv.TrxVoucherId = d.DeviceId
		JOIN DeviceLotDeviceProfile dldp ON d.DeviceLotId = dldp.DeviceLotId
		JOIN DeviceProfileTemplate dpt ON dldp.DeviceProfileId = dpt.Id
		JOIN DeviceProfileTemplatetype dpty ON dpt.DeviceProfileTemplatetypeId = dpty.Id
		JOIN VoucherDeviceProfileTemplate vdp ON dpt.Id = vdp.Id
		WHERE th.TrxID = @TrxId AND ts.Name = 'Completed' AND dpty.Name = 'Voucher' AND vdp.ClassicalVoucher = 1;

		IF EXISTS (SELECT 1 FROM #UsedClassicalVoucher) 
		BEGIN
			IF ISNULL(@MemberId,0) > 0
			BEGIN
				INSERT INTO ClassicalVoucherRedemptionCount (MemberId,VoucherId,LastRedemptionDate,TrxId,DeviceId)
				SELECT DISTINCT @MemberId MemberId,ucv.TrxVoucherId VoucherId,getdate() LastRedemptionDate,@TrxId TrxId,@DeviceId DeviceId
				FROM #UsedClassicalVoucher ucv 
				LEFT JOIN ClassicalVoucherRedemptionCount cvr on ucv.TrxVoucherId=cvr.VoucherId AND cvr.trxid=@Trxid and cvr.MemberId=@MemberId
				WHERE cvr.VoucherId is null
			END
			ELSE
			BEGIN
				INSERT INTO ClassicalVoucherRedemptionCount (MemberId,VoucherId,LastRedemptionDate,TrxId,DeviceId)
				SELECT DISTINCT NULL MemberId,ucv.TrxVoucherId VoucherId,getdate() LastRedemptionDate,@TrxId TrxId,@DeviceId DeviceId
				FROM #UsedClassicalVoucher ucv 
				LEFT JOIN ClassicalVoucherRedemptionCount cvr on ucv.TrxVoucherId=cvr.VoucherId AND cvr.TrxId=@Trxid 
				WHERE cvr.VoucherId is null
			END
		END
		-- Return used vouchers for verification/debugging
		
	END
	----NEED THIS ONLY WHEN Point Promotion SP / Apply Stamp SP is not in Use
	--DECLARE @DefaultVoucher NVARCHAR(25)
	----SET @DefaultVoucher = 'IMMEDIATE' --<<TODO>> SELECT  [Value] FROM ClientConfig  Where [Key] = 'StampcardDefaultVoucher' AND ClientId =1
	--SELECT @DefaultVoucher = [Value] FROM ClientConfig  Where [Key] = 'StampcardDefaultVoucher' AND ClientId =@ClientId

	--DROP TABLE IF EXISTS #TrxDetailData
	--CREATE TABLE #TrxDetailData(TrxId INT,TrxDetailId INT)
	
	--INSERT INTO #TrxDetailData (TrxId,TrxDetailId)
	--SELECT TrxId,TrxDetailId FROM TrxDetail  with(nolock) Where TrxId = @TrxId
	
	--DROP TABLE IF EXISTS #TrxVoucherdetailData
	--CREATE TABLE #TrxVoucherdetailData(TrxDetailId INT ,TrxVoucherId NVARCHAR(30) collate SQL_Latin1_General_CP1_CI_AS,PromotionId INT,TrxVoucherDetailId INT)

	--INSERT INTO #TrxVoucherdetailData(TrxDetailId ,TrxVoucherId,TrxVoucherdetailId) 
	--SELECT tv.TrxDetailId ,tv.TrxVoucherId ,tv.Id
	--FROM TrxVoucherdetail tv  with(nolock)
	--INNER JOIN #TrxDetailData td ON tv.TrxDetailId  = td.TrxDetailID 
	
	--IF EXISTS (SELECT 1 FROM #TrxVoucherdetailData)
	--BEGIN
	--	DECLARE @EDeviceStatusIdActive INT
	--	--SET @EDeviceStatusIdActive = 2 --<<TODO>>  select  DeviceStatusId from DeviceStatus  where Name='Active' and ClientId=1
	--	select @EDeviceStatusIdActive= DeviceStatusId from DeviceStatus  where Name='Active' and ClientId=@ClientId

	--	select DISTINCT ISNULL(d.Id,0) AS DeviceId,ISNULL(vdpt.ClassicalVoucher,0) ClassicalVoucher
	--	INTO #VouchersUsed 
	--	from #TrxVoucherdetailData tv 
	--	inner join #TrxDetailData td on tv.trxdetailid  = td.trxdetailid 
	--	inner join Device d WITH(NOLOCK) on tv.TrxVoucherId = d.DeviceId --collate database_default
	--	inner join DeviceProfile dp WITH(NOLOCK) on d.id=dp.DeviceId 
	--	inner join VoucherDeviceProfileTemplate vdpt WITH(NOLOCK) on dp.DeviceProfileId = vdpt.Id
	--	where tv.TrxVoucherId NOT LIKE (@DefaultVoucher+'%') AND d.DeviceStatusId = @EDeviceStatusIdActive

	--	IF EXISTS (SELECT 1 FROM #VouchersUsed Where ISNULL(DeviceId,0) > 0 AND ClassicalVoucher = 0)
	--	BEGIN
	--		DECLARE @EDeviceStatusIdInactive INT,@EProfileStatusIdInactive INT
	--		--SET @EDeviceStatusIdInactive= 1 --<<TODO>>  select  DeviceStatusId from DeviceStatus  where Name='Inactive' and ClientId=1
	--		select @EDeviceStatusIdInactive= DeviceStatusId from DeviceStatus  where Name='Inactive' and ClientId=@ClientId
	--		--SET @EProfileStatusIdInactive= 4 --<<TODO>>  select DeviceProfileStatusId from DeviceProfileStatus  where Name='Inactive' and ClientId=1
	--		select @EProfileStatusIdInactive= DeviceProfileStatusId from DeviceProfileStatus  where Name='Inactive' and ClientId=@ClientId
		
	--		UPDATE D set DeviceStatusId = @EDeviceStatusIdInactive
	--		FROM Device D INNER JOIN #vouchersUsed ud on D.Id = ud.DeviceId
	--		Where ISNULL(ud.DeviceId,0) > 0 AND ClassicalVoucher = 0

	--		UPDATE D set StatusId = @EProfileStatusIdInactive
	--		FROM DeviceProfile D INNER JOIN #vouchersUsed ud on D.DeviceId = ud.DeviceId
	--		Where ISNULL(ud.DeviceId,0) > 0 AND ClassicalVoucher = 0

	--	END
	--END

END
