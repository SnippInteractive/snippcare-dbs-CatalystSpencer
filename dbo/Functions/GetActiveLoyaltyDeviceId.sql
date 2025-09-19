Create FUNCTION [dbo].[GetActiveLoyaltyDeviceId]         
(        
 @memberid int        
)        
        
RETURNS VARCHAR(25)        
AS        
BEGIN        
  Declare @ActiveLoyaltyDeviceId Varchar(25)       
      
  SET  @ActiveLoyaltyDeviceId =(     
  SELECT top 1 d.DeviceId    
  FROM Device d     
  INNER JOIN DeviceStatus ds ON d.DevicestatusId = ds.DeviceStatusId    
  INNER JOIN DeviceProfile dp   ON d.id = dp.deviceid  
  INNER JOIN DeviceProfileStatus dps ON dps.DeviceProfileStatusId = dp.StatusId     
  INNER JOIN DeviceProfileTemplate t  ON dp.DeviceProfileID = t.id      
  INNER JOIN DeviceProfileTemplateType dt ON t.DeviceProfileTemplateTypeId = dt.Id     
  WHERE dt.Name = 'Loyalty'   
  AND ds.Name = 'Active'   
  AND dps.Name = 'Active'  
  AND d.UserId = @memberid    
  ORDER BY d.StartDate desc    
  )    
      
   RETURN @ActiveLoyaltyDeviceId;          
            
End 
