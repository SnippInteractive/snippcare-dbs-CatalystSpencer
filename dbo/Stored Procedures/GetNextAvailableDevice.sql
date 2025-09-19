CREATE PROCEDURE [dbo].[GetNextAvailableDevice] ( @clientId int,@profileType nvarchar(50), @Result nvarchar(25) output,@IsVirtual bit = 0,@profileId int=0)        
                                                      
                                                      
AS        
  BEGIN        
          
      -- SET NOCOUNT ON added to prevent extra result sets from        
      -- interfering with SELECT statements.        
     SET NOCOUNT ON;        
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED        
   BEGIN TRY        
  BEGIN TRAN          
        
    DECLARE @ProfileTypeId INT        
    DECLARE @DeviceStatusId INT        
    DECLARE @ProfileStatusId INT        
    DECLARE @profiletemplateStatus int; 
	DECLARE @DeviceId VARCHAR(20) 
	      
    

	IF @profileType = 'Voucher'
	BEGIN


			Declare @ProfilecreatedStatusId int
			select @profiletemplateStatus=Id  from DEviceProfileTemplateStatus where clientid=@clientId and Name='Active' 
			SET @DeviceStatusId=(select DeviceStatusId from DeviceStatus where Name='Ready' and ClientId=@ClientId)        
			SET @ProfileStatusId=(select DeviceProfileStatusId from DeviceProfileStatus where Name='Active' and ClientId=@ClientId)  
			SET @ProfilecreatedStatusId=(select DeviceProfileStatusId from DeviceProfileStatus where Name='Created' and ClientId=@ClientId)      
            
			IF @profileId>0
			BEGIN
				SET @DeviceId=(SELECT TOP 1 d.deviceid from Device d join DeviceProfile dp on d.id=dp.DeviceId       
					  join Account a on a.Accountid=d.AccountId and a.UserId is null      
					where d.DeviceStatusId=@DeviceStatusId and dp.StatusId in(@ProfileStatusId,@ProfilecreatedStatusId)        
					and dp.DeviceProfileId = @profileId 
					and isnull(d.Owner,0)<>'-1' and d.UserId is null and d.ExtraInfo is null  
					and d.deviceid not in (select deviceid from TrxHeader where DeviceId is not null)    
												 order by d.Id asc)
			END
			ELSE
			BEGIN
			SET @DeviceId=(SELECT TOP 1 d.deviceid from Device d join DeviceProfile dp on d.id=dp.DeviceId       
					  join Account a on a.Accountid=d.AccountId and a.UserId is null      
					where d.DeviceStatusId=@DeviceStatusId and dp.StatusId in(@ProfileStatusId,@ProfilecreatedStatusId)        
					and dp.DeviceProfileId in(select distinct dp.Id from DeviceProfileTemplate dp       
							join DeviceProfileTemplateType dptp   on dp.DeviceProfileTemplateTypeId=dptp.Id        
							--join [dbo].[LoyaltyDeviceProfileTemplate] lpt on lpt.Id=dp.Id      
					where dptp.Name= @profileType and dptp.ClientId = @clientId 
					and dp.StatusId = @profiletemplateStatus and dp.Virtual = @IsVirtual) 
					and isnull(d.Owner,0)<>'-1' and d.UserId is null and d.ExtraInfo is null  
					and d.deviceid not in (select deviceid from TrxHeader where DeviceId is not null)    
												 order by d.Id asc)
			END
			 
    END
	ELSE
	BEGIN

			select @profiletemplateStatus=Id  from DEviceProfileTemplateStatus where clientid=@clientId and Name='Active'         
			--If @profileType = 'Loyalty'      
			--begin      
			--	IF @IsVirtual = 1 
			--	BEGIN
			--		SET @ProfileTypeId=(select top 1 dp.Id from DeviceProfileTemplate dp       
			--				join DeviceProfileTemplateType dptp   on dp.DeviceProfileTemplateTypeId=dptp.Id        
			--				join [dbo].[LoyaltyDeviceProfileTemplate] lpt on lpt.Id=dp.Id      
			--		where dptp.Name= @profileType and dptp.ClientId = @clientId and dp.StatusId = @profiletemplateStatus and dp.Virtual = 1)
			--	END
			--	ELSE
			--	BEGIN  
			--		SET @ProfileTypeId=(select top 1 dp.Id from DeviceProfileTemplate dp       
			--				join DeviceProfileTemplateType dptp   on dp.DeviceProfileTemplateTypeId=dptp.Id        
			--				join [dbo].[LoyaltyDeviceProfileTemplate] lpt on lpt.Id=dp.Id      
			--		where dptp.Name= @profileType and dptp.ClientId = @clientId and dp.StatusId = @profiletemplateStatus and dp.Virtual <> 1 )     
			--	END   
			--    end      
      
			SET @DeviceStatusId=(select DeviceStatusId from DeviceStatus where Name='Active' and ClientId=@ClientId)        
			SET @ProfileStatusId=(select DeviceProfileStatusId from DeviceProfileStatus where Name='Active' and ClientId=@ClientId)        
			        
			SET @DeviceId=(SELECT TOP 1 d.deviceid from Device d join DeviceProfile dp on d.id=dp.DeviceId       
					  join Account a on a.Accountid=d.AccountId and a.UserId is null      
					where d.DeviceStatusId=@DeviceStatusId and dp.StatusId=@ProfileStatusId         
					and dp.DeviceProfileId in(select distinct dp.Id from DeviceProfileTemplate dp       
							join DeviceProfileTemplateType dptp   on dp.DeviceProfileTemplateTypeId=dptp.Id        
							--join [dbo].[LoyaltyDeviceProfileTemplate] lpt on lpt.Id=dp.Id      
					where dptp.Name= @profileType and dptp.ClientId = @clientId 
					and dp.StatusId = @profiletemplateStatus and dp.Virtual = @IsVirtual) 
					and isnull(d.Owner,0)<>'-1' and d.UserId is null and d.ExtraInfo is null  
					and d.deviceid not in (select deviceid from TrxHeader where DeviceId is not null)    
												 order by d.Id asc)   
		
	END
	   
    UPDATE Device set Owner='-1' where DeviceId=@DeviceId     

SELECT @Result = @DeviceId
   SELECT @DeviceId AS Result 
   
  COMMIT TRAN        
  END TRY        
  BEGIN CATCH        
   ROLLBACK TRAN        
  END CATCH        
         
  END
