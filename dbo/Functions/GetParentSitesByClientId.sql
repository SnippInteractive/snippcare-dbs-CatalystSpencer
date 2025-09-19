-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[GetParentSitesByClientId]
(	
	-- Add the parameters for the function here
	@clientId int
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
          WHERE ClientId = @clientId
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
