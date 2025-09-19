CREATE Procedure [DBHelper].[ResetDevice] ( @Deviceid nvarchar(25))
as
--declare @Deviceid nvarchar(25)DBHelper.ResetDevice ='0338965446634153'
begin
	declare @shouldbeone  int = 0, @userid int=0
	if object_id('tempdb..#DeviceToUpdate') is not null     drop table #DeviceToUpdate
	select dv.id, dv.deviceid, dv.accountid,dv.UserId into #DeviceToUpdate from device  dv join deviceprofile dp on dv.id=dp.deviceid where dv.deviceid = @deviceid
	select @shouldbeone = count(*) from #DeviceToUpdate 
	if @shouldbeone = 1
	Begin
		select @userid = userid from #DeviceToUpdate
		delete from DeviceStatusHistory where deviceid = @deviceid
		delete from trxdetail where trxid in (select trxid from trxheader where deviceid = @deviceid)
		delete from trxpayment where trxid in (select trxid from trxheader where deviceid = @deviceid)
		delete from trxheader where trxid in (select trxid from trxheader where deviceid = @deviceid)

		update account set userid = null, pointsbalance=0, MonetaryBalance=0 where accountid in (select accountid from #DeviceToUpdate)
		update device set devicestatusid = 2, userid = null where id in (select id from #DeviceToUpdate)
		update deviceprofile set statusid = 2 where deviceid in (select id from #DeviceToUpdate)
		Insert into Audit (Version,UserId,FieldName,OldValue,NewValue,ChangeDate,ChangeBy,Reason) values(0,@userId,'AccountBalance','','',GETDATE(),0,'update account from SP-ResetDevice')
	End
end





