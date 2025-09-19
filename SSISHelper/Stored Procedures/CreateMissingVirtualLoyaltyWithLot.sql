Create Procedure [SSISHelper].[CreateMissingVirtualLoyaltyWithLot] (@LevelToTopUpAt int, @NumberOfDevices int=0 ) 
as
Begin
	Declare @DevicesLeft int, @LastDeviceLotID  int, @NewDeviceLotID int, @ClientID int=4
	if @NumberOfDevices = 0
	begin
		set @NumberOfDevices = 250000
	end 
	select @DevicesLeft = 
	count(dp.id) , @LastDeviceLotID = max(dv.devicelotid)
	from deviceprofiletemplate dpt
	join DeviceLotDeviceProfile dldp on dpt.Id=dldp.DeviceProfileId
	join DeviceLot dl on dl.Id=dldp.DeviceLotId
	join DeviceProfile dp on dp.DeviceProfileId=dldp.DeviceProfileId
	join DeviceProfileStatus dps on dps.DeviceProfileStatusId=dp.StatusId
	join Device dv on dv.Id=dp.DeviceId
	join DeviceStatus ds on ds.DeviceStatusId=dv.DeviceStatusId
	where dpt.[Name] ='Loyalty' and ds.Name='Active' and dps.Name='Active'
	group by dps.Name, ds.name,dpt.[Name]
	--select @DevicesLeft
	if @DevicesLeft < @LevelToTopUpAt  --check if we need to top up
	Begin
		--Get the last devicelot and copy it to a new one (set the status of the devicelot properly)
		--Add a record into the devicelotdeviceprofile table
	
		INSERT INTO [dbo].[DeviceLot]
		([Version],[Created],[Updated],[CreatedBy],[UpdatedBy],[StatusId],[NumberOfDevices],[StartDate],[InitialCashBalance]
		,[Name],[Reference],[InitialPointsBalance],[ExpiryDate],[DevicesAssigned],[DeviceStatusId])
		select [Version],GetDate(),GetDate(),[CreatedBy],[UpdatedBy],[StatusId],@NumberOfDevices,GetDate(),[InitialCashBalance]
		,[Name],[Reference],[InitialPointsBalance],DateAdd(Year,10,GetDate()),0,[DeviceStatusId] from devicelot where id = @LastDeviceLotID
		set @NewDeviceLotID = Scope_identity()
		INSERT INTO [dbo].[DeviceLotDeviceProfile]
			   ([Version],[DeviceLotId],[DeviceProfileId])
		select 1,@NewDeviceLotID,[DeviceProfileId] from devicelotdeviceprofile where devicelotid = @LastDeviceLotID
	
		exec bws_CreateDevices @clientid,@NewDeviceLotID,0
		
	End

end


	
