-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
Create FUNCTION [dbo].[GetParentSitesByUserId]  
(   
 -- Add the parameters for the function here  
 @userID int, 
 @ClientId int
)  
RETURNS TABLE   
AS 

RETURN   
(  

 WITH ChildsList (siteid, parentId, level) AS  
      (  
          SELECT  
          siteId,parentId ,0 AS level  
          FROM site a  
          WHERE siteid = (SELECT siteId from [user] where userId=@userId and ClientId = @ClientId)
          UNION ALL  
          SELECT  
          a.siteid, a.parentId, level + 1  
          FROM dbo.site a  
          INNER JOIN ChildsList AS b  
          ON a.siteid = b.parentId  
          WHERE a.siteId <> b.siteid  
    )  
    select s.* from ChildsList sl inner join [Site] s on s.SiteId=sl.siteid  
)
