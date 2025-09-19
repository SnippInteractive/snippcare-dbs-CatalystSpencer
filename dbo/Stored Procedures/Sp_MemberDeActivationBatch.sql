
CREATE PROCEDURE  [dbo].[Sp_MemberDeActivationBatch]  
  
AS  
BEGIN  
  declare @clientid int = (select clientid  from Client where name='baseline')  
  declare @userid int   
  declare @deviceId  nvarchar(25)  
  declare @temp1 table( UserId   int )  
    BEGIN TRY
  insert into @temp1  
  select top 5  
   [user].userid  
    from [user] inner join userstatus    
    on userstatus.UserStatusId = [user].UserStatusId  
    inner join usertype on [user].UserTypeId=usertype.UserTypeId  
    where userstatus.clientid=@clientid and userstatus.name='Active'   
    and usertype.name in('LoyaltyMember','Prospect')  and   
    [user].userid  not in   
    (select distinct table1.userId  from   
    (  
    (select distinct userid from device d inner join trxheader th on th.deviceid = d.deviceid   
    where th.TrxDate > ( SELECT DATEADD(year, -2, GETDATE())) and th.clientid=@clientid  and userid is not null  
    )   
  
    Union  
  
    (select distinct userid  from [user] inner join userstatus on userstatus.UserStatusId = [user].UserStatusId  
    where CreateDate >( SELECT DATEADD(year, -2, GETDATE())) and userstatus.clientid=@clientid         
    ) ) as table1 )  
  
  
  
DECLARE @LoopCounter INT = 0, @MaxId INT = (select count(UserId) from @temp1)  
DECLARE @LoopCounterdevice INT = 1, @MaxdeviceId INT = 0  
    
  WHILE(@LoopCounter <= @MaxId)  
   BEGIN  
   set @userid =(select top 1 UserId from @temp1)  
   print @userid   
   set @MaxdeviceId=0  
   set @LoopCounterdevice=1  
   set @MaxdeviceId= (select count(DeviceId)  from   device  where userid = @userid )  
  update [user]  
  set UserStatusId = (select top 1 UserStatusId from  UserStatus where Name = 'InActive' and ClientId =@clientid)  
  where UserId=@userid  
  
  INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,[SiteId])  
  VALUES      (1,'UserStatus','InActive','Active',getdate(),'Deactivating Member- Batch Job' ,
  'DeactivatingMember' ,@userId,
  (select UserId from  [user] inner join usertype on  usertype.UserTypeId =[user].UserTypeId
		where usertype.name='SystemUser' and ClientId =@clientid),
 (select SiteId from [user] where UserId=@userid))  
  
  
   WHILE(@LoopCounterdevice <= @MaxdeviceId)  
     BEGIN  
     set @deviceId=(select top 1 DeviceId from device d  inner join DeviceStatus ds on ds.DeviceStatusId = d.DeviceStatusId  
     where ds.name='Active' and userid = @userid)  
  
      update device   
      set DeviceStatusId=(select top 1 DeviceStatusId from DeviceStatus where name='Inactive' and clientid=@clientid)  
      where DeviceId= @deviceId  
  
      update account  
      set AccountStatusTypeId =( select top 1 AccountStatusId from  AccountStatus where Name = 'Disable' and ClientId =@clientid)  
      where userid=@userid  
  
      INSERT INTO [DeviceStatusHistory] ([VERSION] ,[DeviceId] ,[DeviceStatusId] ,[ChangeDate] ,[Reason] ,[DeviceStatusTransitionType] ,[UserId] ,[ActionId] ,[DeviceTypeResult] ,[ActionResult] ,
      [ActionDetail] ,[OldValue] ,[NewValue] ,[SiteId] ,[DeviceIdentity] )  
      VALUES (1 ,@deviceId ,  
      (select  top 1 DeviceStatusId from DeviceStatus where Name='Inactive' and clientid=@clientid ) ,  
      GETDATE() ,'Deactivating Member- Batch Job' ,  
      (select  top 1 DeviceStatusTransitionTypeId from DeviceStatusTransitionType where Name='Manual' and clientid=@clientid ) ,  
      @userid ,  
      (select  top 1 DeviceActionId from DeviceAction where Name='Deactivate' and clientid=@clientid ) ,  
      'MainCard' ,1 ,'Deactivating Member' , 'Active' ,'InActive' ,(select HomeSiteId from device  where DeviceId= @deviceId) ,  
      (select top 1 Id from device where DeviceId= @deviceId))  
  
   SET @LoopCounterdevice  = @LoopCounterdevice  + 1   
   end  
  
   delete from @temp1 where userid =@userid  
   SET @LoopCounter  = @LoopCounter  + 1   
  end  
  END TRY
  Begin CATCH
  DECLARE @Identifier VARCHAR(40)	
  SELECT @Identifier = cast(@clientid as nvarchar(2)) + '_'+ cast(NEWID() as nvarchar(40)) 
  	INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),(Select ERROR_MESSAGE()), 'Error', 'DeactivationSP')				

  END CATCH
END

