-- =============================================      
-- Author:  <Author,,Name>      
-- Create date: <Create Date,,>      
-- Description: <Description,,>      
-- =============================================      
CREATE PROCEDURE [dbo].[API_Assign_SubmissionDevices] (@UserId  nvarchar(20), @ClientName  nvarchar(20),@Results nvarchar(max) = NULL output)      
AS      
BEGIN     
SET TRANSACTION ISOLATION LEVEL READ UNcommitTED  
 SET NOCOUNT ON;      
      
 Declare @ClientId int;      
 Declare @ActiveDeviceStatusId int;      
 Declare @InactiveDeviceStatusId int;      
 Declare @InactiveDeviceProfileStatusId int;      
 Declare @CurrentAddressStatusId int;      
 Declare @UserDevices int;      
 Declare @SubmissionDevices int;      
 Declare @UserEmail varchar(max);      
 Declare @UserMobile varchar(25)      
 Declare @MobilePrefix nvarchar(25);      
 Declare @MobileNumber nvarchar(25);      
 Declare @EmailDeviceId varchar(25);      
 Declare @MobileDeviceId varchar(25);      
 Declare @UserAccountId int;      
 Declare @UserBalance decimal(18,2);      
       
 select top 1 @ClientId = ClientId from Client where Name = @ClientName;       
 select top 1 @ActiveDeviceStatusId = DeviceStatusid       
 from DeviceStatus        
 where Name = 'Active'       
 and ClientId = @ClientId;      
      
 select top 1 @InactiveDeviceStatusId = DeviceStatusid       
 from DeviceStatus        
 where Name = 'Inactive'       
 and ClientId = @ClientId;      
      
 select top 1 @InactiveDeviceProfileStatusId = DeviceProfileStatusId       
 from DeviceProfileStatus        
 where Name = 'Inactive'       
 and ClientId = @ClientId;      
      
 select top 1 @CurrentAddressStatusId = addressstatusid       
 from AddressStatus        
 where Name = 'Current'       
 and ClientId = @ClientId;      
      
 select @UserAccountId = accountid, @UserDevices = Count(*) from Device      
 where userid = @UserId      
 and DeviceStatusId=@ActiveDeviceStatusId      
 group by accountid;      
      
 if(@UserDevices is null)      
 begin      
  set @UserDevices = 0;      
 end      
      
 select @UserEmail =cd.Email, @MobilePrefix =isnull(c.MobilePrefix,''), @UserMobile=cd.MobilePhone from [user] u      
 join UserContactDetails ucd on u.userid = ucd.UserId      
 join ContactDetails cd on ucd.contactdetailsid = cd.contactdetailsid      
 join UserAddresses ua on u.userid = ua.UserId      
 join Address a on ua.addressid = a.addressid and a.AddressStatusId = @CurrentAddressStatusId      
 join country c on a.CountryId = c.CountryId      
 where u.userid = @UserId      

----VOY-1172 issue
IF LEFT(@UserMobile,1) <>'+'
	BEGIN
		set @MobileNumber = cast(@MobilePrefix as nvarchar) + cast(@UserMobile as nvarchar);  
	END
ELSE
	BEGIN
		set @MobileNumber = cast(@UserMobile as nvarchar);  
	END

----End VOY-1172 issue
-- set @MobileNumber = cast(@MobilePrefix as nvarchar) + cast(@UserMobile as nvarchar);
      
 select @SubmissionDevices = sum(TotalDevices), @EmailDeviceId = max(EmailDevice), @MobileDeviceId = max(MobileDevice)       
 from (      
  select count(D1.Id) TotalDevices, D2.Id EmailDevice, D3.Id MobileDevice      
  from Device D1      
  left join Device D2 on D1.id = D2.id and @UserEmail = D2.ExtraInfo      
  left join Device D3 on D1.id = D3.id and (@MobileNumber = D3.ExtraInfo OR @MobileNumber = (@MobilePrefix+D3.ExtraInfo)) ----VOY-1172 issue   
  --left join Device D3 on D1.id = D3.id and @MobileNumber = D3.ExtraInfo
  where D1.userid is null       
  and D1.DeviceStatusId=@ActiveDeviceStatusId      
  and (D1.ExtraInfo = @UserEmail or D1.ExtraInfo = @MobileNumber or @MobileNumber = (@MobilePrefix+D1.ExtraInfo)) ----VOY-1172 issue 
  --and (D1.ExtraInfo = @UserEmail or D1.ExtraInfo = @MobileNumber) 
  group by D2.id, D3.id) a      
      
      
      
 if(@SubmissionDevices is null)      
 begin      
  set @SubmissionDevices = 0;      
 end      
      
 if (@SubmissionDevices>0)      
 begin      
  if (@UserDevices >0)      
  begin      
         
   select @UserBalance = isnull(sum(PointsBalance),0) from account a      
   join device d on a.accountid = d.accountid and d.id in (@EmailDeviceId,@MobileDeviceId)      
      
   Update account      
   set PointsBalance = PointsBalance + @UserBalance --null check      
   where accountid = @UserAccountId;      
      
   UPDATE a      
   SET a.userid = null,      
   a.AccountStatusTypeId = 1,      
   a.PointsBalance = 0      
   FROM account AS a      
   INNER JOIN device AS d      
   ON a.accountid = d.accountid and d.id in (@EmailDeviceId,@MobileDeviceId)      
      
   Update Device      
   set userid = @UserId,      
   DeviceStatusId = @InactiveDeviceStatusId,      
   accountid =   @UserAccountId      
   where Id in (@EmailDeviceId,@MobileDeviceId)      
      
   Update DeviceProfile      
   set StatusId = @InactiveDeviceProfileStatusId      
  where deviceid in (@EmailDeviceId,@MobileDeviceId)      
      
   select @Results = 'Submission Devices merged with existing account';      
  end      
      
  if (@UserDevices =0 and @SubmissionDevices = 1)      
  begin      
   Update Device      
   set userid = @UserId      
   where Id in (@EmailDeviceId,@MobileDeviceId)      
      
   Update account      
   set userid = @UserId      
   where accountid in (select accountid from device where id in (@EmailDeviceId,@MobileDeviceId))      
      
   select @Results =  'Submission Device assigned to user';      
  end      
      
  if (@UserDevices =0 and @SubmissionDevices > 1)      
  begin      
      
   select @UserAccountId = accountid from device where id =@EmailDeviceId      
      
   select @UserBalance = isnull(sum(PointsBalance),0) from account a      
   join device d on a.accountid = d.accountid and d.id = @MobileDeviceId      
      
   Update account      
   set PointsBalance = PointsBalance + @UserBalance,      
   userid = @UserId      
   where accountid = (select accountid from device where id =@EmailDeviceId)      
      
   UPDATE a      
   SET a.userid = null,      
   a.AccountStatusTypeId = 1,      
   a.PointsBalance = 0      
   FROM account AS a      
   INNER JOIN device AS d      
   ON a.accountid = d.accountid and d.id = @MobileDeviceId      
      
   Update Device      
   set userid = @UserId      
   where Id =@EmailDeviceId      
      
   Update Device      
   set userid = @UserId,      
   DeviceStatusId = @InactiveDeviceStatusId,      
   accountid =   @UserAccountId      
   where Id =@MobileDeviceId      
      
   Update DeviceProfile      
   set StatusId = @InactiveDeviceProfileStatusId      
   where deviceid =@MobileDeviceId      
      
   select @Results = 'Submission Devices assigned to user and merged';      
  end      
 end      
 if (@SubmissionDevices=0)      
 begin      
  select @Results =  'No additional devices found'      
 end      
      
 return;      
END      
      
      
--[dbo].[API_Assign_SnippCheckDevices] 1402345, 'BlueBuffalo      
/*      
begin      
update device      
set devicestatusid = 2,      
userid = null      
where userid = 1402337 --and extrainfo is not null      
      
update account      
set userid = null,      
pointsbalance = 0      
 where userid = 1402337 --and extrainfo is not null      
declare @test nvarchar(1000);      
exec [dbo].[API_Assign_SubmissionDevices] 1402337, 'BlueBuffalo', @test OUTPUT      
print(@test)      
end      
*/
