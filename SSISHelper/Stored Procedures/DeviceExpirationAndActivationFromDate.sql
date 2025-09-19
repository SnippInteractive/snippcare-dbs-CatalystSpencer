-- =============================================
-- Author: Niall
-- Create date: 2019-08-16
-- Description: Expires and actives devices based on current date
-- =============================================
Create PROCEDURE [SSISHelper].[DeviceExpirationAndActivationFromDate] ( @ClientAlias  varchar(50) = 'Spencer')

AS
BEGIN
--declare @ClientAlias varchar(50) = 'Spencer'
declare @adminUser int, @deviceProfileExpired INT, @deviceProfileActive int, @ClientID int, @DeviceStatusExpiredId INT, 
@DeviceStatusActiveId int, @extraInfo nvarchar(50), @adminUserTypeId int, @deviceActionId int, 
@deviceStatusTransitionTypeId int, @currentTime datetime, @trxtypeMoneyExpiry int, @trxStatusCompleted int;
set @currentTime = GETDATE();
set @extraInfo = 'DeviceExpirationAndActivationFromDate';
select @adminUserTypeId = UserTypeId from usertype where clientid=@ClientId and name='SystemUser';
select @clientid =  clientid from client where Name = @ClientAlias;
select @DeviceStatusExpiredId = DeviceStatusId from DeviceStatus where  clientId = @ClientId and Name='Expired' 
select @DeviceStatusActiveId = DeviceStatusId from DeviceStatus where clientId = @ClientId and Name='Active' 
select @deviceProfileExpired = DeviceProfileStatusId from DeviceProfileStatus where clientId = @ClientId and Name='Blocked'
select @deviceProfileActive = DeviceProfileStatusId from DeviceProfileStatus where  clientId = @ClientId and Name='Active'
select @trxtypeMoneyExpiry = TrxTypeId from TrxType where clientid = @clientid and name = 'MoneyExpiry' 
select @trxStatusCompleted = TrxStatusId from TrxStatus where clientid = @clientid and name = 'Completed' 
select @deviceActionId = DeviceActionId from DeviceAction where Name='UpdateExpireDate' and clientid=@clientid
select @deviceStatusTransitionTypeId = DeviceStatusTransitionTypeId from DeviceStatusTransitionType where Name='Manual' and clientid=@clientid
select top 1 @adminUser = UserId from [user] u join site s on s.siteid = u.siteid where username='batchprocessadmin' 
and clientid = @clientid
select @Clientid
drop table if exists #DevicesToExpire

-- activation is only happening for vouchers & giftcards (devices)
select d.Id, d.deviceid, d.UserId, d.HomeSiteId, ds.Name, ExpirationDate, 
StartDate,
case when d.ExpirationDate < @currentTime then @DeviceStatusExpiredId 
when CONVERT(VARCHAR(10), StartDate, 110)  = CONVERT(VARCHAR(10), 
@currentTime, 110) and dptt.Name in ('Voucher','Financial')   and ds.Name <> 
'Active' then @DeviceStatusActiveId end NewStatusId,
case when d.ExpirationDate < @currentTime then 'Expiry' 
when CONVERT(VARCHAR(10), StartDate, 110)  = CONVERT(VARCHAR(10), 
@currentTime, 110) and dptt.Name  in ('Voucher','Financial') and ds.Name <> 
'Active' then 'Activation' end Reason,
case when d.ExpirationDate < @currentTime then @deviceProfileExpired 
when CONVERT(VARCHAR(10), StartDate, 110)  = CONVERT(VARCHAR(10), 
@currentTime, 110) and dptt.Name in ('Voucher','Financial')  and ds.Name <> 
'Active' then @deviceProfileActive end NewProfileStatusId, d.accountid 
into #DevicesToExpire
from [Device] d 
join DeviceStatus ds on ds.DeviceStatusId = d.DeviceStatusId
join DeviceProfile dp on dp.DeviceId = d.Id
join DeviceProfileTemplate dpt on dpt.Id = dp.DeviceProfileId
join DeviceProfileTemplateType dptt on dpt.DeviceProfileTemplateTypeId = 
dptt.Id
where ds.Name <> 'Expired' and (ExpirationDate < @currentTime or CONVERT(VARCHAR(10), StartDate, 110)  = CONVERT(VARCHAR(10), @currentTime, 110))
and ds.ClientId = @ClientID
and dptt.ClientId = @ClientID;
delete from #DevicesToExpire where NewStatusId is null or NewProfileStatusId 
is null;

/*
There are device ( for Birthday vouchers ) which are setup en-mas. DO NOT EXPIRE THEM
as they are READY and not ACTIVE. Basically setup as a Future Devices.
*/
update d
set DeviceStatusId = dte.NewStatusId
from Device d
join #DevicesToExpire dte on dte.Id = d.Id and dte.name = 'Active' and d.Expirationdate < GetDate()

update dp
set StatusId = dte.NewProfileStatusId
from DeviceProfile dp
join #DevicesToExpire dte on dte.Id = dp.DeviceId and dte.name = 'Active' and dte.Expirationdate < GetDate()

INSERT INTO [DeviceStatusHistory] (
[VERSION] ,[DeviceId],[DeviceStatusId] ,[ChangeDate] ,[Reason] ,
[DeviceStatusTransitionType] ,
[UserId] ,ExtraInfo, [ActionId], [DeviceTypeResult], [ActionResult],
[ActionDetail], [OldValue], [NewValue], [SiteId], [DeviceIdentity])
select 1, dte.DeviceId, dte.NewStatusId, @currentTime, 'SQL Job-  ' + 
dte.Reason + ' From Current Date'  , @deviceStatusTransitionTypeId, 
case when isnull(dte.UserId,0) = 0 then @adminUser else dte.userid end,
@extraInfo, @deviceActionId, null, 1, dte.Reason + ' Device ',  dte.Name, 
dte.Reason, dte.HomeSiteId, dte.Id
from #DevicesToExpire dte
where dte.name = 'Active' and dte.Expirationdate < GetDate();

drop table if exists #DevicesToExpire

END