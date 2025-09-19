CREATE procedure SSISHelper.VoucherExpiration  as 
/*
If a voucher is to expire due to date and it is Active, EXPIRE it after putting a records into the DEVICEStatusHistory (Audit) table
Written by Niall >> 2023-05-11


*/
Begin
	Declare @clientid int
	select @clientid = clientid from client where name = 'Spencer'
	drop table if exists #DevicesToExpire
	select dpt.name, dv.deviceid, dv.ExpirationDate, dv.userid,dv.DeviceStatusId, dv.HomeSiteId,dv.id IDOfDevice into #DevicesToExpire from device dv join devicelot dl on dl.id=
	dv.devicelotid join devicelotdeviceprofile dldp on dl.id=dldp.DeviceLotId
	join deviceprofiletemplate dpt on dpt.id = dldp.DeviceProfileId
	join deviceprofiletemplatetype dptt on dpt.deviceprofiletemplatetypeid =dptt.id 
	join devicestatus ds on dv.devicestatusid=ds.devicestatusid
	join site s on s.siteid = dv.homesiteid
	where dptt.name = 'Voucher' and expirationdate < getUTCdate() 
	and s.clientid = @clientid and ds.name = 'Active' order by expirationdate 

	Declare @devicestatus_Expired int, @DeviceAction_ExpireDevice int
	select @devicestatus_Expired = devicestatusid from devicestatus ds where name = 'Expired' and clientid = @clientid
	select DeviceActionid from DeviceAction where name = 'ExpireDevice' and clientid = @clientid

	INSERT INTO [dbo].[DeviceStatusHistory]
	([Version],[DeviceId],[DeviceStatusId],[ChangeDate],[Reason],[DeviceStatusTransitionType],[ExtraInfo],[UserId]
	,[ActionId],[DeviceTypeResult],[ActionResult],[ActionDetail],[OldValue],[NewValue],[SiteId],[Processed],[DeviceIdentity]
	,[OpId],[TerminalId])
	select 1, Deviceid,@devicestatus_Expired,GetUTCDate(),'Expirataion Due to Date', @DeviceAction_ExpireDevice, 'Expiry', userid,
	@DeviceAction_ExpireDevice,'Voucher',@devicestatus_Expired, 'SSISHelper.VoucherExpiration','Active','Expired',HomeSiteId,0,IDOfDevice,'','Batch Process'
	from #DevicesToExpire

	Update DV set dv.devicestatusid = @devicestatus_Expired from device dv join #DevicesToExpire dte on dv.deviceid=dte.deviceid
	drop table if exists #DevicesToExpire
End