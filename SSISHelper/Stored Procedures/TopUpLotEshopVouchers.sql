
Create Procedure [SSISHelper].[TopUpLotEshopVouchers] as 

Begin
/*
This is NON STANDARD and for Spencer only as they want VOUCHER Lots topped up. DO NOT do this for other clients!!!!
Written By Niall - 2023-05-17
Note - Only two specific lots will be topped up 1082 and 1084 for Tees and Jewellery, if there are different ones they need to be added here!!!
**** This needs to get the info from Catalyst, but that will require front end changes *****

*/


	Declare @AmountOfDev int,@DeviceLotID int, @Clientid int

	Declare db_cursor cursor for 
		SELECT count(dv.id) Devices,max(dv.devicelotid) DeviceLot,DPTT.ClientId
		FROM DeviceProfileTemplateTYPE DPTT 
		JOIN DeviceProfileTemplate DPT ON DPT.DeviceProfileTemplateTypeId = DPTT.ID
		join DeviceLotDeviceProfile dldp on dldp.DeviceProfileId=dpt.Id
		join device dv on dv.devicelotid=dldp.DeviceLotId
		WHERE (DPTT.Name = 'Voucher')
		AND dv.userid is null and dv.ExtraInfo is null and dv.DeviceLotId in (1082,1084)
		group by DPT.Id,DPTT.Name,DPTT.ClientId, dpt.Description
		having count(dv.Id) < 100000 

	
	OPEN db_cursor  
	FETCH NEXT FROM db_cursor INTO @AmountOfDev  , @DeviceLotID, @Clientid

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		Update devicelot set numberofdevices = numberofdevices + 500000 where id = @devicelotid --Add 500K to the Lot
		exec bws_CreateDevices @clientid, @devicelotid	,0 --Top up this bad boy!
		FETCH NEXT FROM db_cursor INTO @AmountOfDev  , @DeviceLotID, @Clientid
		END 

	CLOSE db_cursor  
	DEALLOCATE db_cursor 

end