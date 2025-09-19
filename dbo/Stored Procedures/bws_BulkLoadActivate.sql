CREATE Procedure [dbo].[bws_BulkLoadActivate]     
(@ClientId int,@StartDeviceID varchar(20), @EndDeviceID varchar(20), @ExpirationDate datetime, @CardReference varchar(1000), @Amount decimal)     
    
as     
 BEGIN   
    
--Pur in an EXPIRATION DATE    
--declare @ExpirationDate datetime = '2017-05-21 23:59' --'6033232544619878' ,'6033232104622768'    
--Declare @MinAccount int, @MaxAccount int    
--select @MinAccount = min(accountid) from device where deviceid in  (@StartDeviceID,@EndDeviceID)    
--print @Minaccount    
--select @MaxAccount = max(accountid) from device where deviceid in  (@StartDeviceID,@EndDeviceID)    
--print @Maxaccount    
--POPULATE the tabel for the cards to be loaded.    
    
--  

Declare @Minid int, @Maxid int    
select @Minid = min(id) from device where deviceid in  (@StartDeviceID,@EndDeviceID)    
print @Minid    
select @Maxid = max(id) from device where deviceid in  (@StartDeviceID,@EndDeviceID)    
print @Maxid    
--POPULATE the tabel for the cards to be loaded.    
 
  
    
--delete from [__DevicesToActivate]     
--insert into  [__DevicesToActivate] (ID, Accountid, deviceid, AmtToLoad, ref)    
select ID, accountid, Deviceid, @Amount AmtToLoad, @CardReference Ref into #DevicesToActivate from device 
where  id between @Minid and @Maxid

--accountid between @MinAccount and @MaxAccount -- the 310 records to be activated with 50 for Globoforce 15    
/*insert into  [__DevicesToActivate] (ID, Accountid, deviceid, AmtToLoad, ref)    
--select accountid from device where deviceid in  ('6033232744069843' ,'6033232516984344')    
select ID, accountid, Deviceid, 10 AmtToLoad, 'Globoforce 15' Ref  from device where accountid between 5645819 and 5646118 -- the 300 records to be activated with 10 for Globoforce 15    
*/    
    
    
    
declare @DeviceActive int=0, @trxTypeRedemption int=0, @DeviceBlocked int=0    
declare @trxTypeManualClaim int=0, @OurTrxID int=0, @Trxstatus int=0    
declare @BatchProcessUser int=0, @Siteid int=0, @DeviceActionIdBlockDevice int=0    
declare @Deviceid varchar(25), @Reference varchar(1000),@TrxReference varchar(1000), @Accountid int=0, @Points int    
declare @trxTypeActivation int, @value int, @DeviceProfileActive int    
    
--select @ClientId = clientid from client where name ='ARNOTTS'    
select @siteid=siteid from Site where ClientId = @ClientId and ParentId=siteid    
    
    
select @DeviceProfileActive= DeviceProfileStatusId from DeviceProfileStatus where [Name] = 'Active' and clientid=@ClientId    
    
select @DeviceActive=DeviceStatusId from DeviceStatus where [Name] = 'Active' and clientid=@ClientId    
select @DeviceBlocked=DeviceStatusId from DeviceStatus where [Name] = 'Blocked' and clientid=@ClientId    
    
select @BatchProcessUser=userid from [User] where Username='batchprocessadmin'    
    
select @trxTypeActivation=TrxTypeid from TrxType where ClientId =@ClientId and [Name] = 'Activation'    
    --select * from trxtype
select @trxTypeManualClaim=TrxTypeid from TrxType where ClientId =@ClientId and [Name] = 'Reload'    
set @Trxstatus = (select TrxstatusId from Trxstatus where ClientId = @ClientId and Name = 'Completed')    
    
SELECT @DeviceActionIdBlockDevice=[DeviceActionId]   FROM [DeviceAction] where clientid = @ClientId and [Name]='BlockDevice'    
Declare @IDofDevice INT    
set @TRXReference = 'Bulk Load'    
    
declare cur cursor for     
select ID, accountid, Deviceid, AmtToLoad, Ref from #DevicesToActivate     
open cur    
fetch next from cur into  @IDofDevice, @Accountid, @Deviceid, @Value, @Reference    
while @@fetch_status =0      
Begin      
 BEGIN TRAN    
--Add a record to the DeviceStatusHistory, Audit and then change the Device status to BLOCKED on the Device Table.    
     
     --print 'A '+ @Deviceid
 update device set devicestatusid = @DeviceActive, Reference = @Reference, ExpirationDate = @ExpirationDate  ,  StartDate = Getdate()   where deviceid = @Deviceid    
 update deviceprofile set statusid = @DeviceProfileActive where Deviceid = @IDofDevice    
     
 INSERT INTO [TrxHeader]     
     ([DeviceId],[TrxTypeID],[TrxDate],[ClientId],[SiteId],Reference,TrxStatusTypeId,accountcashbalance, CallContextId)    
 VALUES      (@DeviceID,@trxTypeActivation,GetDate(),@ClientId ,@siteid,@TrxReference,@Trxstatus,@value,NEWID());    
    
 SET @OurTrxID= SCOPE_IDENTITY()    
    
   --Write the Transaction Detail records.    
 INSERT INTO [TrxDetail]    
  ([TrxID],[LineNumber],[ItemCode],[Description],[Quantity],[Value],[Points],Anal1)    
 VALUES      (@OurTrxID,'1','Activation',@Reference,1,@Value,0,'BulkLoad')    
    
 UPDATE [Account] SET    [MonetaryBalance] = @Value     WHERE  AccountId = @AccountID    
    
 fetch next from cur into  @IDofDevice, @Accountid, @Deviceid, @Value, @Reference    
     
     
 COMMIT TRAN    
end    
close cur    
deallocate cur    

    declare @DeviceIds varchar(max);
	set @DeviceIds = (select  DeviceId from #DevicesToActivate  FOR JSON AUTO)
	--exec [EP2_ProcessGiftcardsToJecas] @DeviceIds, null, 'loeb';

 select 1 as Result   ,'' AS Message
  END

