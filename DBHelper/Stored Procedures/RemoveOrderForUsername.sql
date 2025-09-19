CREATE Procedure [DBHelper].[RemoveOrderForUsername] ( @emailAddress nvarchar(50))
as
--declare @Deviceid nvarchar(25)DBHelper.ResetDevice ='0338965446634153'
begin


declare @userid int

select @userid = userid from [user] where username = @emailAddress

select distinct th.trxid into #TrxToDelete from trxheader th 
join trxdetail td on th.trxid=td.trxid
join trxtype tt on th.TrxTypeId=tt.trxtypeid where deviceid in (
select deviceid from device where userid = @userid) --and tt.name = 'RedeemPoints'


delete from trxpayment where trxid in (select trxid from #TrxToDelete)
delete from trxdetail where trxid in (select trxid from #TrxToDelete)
delete from trxheader where trxid in (select trxid from #TrxToDelete)

end