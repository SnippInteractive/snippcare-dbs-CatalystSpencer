CREATE   FUNCTION [dbo].[Sitelist2Table] 
 (
  @siteId  int
 )
RETURNS @retTable TABLE 
 (
  siteId  varchar(20)
 )
AS


BEGIN

	WITH SiteList (siteid, parentId, level) AS
	 (
	  -- Create the anchor query. This establishes the starting point
	  SELECT
		siteId,parentId ,0 AS level
	  FROM site a
	  WHERE siteid = @siteId
	  UNION ALL
	  -- Create the recursive query. This query will be executed until it returns no more rows
	  -- or it meets a site with the same parent id which signifys root
	  SELECT
		 a.siteid, a.parentId, level + 1 
	   FROM dbo.site a
		  INNER JOIN SiteList AS b
			ON a.siteid = b.parentId
		WHERE a.siteId <> b.siteid
	 )

	INSERT INTO @retTable 
		SELECT siteId FROM SiteList 

	RETURN 
END
