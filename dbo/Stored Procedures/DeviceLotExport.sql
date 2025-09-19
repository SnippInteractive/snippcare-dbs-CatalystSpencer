CREATE Procedure [dbo].[DeviceLotExport] (@DeviceLotID int) as

	
	--select dl.LotSequenceNo InternalID, dl.DeviceID, StartDate,ExpirationDate [ExpiryDate],  isnull(Pin,'') Pin,''  Voucher from  device dl	
	-- where dl.devicelotid = @DeviceLotID

	declare @profileType varchar(50);

	select @profileType = dptt.Name from DeviceLot dl 
	inner join deviceLotdeviceprofile dlp	  on dl.Id= dlp.DeviceLotId 
	inner join DEviceProfileTEmplate dpt	  on dpt.Id= dlp.DEviceProfileId 
	inner join DEviceProfileTEmplateType dptt on dptt.Id= dpt.DEviceProfileTEmplateTypeId
	where dl.Id=@DeviceLotID;
	-- IF Loyalty lot export vouchers associated with loyalty device
	IF (@profileType = 'Loyalty')
	begin
		select dl.id InternalID, dl.DeviceID, StartDate,ExpirationDate [ExpiryDate],  isnull(Pin,'') Pin,''  Voucher from  device dl	
		where dl.devicelotid = @DeviceLotID order by dl.id 
	end
	-- in  case of voucher export show voucher device id in both Voucher column and DEviceId column
	ELSE IF (@profileType = 'Voucher')
	BEGIN

	    /* 
			Checking whether the given lotId is there in the VoucherProfile and if it is there,
			check whether the EnterCode is true.If it is , fetch devices from VoucherCodes table.
		*/
		DECLARE		@LotIsInVoucherProfile BIT = 0,@EnterCode BIT = null

		SELECT		@LotIsInVoucherProfile = CASE WHEN ISNULL(dldp.DeviceLotId,0) > 0 THEN 1 ELSE 0 END,
					@EnterCode = vdpt.EnterCode

		FROM		DeviceLotDeviceProfile dldp
		INNER JOIN	VoucherDeviceProfileTemplate vdpt
		ON			dldp.DeviceProfileId = vdpt.Id
		WHERE		DeviceLotId = @DeviceLotID

		IF @LotIsInVoucherProfile = 1 AND @EnterCode = 1
		BEGIN
			SELECT  ROW_NUMBER() OVER (ORDER BY dl.DeviceId) AS InternalID, dl.DeviceID, NULL AS StartDate,CAST(ExpirationDate AS DATETIME2) [ExpiryDate],  isnull(Value,'') Pin,dl.DeviceId Voucher 
			FROM	VoucherCodes dl	
			WHERE	dl.devicelotid = @DeviceLotID 
		END
		ELSE
		BEGIN
			SELECT	dl.id InternalID, dl.DeviceID, StartDate,ExpirationDate [ExpiryDate],  isnull(Pin,'') Pin,dl.DeviceId Voucher from  device dl	
			WHERE	dl.devicelotid = @DeviceLotID order by dl.id 
		END
		

	END
	ELSE
	BEGIN
		select dl.LotSequenceNo InternalID, dl.DeviceID, StartDate,ExpirationDate [ExpiryDate],  isnull(Pin,'') Pin,''  Voucher from  device dl	
		where dl.devicelotid = @DeviceLotID order by dl.id 
	END
