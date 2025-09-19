-- =============================================
-- Author:		BINU JACOB SCARIA
-- Create date: 28-11-2023
-- Description:	Get Available Vouchers For Member
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_GetAvailableVouchersForMember]
	-- Add the parameters for the stored procedure here
	(@MemberId INT,
	 @SiteRef NVARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
	
	DROP TABLE IF EXISTS #AvailableVouchers
	CREATE TABLE #AvailableVouchers(ExpirationDate Datetime2, Id NVARCHAR(25),MemberId INT,Description NVARCHAR(500),Name NVARCHAR(100),ClassicalVoucher bit,
	ProductCode NVARCHAR(50),SpendRequired DECIMAL(18,2),VoucherSubType NVARCHAR(25),VoucherType NVARCHAR(25),VoucherValue DECIMAL(18,2),Status NVARCHAR(25),MisCode nvarchar(50))

	IF ISNULL(@SiteRef,'') = 'ecomm'
	BEGIN
		INSERT INTO #AvailableVouchers(ExpirationDate, Id,MemberId,Description,Name,ClassicalVoucher,ProductCode,SpendRequired,VoucherSubType,VoucherType,VoucherValue,Status,MisCode)
		(select D.ExpirationDate,D.DeviceId Id,	D.UserId MemberId,dpt.Description,dpt.Name Name,vdpt.ClassicalVoucher,''ProductCode,ISNULL(vdpt.SpendRequired,0)SpendRequired,
		Vs.Name  VoucherSubType,'' VoucherType,vdpt.OfferValue VoucherValue,DS.Name Status,vdpt.MisCode
		FROM Device AS d 
		INNER JOIN DeviceProfile AS dp ON d.Id = dp.DeviceId 
		INNER JOIN DeviceProfileTemplate AS dpt ON dpt.Id = dp.DeviceProfileId 
		INNER JOIN VoucherDeviceProfileTemplate vdpt  on  dpt.Id = vdpt.Id  
		INNER JOIN VoucherSubType vs on vdpt.VoucherSubTypeId =  vs.VoucherSubTypeId
		INNER JOIN DeviceProfileTemplateType AS dptt ON dptt.Id = dpt.DeviceProfileTemplateTypeId --
		INNER JOIN DeviceStatus ds on D.DeviceStatusId = ds.DeviceStatusId --
		INNER JOIN DeviceProfileStatus dps on dp.StatusId = dps.DeviceProfileStatusId --
		where  D.UserId = @MemberId	and DS.Name = 'Active' and dps.Name = 'Active' and dptt.Name = 'Voucher' and D.StartDate <= getdate() and d.ExpirationDate >=getdate()
		and vdpt.DisplayInEcomm IS NOT NULL
		and vdpt.DisplayInEcomm = 1
		)
	END
	ELSE
	BEGIN
		INSERT INTO #AvailableVouchers(ExpirationDate, Id,MemberId,Description,Name,ClassicalVoucher,ProductCode,SpendRequired,VoucherSubType,VoucherType,VoucherValue,Status,MisCode)
		(select D.ExpirationDate,D.DeviceId Id,	D.UserId MemberId,dpt.Description,dpt.Name Name,vdpt.ClassicalVoucher,''ProductCode,ISNULL(vdpt.SpendRequired,0)SpendRequired,
		Vs.Name  VoucherSubType,'' VoucherType,vdpt.OfferValue VoucherValue,DS.Name Status,vdpt.MisCode
		FROM Device AS d 
		INNER JOIN DeviceProfile AS dp ON d.Id = dp.DeviceId 
		INNER JOIN DeviceProfileTemplate AS dpt ON dpt.Id = dp.DeviceProfileId 
		INNER JOIN VoucherDeviceProfileTemplate vdpt  on  dpt.Id = vdpt.Id  
		INNER JOIN VoucherSubType vs on vdpt.VoucherSubTypeId =  vs.VoucherSubTypeId
		INNER JOIN DeviceProfileTemplateType AS dptt ON dptt.Id = dpt.DeviceProfileTemplateTypeId --
		INNER JOIN DeviceStatus ds on D.DeviceStatusId = ds.DeviceStatusId --
		INNER JOIN DeviceProfileStatus dps on dp.StatusId = dps.DeviceProfileStatusId --
		where  D.UserId = @MemberId	and DS.Name = 'Active' and dps.Name = 'Active' and dptt.Name = 'Voucher' and D.StartDate <= getdate() and d.ExpirationDate >=getdate()
		and vdpt.DisplayInTill IS NOT NULL
		and vdpt.DisplayInTill = 1
		)
	END


	DECLARE @result NVARCHAR(max)

	SEt @result = (
	SELECT * FROM #AvailableVouchers
	FOR			JSON PATH,INCLUDE_NULL_VALUES)

	SELECT @result Result

	DROP TABLE IF EXISTS #AvailableVouchers
END
