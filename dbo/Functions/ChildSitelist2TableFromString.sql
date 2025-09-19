
CREATE FUNCTION [dbo].[ChildSitelist2TableFromString]
 (
  @siteList varchar(1000)
 )
RETURNS @retTable TABLE 
 (
  siteId  varchar(20),
  Name nvarchar(40)
 )
AS


BEGIN

	DECLARE @delimeter  char(1)
	DECLARE @tmpTxt  varchar(20)
	
	DECLARE @pos int

	SET @delimeter = ',' --default to comma delimited.
	SET @siteList = LTRIM(RTRIM(@siteList))+ @delimeter
	SET @pos = CHARINDEX(@delimeter, @siteList, 1)

	IF REPLACE(@siteList, @delimeter, '') <> ''
		BEGIN
			WHILE @Pos > 0
			BEGIN
				SET @tmpTxt = LTRIM(RTRIM(LEFT(@siteList, @Pos - 1)))
				IF @tmpTxt <> ''
				BEGIN
					--INSERT INTO @retTable (siteId) VALUES (@tmpTxt) 

					WITH SiteList (Id, Name, level) AS
					 (
					  -- Create the anchor query. This establishes the starting point
					  SELECT
						SiteId, a.Name ,0 AS level
					  FROM Site a
					  WHERE siteId = @tmpTxt
					  UNION ALL
					  -- Create the recursive query. This query will be executed until it returns no more rows
					  SELECT
						 a.siteId, a.Name, level + 1 
					   FROM Site a
						  INNER JOIN SiteList AS b
							ON a.parentId = b.Id
							and (a.parentId <> a.siteId)
					 )

					INSERT INTO @retTable 
						SELECT Id, Name FROM SiteList order by level

				END
				SET @siteList = RIGHT(@siteList, LEN(@siteList) - @Pos)
				SET @Pos = CHARINDEX(',', @siteList, 1)

			END
		END	
	RETURN 
END


