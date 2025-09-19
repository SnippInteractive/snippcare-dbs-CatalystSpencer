CREATE Procedure [SSISHelper].[VouchersOnceOffChristmas] as 
Begin
drop table if exists #dev
drop table if exists #usr
drop table if exists #ToUpdate
select id, deviceid,accountid,row_number() over(order by imageurl desc) RN
into #Dev
from device where devicelotid = 1086 and userid is null 

select [userid], row_number() over(order by userid ) RN into  #usr  from [User] u where UserTypeId=3 and UserStatusId = 2

select id,deviceid,accountid,userid into #ToUpdate from #dev d join #usr u on d.RN=u.RN

--select top 1 * from #ToUpdate

/*
1. Set the DeviceProfileStatus = 2
2. Update Accounts USERID
3. Update DEVICE, set USERID, STARTDATE = '2023-12-26', devicestatus = 2
*/
begin tran
update dv 
set dv.startdate = '2023-12-26 0:00 +00:00', 
dv.devicestatusid=2,
dv.UserId =t.UserId,
ExpirationDate = '2024-01-08 23:59:59 -05:00'
from device dv join #ToUpdate t on dv.deviceid = t.deviceid 

Update dp set dp.statusid = 2 from DeviceProfile dp join #ToUpdate t on 
dp.deviceid=t.id

update ac 
set ac.userid = t.userid
from account ac join #ToUpdate t on t.accountid = ac.accountid

commit tran

drop table if exists #dev
drop table if exists #usr
drop table if exists #ToUpdate

end