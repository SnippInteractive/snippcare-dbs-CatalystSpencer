
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[GetChildSitesBySiteId]  
(	
	-- Add the parameters for the function here
	@siteID int
)
RETURNS TABLE 
AS
RETURN 
(
	WITH ChildsList (siteid, parentId, level) AS
      (
          SELECT
          siteId, parentId ,0 AS level
          FROM site a
          WHERE siteid = @SiteId
          UNION ALL
          SELECT
          a.siteid, a.parentId, level + 1
          FROM dbo.site a
          INNER JOIN ChildsList AS b
          ON a.parentId = b.siteid
          WHERE a.siteId <> b.siteid
    )
 -- PG EDIT - REMOVED 05/03/2014    
 --   SELECT 
 --         s.* from [Site] s 
 --         WHERE s.siteId =  (Select ParentId from Site where SiteId = @siteID)
	--UNION ALL  
   select s.* from ChildsList sl inner join [Site] s on s.SiteId=sl.siteid --where s.SiteTypeId not in (Select SiteTypeId from SiteType where Name='Installer')
)
