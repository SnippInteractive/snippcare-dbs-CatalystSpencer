create  Procedure [dbo].[UpdateExpiredStatusFromExpiryDate] (@ClientAlias varchar(20)) as 

declare @idofdevice INT;
declare @userid int,@siteId int;
declare @deviceId varchar(20);

declare @ClientID int, @DeviceStatusID int
declare @deviceblockStatus INT;
declare @DeviceStatusExpiredId INT;
declare @extraInfo nvarchar(50)
select top 1 @clientid =  clientid from client where Name =@ClientAlias


		select @DeviceStatusExpiredId=DeviceStatusId from DeviceStatus where clientId=@ClientId and Name='Expired'
		select @deviceblockStatus=DeviceStatusId from DeviceStatus where clientId=@ClientId and Name='Blocked'
	

		DECLARE db_cursor CURSOR FOR  	
		
		SELECT d.Id,d.deviceid,d.UserId,d.HomeSiteId  FROM [Device] d join DeviceStatus ds on ds.DeviceStatusId = d.DeviceStatusId WHERE DS.Name in( 'Active','Ready') and ExpirationDate < getdate() and DS.ClientId=@clientid
		OPEN db_cursor   
		FETCH NEXT FROM db_cursor INTO @idofdevice,@deviceId,@userid,@siteId   

		WHILE @@FETCH_STATUS = 0   
		BEGIN   
		--update device status to expired
           update device set DeviceStatusId = @DeviceStatusExpiredId where ID = @idofdevice
		-- update device profile statusto blocked
		   update deviceprofile set StatusId=@deviceblockStatus where deviceid=@idofdevice
		--  there could be devices with out userid with expiry date < today,so set batchprocessdmins userid for those devices so that an entry could be made to [DeviceStatusHistory]
		   If ISNULL(@userid,0) = 0
		    begin
			select @userid = UserId from [user] where username='batchprocessadmin' and usertypeid in (select UserTypeId from usertype where clientid=@ClientId and name='SystemUser')
			set @extraInfo =' UserId is null -set batchprocessadmins userid'
			end
		-- an entry to DeviceStatusHistory 
		
		   INSERT INTO [DeviceStatusHistory] ([VERSION] ,[DeviceId] ,[DeviceStatusId] ,[ChangeDate] ,[Reason] ,[DeviceStatusTransitionType] ,[UserId] ,ExtraInfo,[ActionId] ,[DeviceTypeResult] ,[ActionResult] ,
			  [ActionDetail] ,[OldValue] ,[NewValue] ,[SiteId] ,[DeviceIdentity] )  
			  VALUES (1 ,@deviceId ,  
			  (select  top 1 DeviceStatusId from DeviceStatus where Name='Expired' and clientid=@clientid ) ,  
			  GETDATE() ,'SQL Job- UpdateExpiredStatusFromExpiryDate' ,  
			  (select  top 1 DeviceStatusTransitionTypeId from DeviceStatusTransitionType where Name='Manual' and clientid=@clientid ) ,  
			  @userid ,  @extraInfo,
			  (select  top 1 DeviceActionId from DeviceAction where Name='UpdateExpireDate' and clientid=@clientid ) ,  
			  'MainCard' ,1 ,'Expire Device & Block Profile' , 'Active' ,'Expired' ,@siteId ,  
			  @idofdevice)  
  
       FETCH NEXT FROM db_cursor INTO @idofdevice,@deviceId,@userid,@siteId     
		END   

CLOSE db_cursor   
DEALLOCATE db_cursor
