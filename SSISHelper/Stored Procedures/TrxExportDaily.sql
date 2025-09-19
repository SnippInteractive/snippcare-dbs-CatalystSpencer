

CREATE Procedure [SSISHelper].[TrxExportDaily] as 

Begin

select userid into #TestUsers from segmentadmin sa join segmentusers su on sa.segmentid=su.segmentid where name = 'Test_Users'

Declare @DatePart nvarchar(8), @EndOfDayYesterday datetime
select @EndOfDayYesterday = convert(datetime,CONVERT(date,Getdate()))
select @DatePart = CONVERT(nvarchar(8),@EndOfDayYesterday,112)

Drop table if exists #TrxToGo
select distinct th.trxid into #TrxToGo from trxheader th join trxtype tt on tt.trxtypeid=th.trxtypeid
join trxdetail td on th.trxid=td.trxid
left join SSISHelper.Transaction_Export  te on th.trxid=te.[CatTrxID] 
where tt.name in ('PosTransaction','Void','Return') and te.[CatTrxID] is null -- and th.trxdate < @EndOfDayYesterday
--the filter above was causing issues due to UTC. We were missing 10 hours of transactions per day potentially.
--I have the filter removed and we have all records up to time that the process runs at 09:05 UTC
insert into SSISHelper.Transaction_Export 
([EposTrxId],[reference],[TrxDate],[LoyaltyDeviceID],[MemberID],[MobilePhone],[CatTrxID],[TotalAmount],[#items],[ExportDate],[Filename],[ExportStatus])
select th.EposTrxId,th.reference,convert(nvarchar(10),th.TrxDate,112) as TrxDate, 
dv.DeviceID as LoyaltyDeviceID ,dv.userid MemberID, 
--case when isnull(cd.MobilePhone,'')='' then dv.ExtraInfo else cd.MobilePhone end as [MobilePhone], 
dv.ExtraInfo as [MobilePhone], 
th.trxid CatTrxID,SUM(Value) TotalAmount,COUNT(td.trxdetailid) [#items],
GetDate() as [ExportDate],'Spencer_TrxFeed_' + @DatePart as [Filename],'ToExport' as [ExportStatus]
from TrxHeader th join trxdetail td on th.trxid=td.trxid
left join Device dv on th.deviceid=dv.deviceid
left join usercontactdetails ucd on dv.userid=ucd.userid
left join contactdetails cd on cd.contactdetailsid =ucd.contactdetailsid 
join TrxType tt on th.trxtypeid=tt.trxtypeid
join #TrxToGo te on th.trxid=te.trxid  -->> this is the filter for the records and they are deduped!

Group by th.EposTrxId,dv.DeviceID ,dv.userid, dv.ExtraInfo, th.trxid,tt.name, th.reference,convert(nvarchar(10),th.TrxDate,112)
delete from SSISHelper.Transaction_Export where memberid in (select userid from #testusers) 
delete from SSISHelper.Transaction_Export where reference like 'auto%'
delete from SSISHelper.Transaction_Export where reference like 'Snipp-Auto%'
Drop table if exists #TrxToGo
Drop table if exists #TestUsers 

End
