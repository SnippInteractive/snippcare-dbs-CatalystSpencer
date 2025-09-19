CREATE Procedure [DBHelper].[RemoveAllTrxForUsername] ( @emailAddress nvarchar(50))
as
--declare @Deviceid nvarchar(25)DBHelper.ResetDevice ='0338965446634153'
begin

	declare @userid int =0
	select @userid = userid from [user] where username = @emailAddress
	
	if @userid !=0
	Begin 
		select distinct th.trxid into #TrxToDelete from trxheader th 
		join trxdetail td on th.trxid=td.trxid
		join trxtype tt on th.TrxTypeId=tt.trxtypeid where deviceid in (
		select deviceid from device where userid = @userid) --and tt.name = 'RedeemPoints'

		delete from trxpayment where trxid in (select trxid from #TrxToDelete)
		 delete from TrxDetailPromotion where TrxDetailId in (Select TrxDetailId from trxdetail where trxid in (select trxid from #TrxToDelete))
		  delete from TrxDetailItemProperties where TrxDetailId in (Select TrxDetailId from trxdetail where trxid in (select trxid from #TrxToDelete))
		delete from trxdetail where trxid in (select trxid from #TrxToDelete)
		delete from trxheader where trxid in (select trxid from #TrxToDelete)

		update account set  PointsBalance=0, MonetaryBalance=0 where userid =@userid
		Insert into Audit (Version,UserId,FieldName,OldValue,NewValue,ChangeDate,ChangeBy,Reason) values(0,@userId,'AccountBalance','','',GETDATE(),0,'update account from SP-RemoveAllTrxFRomUsername')
	end
end
