
create Procedure [dbo].[BWS_CreateDevicesFromPool] (@NoOfDevices INT, @ClientID INT, @Reference  nvarchar (100), @DeviceProfileId INT, @DeviceLotID INT) as 

/*
Created by Anish and Niall - 2015-03-20 to create GIFTCARDS from the DEVICE NUMBER POOL

--you MUST update the pool first by run the SP called 
bws_CreateNumbersForDeviceNumberGeneratorTemplate

NOTE THAT THE 
@DEVICEPROFILEID is hardcoded 
@CLIENTID is LuS = 3
@NoOfDEVICES can be set


*/

BEGIN

	DECLARE @DeviceID INT
	--@NoOfDevices INT = 9000, @ClientID int=1, 
	Declare @DeviceProfileStatusIDCreated INT
	select @DeviceProfileStatusIDCreated = DeviceProfileStatusID from deviceprofilestatus where clientid = @Clientid and [Name]='Active'
	Declare @Reference_Name NVarchar(100)
print 'Starting...'
	--DECLARE @DeviceProfileId INT = 2167 ----- needs to be passed as a parameter
	--DECLARE @Reference nvarchar(100) 
	
	DECLARE @SelectedDeviceNumber VARCHAR(25);
	DECLARE @SelectedDeviceNumberId INT;
	DECLARE @ParentSiteId int ;
	select top 1 @ParentSiteId= siteid from site where clientid = @Clientid and Parentid=Siteid

	DECLARE @InitialDeviceStatusId int ; 
	select @InitialDeviceStatusId = DeviceStatusID from devicestatus where clientid = @clientid and [Name]='Active'
	DECLARE @InitialDeviceTypeId int ;
	Select @InitialDeviceTypeId = DeviceTypeId from devicetype where clientid = @clientid and [Name]='CARD'
	DECLARE @InitialAccountStatusId int ;	
	select @InitialAccountStatusId = AccountStatusID from accountstatus where clientid = @clientid and [Name]='Enable'
	DECLARE @NewAccountId INT;

	DECLARE @VoucherStartDate DATETIME, @VoucherEndDate DATETIME;
	SELECT @VoucherStartDate = StartDate, @VoucherEndDate = ExpiryDate FROM DeviceLot
	where ID = @DeviceLotID;

	Select @Reference_Name = [NAME] from DevicePRofileTemplate where ID = @DeviceProfileId
	
	

	DECLARE @ID int
	DECLARE IDs CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR 
	SELECT TOP (@NoOfDevices) Id, DeviceNumber 
	FROM dbo.DeviceNumberPool where DeviceNumber not in (select DeviceID from Device) and Reference=@Reference
	

	OPEN IDs
	FETCH NEXT FROM IDs INTO @SelectedDeviceNumberId, @SelectedDeviceNumber
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRAN
		INSERT INTO Account (AccountStatusTypeId, MonetaryBalance, PointsBalance, CreateDate) 
		VALUES (@InitialAccountStatusId, 0, 0, GETDATE())
		SELECT @NewAccountId = SCOPE_IDENTITY()
		

		INSERT INTO Device (DeviceId, DeviceLotID,Reference, StartDate, ExpirationDate, DeviceStatusId, DeviceTypeId, UserId, HomeSiteId, CreateDate, DeviceNumberPoolId, AccountId, Pin)  
		VALUES (@SelectedDeviceNumber,@DeviceLotID,@Reference_Name, @VoucherStartDate, @VoucherEndDate, @InitialDeviceStatusId, @InitialDeviceTypeId, null, @ParentSiteId, GETDATE(), @SelectedDeviceNumberId, @NewAccountId,FLOOR( 1000 + ( RAND(CAST( NEWID() AS varbinary )) *8999 ) ))
		Select @DeviceID = SCOPE_IDENTITY()
		
		
		
		INSERT INTO [DeviceProfile] ([Version],[StatusId],[DeviceId],[DeviceProfileId])
		VALUES (0,@DeviceProfileStatusIDCreated,@DeviceID,@DeviceProfileId)
		
		print @SelectedDeviceNumber
	
		COMMIT TRAN
		
		FETCH NEXT FROM IDs INTO @SelectedDeviceNumberId, @SelectedDeviceNumber
	END

	CLOSE IDs
	DEALLOCATE IDs


END
