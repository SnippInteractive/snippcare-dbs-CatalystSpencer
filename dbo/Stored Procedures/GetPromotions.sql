
CREATE PROCEDURE [dbo].[GetPromotions]
(
	@pageIndex INT = 0,
	@pageSize  INT = 10,
	@sortDirection VARCHAR(100) = 'desc',
	@sortProperty VARCHAR(100),
	@Enabled VARCHAR(15)='',
	@siteids VARCHAR(MAX)='',
	@promotionCategoryTypeId INT = 0,
	@startDate VARCHAR(50)=NULL,
	@endDate VARCHAR(50)=NULL,
	@nameOrDesc NVARCHAR(250) = '',
	@acceptedSiteIds NVARCHAR(MAX)=NULL
)
AS
BEGIN
			DECLARE @Enable BIT = NULL
			print 'start'
			IF ( ISNULL(@Enabled,'') <> '' OR @Enabled <>'')
			BEGIN
				IF LOWER(@Enabled)='true'
					SET @Enable = 1
				IF LOWER(@Enabled)='false'
					SET @Enable = 0
			END
			print 'start2'

			IF @pageSize = 0  
			BEGIN  
				SET @pageSize = 10  
			END
			  
			IF @pageIndex =-1          
			BEGIN          
				SET @pageIndex = 0;          
			END 
			  
			DECLARE @FirstRow INT = 0, @LastRow INT = 0          
			SET @LastRow = @pageSize*(@pageIndex+1)          
			SET @FirstRow = @LastRow + 1 - @pageSize  
			
			DECLARE @SQL VARCHAR(MAX)=''
			DECLARE @OrderClause VARCHAR(100)=''

			IF @sortProperty  <> '' OR @sortProperty <> NULL
				SET @OrderClause = ' ORDER BY '+@sortProperty + ' ' +@sortDirection
			ELSE
				SET @OrderClause = '	ORDER BY  Id desc '
				
			SET @SQL = '

				DECLARE @TotalCount INT
				DECLARE @table TABLE
				(					
					[Site]				VARCHAR(100),
					Id					INT,
					[Name]				VARCHAR(100),
					Description			VARCHAR(MAX),
					StartDate			DATETIME,
					EndDate				DATETIME,
					[Enabled]			BIT,
					PromotionCategory	VARCHAR(100),
					Config				VARCHAR(MAX)
				)	

				DECLARE @tableSorted TABLE
				(
					RowNum				INT,
					[Site]				VARCHAR(100),
					Id					INT,
					[Name]				VARCHAR(100),
					Description			VARCHAR(MAX),
					StartDate			DATETIME,
					EndDate				DATETIME,
					[Enabled]			BIT,
					PromotionCategory	VARCHAR(100),
					Config				VARCHAR(MAX)
				)	

				INSERT @table
				(
							[Site],
							Id,
							Name,
							Description,
							StartDate,
							EndDate,
							[Enabled],
							PromotionCategory,
							Config
				)

				SELECT		s.Name as SiteName,
							p.Id Id,
							p.Name Name,
							p.Description Description,
							p.StartDate StartDate,
							p.EndDate EndDate,
							p.[Enabled],
							pc.Name as PromotionCategory,
							p.Config

				FROM		Promotion p
				INNER JOIN  [Site] s
				ON			p.SiteId = s.SiteId
				INNER JOIN  PromotionCategory pc
				ON			p.PromotionCategoryId = pc.Id
				INNER JOIN  dbo.GetChildSitesBySiteId ('+@siteids+') ps
				on ps.SiteId =p.SiteId	'

			print 'sql'
			print @SQL
			IF len(@acceptedSiteIds) > 0
			BEGIN
			SET @SQL = @SQL + 'INNER JOIN PromotionSites pas ON pas.PromotionId = p.Id AND pas.SiteId in ('+@acceptedSiteIds +') '
			END

			IF @Enable IS NOT NULL
				SET @SQL = @SQL + ' 
					AND p.[Enabled] ='+CAST(@Enable AS VARCHAR(100))

			--IF LEN(@siteids) > 0
			--	SET @SQL = @SQL +'
			--		AND p.SiteId IN (SELECT CAST(splitdata AS INT) FROM  dbo.fnSplitString('''+@siteids+''', '',''))'

			IF @promotionCategoryTypeId != 0
				SET @SQL = @SQL +' AND pc.PromotionCategoryTypeId =' + CAST(@promotionCategoryTypeId AS VARCHAR(10))

			IF Len(isnull(@startDate,'')) > 0  
				SET @SQL = @SQL +' AND p.StartDate >=''' + @startDate + ''''

			IF Len(isnull(@endDate,'')) > 0
				SET @SQL = @SQL +' AND p.EndDate <= dateadd(DAY, 1, ''' + @endDate + ''')'
		
			IF Len(@nameOrDesc) > 0
				SET @SQL = @SQL +' AND (p.Name like ''%' + @nameOrDesc + '%'' OR p.Description like ''%'+@nameOrDesc+'%'')'
		


			SET @SQL = @SQl + '


			INSERT @tableSorted
				(
							RowNum,
							[Site],
							Id,
							Name,
							Description,
							StartDate,
							EndDate,
							[Enabled],
							PromotionCategory,
							Config
				)
			SELECT		ROW_NUMBER()OVER( '+@OrderClause+')RowNum,
							[Site] as SiteName,
							Id,
							Name,
							Description,
							StartDate,
							EndDate,
							[Enabled],
							PromotionCategory,
							Config

			FROM		@table '+ @OrderClause +


			' 
			SELECT @TotalCount = COUNT(1)
			FROM   @table

			DELETE @tableSorted where RowNum < '+CAST(@FirstRow AS VARCHAR(100))+'
			DELETE @tableSorted where RowNum >'+CAST( @LastRow AS VARCHAR(100))+


			'
			SELECT 
					[Site] as SiteName,
					Id,
					Name,
					Description,
					CONVERT(VARCHAR(100),StartDate,101)StartDate,
					CONVERT(VARCHAR(100),EndDate,101)EndDate,
					[Enabled],
					PromotionCategory as PromotionCategoryName,
					Config,
					@TotalCount TotalCount

			FROM	@tableSorted'
			

			PRINT(@SQL)
			EXEC(@SQL)

END
