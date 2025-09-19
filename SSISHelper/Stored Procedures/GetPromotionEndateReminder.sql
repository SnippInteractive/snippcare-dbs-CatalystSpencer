


CREATE PROCEDURE [SSISHelper].[GetPromotionEndateReminder] 
	   
AS
BEGIN


Declare  @DaysToGoBack INT 
select @DaysToGoBack =  Value from ClientConfig where Id = 1119

Truncate table [dbo].[SSISHelper.GetPromotionEndateReminder]

Insert into [dbo].[SSISHelper.GetPromotionEndateReminder]

Select datediff(day,getdate(),EndDate) as 'Days when this promo ends', Name PromotionName ,Description
from promotion

where
  datediff(day,getdate(),enddate) <= @DaysToGoBack  
  and 
   datediff(day,getdate(),EndDate) >0
  Order by datediff(day,getdate(),EndDate) asc

  end


