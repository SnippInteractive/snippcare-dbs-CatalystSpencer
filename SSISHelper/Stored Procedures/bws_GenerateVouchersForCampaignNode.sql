
Create PROCEDURE [SSISHelper].[bws_GenerateVouchersForCampaignNode]
	
	@CampaignActionId INT, 	@Result INT OUTPUT

AS
BEGIN

	--If the Job Detail line is for a VOUCHER, then add the voucher export fields (if they do not already exist)
	update CatalystMail_CampaignJobdetails  set fieldlist = convert(nvarchar(400),fieldlist) + convert(nvarchar(40),',voucher code,voucher name') 
	where jobdetailid in (
	select jobdetailid 
	from CatalystMail_CampaignJobHeader h
	join CatalystMail_CampaignJobdetails  d on h.JobId=d.JobId
	where ActionType = 'AssignVoucher'
	and fieldlist not like '%voucher code%')

	BEGIN TRY

	DECLARE @ClientId INT, @DeviceStatusActiveId INT,@DeviceProfileStatusActiveId INT

	--Get the CLIENT id of the Vouchers to be created.
	select @ClientId=clientid from CatalystMail_CampaignJobHeader h join CatalystMail_CampaignJobdetails  d on h.JobId=d.JobId
	where ActionType = 'AssignVoucher' and actionid = @CampaignActionId

	select @DeviceStatusActiveId = DeviceStatusId from DeviceStatus where ClientId = @ClientId AND Name = 'Active';
	select @DeviceProfileStatusActiveId = DeviceProfileStatusId from DeviceProfileStatus where ClientId = @ClientId AND Name = 'Active';
	
	DECLARE @VoucherCount INT,@DeviceNumberGeneratorTemplateId INT, @NodeId INT
	DECLARE @VoucherExpiryDateString NVARCHAR(MAX),@VoucherExpiryDate DATE,@VoucherExpiryDateTime DateTime,@VoucherStartDate DATE,@VoucherStartDateString NVARCHAR(MAX)
	
	DECLARE @UseProfileExpiry INT=0,@NumberDaysUntilExpire INT=0,@DeviceProfileTemplateIdString varchar(10),@DeviceProfileTemplateId INT
	DECLARE @DeviceProfileStatusActive INT,@IDofDevice INT	,@DeviceProfileTemplateName nVarChar(1000)
	DECLARE @ContactHistoryCount INT=0, @ContactTypeID INT=0

	DECLARE @BatchUserId INT
	DECLARE @DeviceLotStatusId INT,@DeviceStatusId INT,@DeviceLotId INT

	SELECT @BatchUserId = UserId FROM [User] WHERE SiteId IN (Select SiteId From [Site] Where ClientId = @ClientID) AND Username = 'batchprocessadmin'
	SELECT @DeviceLotStatusId = Id From [DeviceLotStatus] WHERE ClientId = @ClientId and Name = 'NumbersAssigned'
	SELECT @DeviceStatusId = DeviceStatusId FROM DeviceStatus WHERE ClientId = @ClientId and Name = 'Created'
	SELECT @DeviceProfileStatusActive = DeviceProfileStatusID from deviceprofilestatus 
	where name = 'Active' and clientid = @Clientid
	--Get which NODE is used for this ActionID
	SELECT @NodeId = FilterParentId FROM CatalystMail_Action WHERE Id = @CampaignActionId
	SELECT @VoucherCount = Count(*) FROM CatalystMail_SelMembers WHERE NodeId = @NodeId
	SELECT @ContactTypeID = [ContactTypeId] FROM [ContactType] where clientid = @ClientId and [Name] = 'Mail'
	
	/*Get all the information for the DEVICELOT Creation*/
	select @DeviceProfileTemplateIdString = f.ValuesJSON from CatalystMail_Action a 
	inner join CatalystMail_ActionsFields af on a.Id=af.ActionId
	inner join CatalystMail_Field f on f.Id=af.FilterId 
	where f.Name='VoucherProfiles' and a.Id=@CampaignActionId
	
	select @DeviceProfileTemplateId = CONVERT(int,REPLACE(REPLACE(REPLACE(@DeviceProfileTemplateIdString, '[',''), ']',''), '"',''))
	
	SELECT @DeviceNumberGeneratorTemplateId = DeviceNumberGeneratorTemplateId, @DeviceProfileTemplateName = Name  
	FROM DeviceProfileTemplate WHERE Id = @DeviceProfileTemplateId

	SELECT @VoucherExpiryDateString = ValuesJSON FROM CatalystMail_Field AS CMF 
	INNER JOIN CatalystMail_ActionsFields AS CMAF ON CMF.Id = CMAF.FilterId 
	WHERE CMAF.ActionId = @CampaignActionId AND CMF.Name = 'Date'
	SELECT @VoucherExpiryDate = CONVERT(DATETIME,REPLACE(REPLACE(@VoucherExpiryDateString, '["',''), '"]',''),103)
	
	SELECT @VoucherStartDateString = ValuesJSON FROM CatalystMail_Field AS CMF 
	INNER JOIN CatalystMail_ActionsFields AS CMAF ON CMF.Id = CMAF.FilterId 
	WHERE CMAF.ActionId = @CampaignActionId AND CMF.Name = 'StartDate'
	SELECT @VoucherStartDate = CONVERT(DATETIME,REPLACE(REPLACE(@VoucherStartDateString, '["',''), '"]',''),103)

	-- Check if we use the VoucherExpiryPolicy
	SELECT @UseProfileExpiry = UseProfileExpiry from catalystmail_action where id=@CampaignActionId
	if @UseProfileExpiry = 1
	BEGIN
		SELECT @NumberDaysUntilExpire = numberdaysuntilexpire  
		FROM [DeviceProfileTemplate] dpt 
		JOIN  DeviceExpirationPolicy dep on dep.id = dpt.ExpirationPolicyid
		where dpt.id =@DeviceProfileTemplateId
		SELECT @VoucherExpiryDate = dateadd(d,@NumberDaysUntilExpire,@VoucherStartDate)
	END
	Select @VoucherExpiryDateTime = @VoucherExpiryDate
	Select @VoucherExpiryDateTime = dateadd(ss,-1,dateadd(dd,1,@VoucherExpiryDateTime))
	
	--Check that voucher count is greater than 0
	--Check if a lot already exists with the specified NodeId if it does throw an error
	IF(((SELECT COUNT (*) FROM DeviceLot WHERE Reference = cast(@NodeId as nvarchar(40)) ) > 0) OR (@VoucherCount = 0))
	BEGIN
		IF(@VoucherCount = 0)
			BEGIN
			RAISERROR ('Voucher Count Is Zero, voucher count must be greater than 0, no vouchers to assign', 0, 1 )
			Select -1 As Result, 'Voucher Count Is Zero,No User found to assign voucher' AS [Message]
		END
		ELSE
		BEGIN
			RAISERROR ('Vouchers Already Assigned', 0, 1 )
			Select -1 As Result, 'Vouchers Already Assigned' AS [Message]
		END		
	END
	ELSE
	BEGIN
		-- Create New Lot, Link to profile template And Assign All devices
		print 'DeviceLot Update - '
		INSERT INTO DeviceLot (
		[Version],[Created],[Updated],[CreatedBy],[UpdatedBy],[StatusId],
		[NumberOfDevices],[StartDate],[InitialCashBalance],[Name],[Reference],[InitialPointsBalance],[DeviceStatusID],[ExpiryDate])
		VALUES
		(0,GETDATE(),GETDATE(),@BatchUserId,@BatchUserId,@DeviceLotStatusId,@VoucherCount,@VoucherStartDate,0,
		'Campaign Voucher ' +  cast(@NodeId as nvarchar(5)) , @CampaignActionId, 0,@DeviceStatusId,@VoucherExpiryDateTime)
		SELECT @DeviceLotId = SCOPE_IDENTITY()
		print 'DeviceLotDevicePRofile Update - '
		INSERT INTO [DeviceLotDeviceProfile] ([Version],[DeviceLotId],[DeviceProfileId]) 
		VALUES(0,@DeviceLotId,@DeviceProfileTemplateId)	

		exec [dbo].[bws_CreateDevices] @Clientid,@DeviceLotId,0
		IF OBJECT_ID('tempdb.dbo.#toUpdate', 'U') IS NOT NULL
		DROP TABLE #toUpdate 
		select memberid, deviceid into #toUpdate from ( 
		SELECT [MemberID],ROW_NUMBER() OVER(ORDER BY memberid) AS RN 
		FROM [CatalystMail_SelMembers] where nodeid = @NodeId) m
		join (select deviceid,  ROW_NUMBER() OVER(ORDER BY userid) AS RN   
		from  device where devicelotid = @DeviceLotId)
		d on m.RN=d.rn

		update dv set dv.userid = u.memberid, dv.DeviceStatusId=@DeviceStatusActiveId from Device dv join #toUpdate u on dv.deviceid=u.deviceid
		Update dp set dp.statusid = @DeviceProfileStatusActiveId 
		from deviceprofile dp join device dv on dv.id=dp.deviceid join #toUpdate u  on dv.deviceid=u.deviceid 
		IF OBJECT_ID('tempdb.dbo.#toUpdate', 'U') IS NOT NULL
		DROP TABLE #toUpdate 
	
		update DEVICE set reference = @DeviceProfileTemplateName, extrainfo = @DeviceProfileTemplateName  
		where devicelotid = @DeviceLotId
		Select 1 As Result, 'Vouchers Assigned' AS [Message]
	END
	
	END TRY
	BEGIN CATCH
		PRINT(ERROR_MESSAGE())	
		Select -1 As Result, ERROR_MESSAGE() AS [Message]
	END CATCH
END
