-- =============================================
-- Author:		<Kamil Wozniak>
-- =============================================

-- Modified by: Abdul Wahab 
-- Modified Date: 30-June-2020
-- Update the account table with correct user Id

CREATE PROCEDURE  [dbo].[API_Device_AssignDeviceToUser] (
		@DeviceStatus nvarchar(20),
		@DeviceProfileTemplate nvarchar(20),
		@ClientName nvarchar(20),
		@UserId1  nvarchar(20),
		@Results varchar(max) = NULL output ,
		@ResultsValidation bit = 0 output 
	)
AS
BEGIN
--SET ANSI_WARNINGS OFF

--SET TRANSACTION ISOLATION LEVEL READ UNcommitTED   

 SET NOCOUNT ON;    
    
 Declare @DeviceStatusId int    
 Declare @outputDevice table (DeviceId varchar(20), AccountId int, UserId int, SiteId int)    
 Declare @outputTrxHeader table (TrxId int)    
 Declare @ProfileId int    
 Declare @UserSiteId int;    
 Declare @UserDevices int;    
 Declare @trxTypeId int;    
 Declare @trxStatusTypeId int;    
 Declare @UserId int;    
 Declare @UserType varchar(30);    
 Declare @UserTypeId int;    
 Declare @ClientId int;    
 Declare @MergeResults nvarchar(max);    
    
 set @UserId =  CONVERT(int, @UserId1)    
 set @ResultsValidation = 0;    
    
 select top 1 @ClientId = ClientId from Client where Name = @ClientName;    
 select top 1 @UserTypeId= UserTypeId from UserType where clientid = @ClientId and Name = 'LoyaltyMember';    
    
    
 select top 1 @ProfileId = dp.id     
 from DeviceProfileTemplate dp with (nolock)    
 inner join DeviceProfileTemplateType dpt on dp.DeviceProfileTemplateTypeId=dpt.Id     
 where dpt.ClientId = @ClientId     
 and dpt.Name = @DeviceProfileTemplate    
     
 select top 1 @DeviceStatusId = DeviceStatusid     
 from DeviceStatus      
 where Name = @DeviceStatus     
 and ClientId = @ClientId;    
    
  exec [dbo].[API_Assign_SubmissionDevices] @UserId, @ClientName, @MergeResults OUTPUT    
  
 select @UserDevices = isnull(COUNT(d.deviceid),0), @UserSiteId = isnull(max(SiteId),0), @UserType = max(ut.Name)    
 from [user] u  --WITH (UPDLOCK, HOLDLOCK)    
 join UserType ut on ut.UserTypeId = u.UserTypeId    
 left join device d on  u.userid = d.userid and DeviceStatusId = @DeviceStatusId     
 left join DeviceProfile dp on d.id=dp.DeviceId and DeviceProfileId = @ProfileId     
 where u.userid = @UserId    
    
 if(@UserDevices is null)    
 begin    
  set @UserDevices = 0;    
 end    
    
 --BEGIN TRAN    
    
 if(@UserSiteId = 0)    
  begin     
  print( 'usersiteid = 0')    
   --commit    
   set @Results = 'User does not exists';    
   select @Results, @ResultsValidation;    
   return;    
  end     
  -- not enough cards in the pool     
      
 if(@UserDevices > 0 and @MergeResults = 'No additional devices found')    
  begin     
  print( 'UserDevices > 0, MergeResults = No additional devices found')    
   --commit    
   set @Results = 'User already has an active loyalty device assigned to them, please review and try again';    
   select @Results, @ResultsValidation;    
   return;    
  end     
 if(@UserDevices > 0 and @MergeResults != 'No additional devices found')    
  begin     
  print( 'UserDevices > 0, MergeResults != No additional devices found')    
   if(@UserType = 'Prospect')    
    begin    
     update [User] set UserTypeId = @UserTypeId where UserId = @UserId;    
    end    
    
   --commit    
   select @Results = deviceid from Device where userid = @UserId and devicestatusid = @DeviceStatusId;    
   set @ResultsValidation = 1;    
   select @Results, @ResultsValidation;    
   return;    
  end     
 else     
  begin     
  print( 'UserDevices '+cast(@UserDevices as varchar)+' MergeResults: '+@MergeResults)    
   if(@UserType = 'Prospect')    
    begin    
     update [User] set UserTypeId = @UserTypeId where UserId = @UserId;    
    end    

    Drop table if exists #DL
	Select devicelotid into #DL from devicelotdeviceprofile where deviceprofileid = @ProfileId	

    UPDATE device     
   set UserId = @UserId, StartDate = GETDATE(), HomeSiteId = @UserSiteId    
    OUTPUT inserted.DeviceId, inserted.AccountId, inserted.UserId, inserted.HomeSiteId    
   into @outputDevice    
   where id = (    
    SELECT TOP 1 dv.id
			FROM device dv join #DL dl on dv.devicelotid=dl.devicelotid
			WHERE dv.userid is null and ExtraInfo is null and dv.DeviceStatusId = 2 and ([Owner]!=-1 or [Owner] is null)
			--order by newID() 
			and (ABS(CAST((BINARY_CHECKSUM (dv.Id, NEWID())) as int))  % 100) < 10 
   );    
    
   UPDATE Account     
   SET UserId=@UserId     
   FROM Account A INNER JOIN @outputDevice OD     
   ON A.AccountId = OD.AccountId      
  
  /*AW-2023-12-04:  we do not need this for Spencer (extra call, performance impact) **/
   --insert into tierusers ([TierId], [UserId], [StartOfPeriod], [EndOfPeriod], [Enabled], [ThresholdTo])  
   --select ta.id,dv.userid, ta.StartMonth,dateadd(month, ta.TierDuration,ta.StartMonth)EndDate,1,  ta.thresholdto   
   --from device dv join deviceprofile dp on dp.deviceid=dv.id  
   --join tieradmin ta on ta.LoyaltyProfileId=dp.DeviceProfileId  
   --INNER JOIN @outputDevice OD on od.deviceid=dv.deviceid collate database_Default  
   --and dv.userid not in (select userid from tierusers)  
  
    
   if (select count(1) from @outputDevice) = 0    
   begin     
    --commit    
    set @Results = 'Unable to assing device to the member. No active loyalty devices are currently available for this site';    
    select @Results, @ResultsValidation;    
    return;    
   end    
     
   select @Results = DeviceId from @outputDevice;    
   set @ResultsValidation = 1;    
    
   select @Results, @ResultsValidation;    
    
   end    
      
 --commit TRAN    
END    
/*    
begin    
/*update device    
set devicestatusid = 2,    
userid = null    
where userid = 1402352    
    
update account    
set pointsbalance = 0,    
userid = null    
where userid = 1402352 */    
    
declare @test nvarchar(1000);    
declare @test1 bit;    
exec [dbo].[API_Device_AssignDeviceToUser]  'Active','Loyalty', 'BlueBuffalo','1402352',@test OUTPUT, @test1 OUTPUT    
print(@test)    
end    
*/
