
CREATE Procedure [SSISHelper].[TopUpLotEshopLoyalty] as 

Begin



	Declare @AmountOfDev int,@DeviceLotID int, @Clientid int

	Declare db_cursor cursor for 
		SELECT count(dv.id) Devices,max(dv.devicelotid) DeviceLot,DPTT.ClientId
		FROM DeviceProfileTemplateTYPE DPTT 
		JOIN DeviceProfileTemplate DPT ON DPT.DeviceProfileTemplateTypeId = DPTT.ID
		join DeviceLotDeviceProfile dldp on dldp.DeviceProfileId=dpt.Id
		join device dv on dv.devicelotid=dldp.DeviceLotId
		WHERE (DPTT.Name = 'Loyalty')
		AND dv.userid is null and dv.ExtraInfo is null
		group by DPT.Id,DPTT.Name,DPTT.ClientId, dpt.Description
		having count(dv.Id) < 100000

	
	OPEN db_cursor  
	FETCH NEXT FROM db_cursor INTO @AmountOfDev  , @DeviceLotID, @Clientid

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		Update devicelot set numberofdevices = numberofdevices + 500000 where id = @devicelotid
		exec bws_CreateDevices @clientid, @devicelotid	,0
		FETCH NEXT FROM db_cursor INTO @AmountOfDev  , @DeviceLotID, @Clientid
		END 

	CLOSE db_cursor  
	DEALLOCATE db_cursor 

end