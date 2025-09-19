CREATE FUNCTION [dbo].[GetMemberStatus]   
(  
 @memberid int,@clientId int  
)  
  
RETURNS VARCHAR(15)  
AS  
BEGIN  
  Declare @MemberStatus Varchar(15)  
  
  if exists( Select 1 from device d inner join devicestatus ds on ds.DeviceStatusId = d.DeviceStatusId and ds.clientId=@clientId and ds.Name='Active'  
        inner join deviceprofile df on df.deviceid=d.id  
                          inner join DEviceProfiletemplate dpt on dpt.Id=df.DeviceProfileId  
        inner join DEviceProfiletemplateType dptt on dptt.Id= dpt.DEviceProfiletemplateTypeId  
        where d.USerId=@memberid and dptt.Name in ('Loyalty') and dptt.ClientId=@clientId )  
   begin  
   set @MemberStatus = 'Member'     
   end  
  else  
  begin  
  set @MemberStatus = 'Prospect'   
  end  
  
      RETURN @MemberStatus;    
      
End
