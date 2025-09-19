
-- =============================================
-- Author:		BINU
-- Create date: 26-06-2025
-- Description:	Classical Voucher Maximum Redemption Check
-- =============================================
CREATE PROCEDURE [dbo].[Epos_CheckClassicalVoucherUsage]
	-- Add the parameters for the stored procedure here
	@LoyaltyDevice varchar(50),
	@Voucher varchar(50),
	@MemberId INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Resolve MemberId from LoyaltyDevice if not already provided
	IF ISNULL(@MemberId, 0) = 0
	BEGIN
		SELECT @MemberId = UserId
		FROM Device
		WHERE DeviceId = @LoyaltyDevice;
	END

	-- Initialize variables
	DECLARE 
		@MaximumVoucherUsage INT,
		@MaximumUserUsage INT,
		@UsedVoucherCount INT,
		@UsedUserVoucherCount INT,
		@ClassicalVoucher NVARCHAR(50),
		@Result INT = 1;

	-- Fetch voucher details
	SELECT TOP 1 
		@MaximumUserUsage = ISNULL(vdp.MaximumUsage, 0),
		@MaximumVoucherUsage = ISNULL(vdp.MaximumVoucherUsage, 0),
		@ClassicalVoucher = d.DeviceId
	FROM Device d
	JOIN DeviceLotDeviceProfile dldp ON d.DeviceLotId = dldp.DeviceLotId
	JOIN DeviceProfileTemplate dpt ON dldp.DeviceProfileId = dpt.Id
	JOIN DeviceProfileTemplatetype dpty ON dpt.DeviceProfileTemplatetypeId = dpty.Id
	JOIN VoucherDeviceProfileTemplate vdp ON dpt.Id = vdp.Id
	WHERE d.DeviceId = @Voucher AND dpty.Name = 'Voucher' AND vdp.ClassicalVoucher = 1;

	-- Proceed if a classical voucher was found
	IF ISNULL(@ClassicalVoucher, '') <> ''
	BEGIN
		-- Validate per-user usage
		IF @MaximumUserUsage > 0 AND ISNULL(@MemberId,0) > 0
		BEGIN

			SELECT @UsedUserVoucherCount = COUNT(Id)
			FROM ClassicalVoucherRedemptionCount
			WHERE VoucherId = @Voucher AND MemberId = @MemberId;

			IF @UsedUserVoucherCount >= @MaximumUserUsage
			BEGIN
				SET @Result = 2;
				PRINT 'Member'
			END
		END
		ELSE IF @MaximumUserUsage > 0 AND ISNULL(@LoyaltyDevice,'') <> ''
		BEGIN

			SELECT @UsedUserVoucherCount = COUNT(Id)
			FROM ClassicalVoucherRedemptionCount
			WHERE VoucherId = @Voucher AND DeviceId = @LoyaltyDevice;

			IF @UsedUserVoucherCount >= @MaximumUserUsage
			BEGIN
				SET @Result = 2;
				PRINT 'Device'
			END
		END

		-- Validate total usage, only if previous check passed
		IF @Result = 1 AND @MaximumVoucherUsage > 0
		BEGIN
			SELECT @UsedVoucherCount = COUNT(Id)
			FROM ClassicalVoucherRedemptionCount
			WHERE VoucherId = @Voucher;

			IF @UsedVoucherCount >= @MaximumVoucherUsage
			BEGIN
				PRINT 'MaxUsage'
				SET @Result = 2;
			END
		END
	END

	-- Output result
	SELECT @Result AS Result;

/*
    -- Insert statements for procedure here
	Declare @UserId INT
	SET @UserId=(select userid from device where deviceid=@LoyaltyDevice)
	Declare @MaxUsage INT
	SET @MaxUsage=(select top 1 isnull(MaximumUsage,0) from  
device d join deviceprofile dp on d.id=dp.deviceid 
join deviceprofiletemplate dpt on dp.deviceprofileid=dpt.id 
join deviceprofiletemplatetype dpty on dpt.deviceprofiletemplatetypeId=dpty.id
join voucherdeviceprofiletemplate vdp on dpt.id=vdp.id where dpty.name='Voucher' and d.DeviceId=@Voucher and vdp.ClassicalVoucher=1)

Declare @UsedVoucherCount INT
SET @UsedVoucherCount=(SELECT isnull(count(1),0)
  FROM [ClassicalVoucherRedemptionCount] where MemberId=@UserId and VoucherId=@Voucher)
	
	if(@UsedVoucherCount>=@MaxUsage AND @UsedVoucherCount>0)
	begin
	select 2 as Result -- failed
	end
	else
	begin
	select 1 as Result-- ok
	end
	*/
END

