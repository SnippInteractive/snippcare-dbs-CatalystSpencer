CREATE PROCEDURE [dbo].[GetProductInfo]
(
	@SearchCriteria		NVARCHAR(MAX) = '',
	@ReturnASJson		BIT = 1
)
AS
BEGIN
	SET NOCOUNT ON
	-- Checking whether the string is JSON or not.If not, return.
	IF ISJSON(@SearchCriteria) <= 0
	BEGIN
		PRINT 'Invalid Search Criteria'
		RETURN
	END	

	DECLARE @ClientId			INT			  = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.ClientId') AS INT),0)
	DECLARE @MaxSearchCount		INT			  = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.MaxSearchCount') AS INT),0)
	DECLARE @ProductId			NVARCHAR(150) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.ProductId') AS NVARCHAR(150)),'')
	DECLARE @ProductDescription	NVARCHAR(500) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.ProductDescription') AS NVARCHAR(500)),'')
	DECLARE @AnalysisCode1		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode1') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode2		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode2') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode3		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode3') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode4		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode4') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode5		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode5') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode6		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode6') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode7		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode7') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode8		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode8') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode9		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode9') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode10		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode10') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode11		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode11') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode12		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode12') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode13		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode13') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode14		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode14') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode15		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.AnalysisCode15') AS NVARCHAR(100)),'')
	DECLARE @SortProperty		NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.SortProperty') AS NVARCHAR(100)),'')
	DECLARE @SortOrder			NVARCHAR(100) = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.SortOrder') AS NVARCHAR(100)),'ASC')
	DECLARE @Page				INT			  = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.Page') AS INT),0)
	DECLARE @PageSize			INT			  = ISNULL(CAST(JSON_VALUE(@SearchCriteria,'$.PageSize') AS INT),50)
	DECLARE @StartDate			DATETIME =	CASE 
												WHEN ISDATE(JSON_VALUE(@SearchCriteria,'$.StartDate')) > 0 
												THEN CONVERT(DATE, JSON_VALUE(@SearchCriteria,'$.StartDate'))
												ELSE NULL
											END
	DECLARE @EndDate			DATETIME =	CASE 
												WHEN ISDATE(JSON_VALUE(@SearchCriteria,'$.EndDate')) > 0 
												THEN CONVERT(DATE, JSON_VALUE(@SearchCriteria,'$.EndDate'))
												ELSE NULL
											END

	DECLARE @DISTINCTCLAUSE		NVARCHAR(MAX) = ''
	DECLARE @PROJECTION			NVARCHAR(MAX) = ''
	DECLARE @COUNTPROJECTION	NVARCHAR(MAX) = ''
	DECLARE @FROM				NVARCHAR(MAX) = ''
	DECLARE @WHERE				NVARCHAR(MAX) = ''
	DECLARE @SQL				NVARCHAR(MAX) = ''
	DECLARE @PAGINATION			NVARCHAR(MAX) = ''
	DECLARE @TotalCount			TABLE(TotalCount INT)
	DECLARE @GridCols			TABLE(ColumnName NVARCHAR(20))

	INSERT  @GridCols(ColumnName)
	VALUES  ('Id'),
			('ProductId'),
			('ProductDescription'),
			('AnalysisCode1'),
			('AnalysisCode2'),
			('AnalysisCode3'),
			('AnalysisCode4'),
			('AnalysisCode5')

	-- Checking whether the ClientId is null or 0 or valid, If then, return.
	IF @ClientId IS NULL OR @ClientId <= 0 
	BEGIN
		RETURN
	END


	-- Building the Select clause
	SET @PROJECTION = '
		SELECT 	pi.ID AS Id,
				pi.ProductId AS ProductId,
				pi.ProductDescription AS ProductDescription,
				pi.AnalysisCode1 AS AnalysisCode1,
				pi.AnalysisCode2 AS AnalysisCode2,
				pi.AnalysisCode3 AS AnalysisCode3,
				pi.AnalysisCode4 AS AnalysisCode4,
				pi.analysisCode5 AS AnalysisCode5,
				pi.AnalysisCode6 AS AnalysisCode6,
				pi.AnalysisCode7 AS AnalysisCode7,
				pi.AnalysisCode8 AS AnalysisCode8,
				pi.AnalysisCode9 AS AnalysisCode9,
				pi.AnalysisCode10 AS AnalysisCode10,
				pi.AnalysisCode11 AS AnalysisCode11,
				pi.AnalysisCode12 AS AnalysisCode12,
				pi.analysisCode13 AS AnalysisCode13,
				pi.analysisCode14 AS AnalysisCode14,
				pi.AnalysisCode15 AS AnalysisCode15,
				pi.ImportDate AS ImportDate ,
				pi.BaseValue AS BaseValue,
				pi.RetailPrice AS RetailPrice
	'

	-- Building the count clause to find out the total count of searched records.
	SET @COUNTPROJECTION = '
		SELECT	COUNT(pi.Id)
	'
	-- Building the From clause.
	SET @FROM = '
		FROM	ProductInfo pi
	'
	-- Building the Where Clause - START.
	-- Filtering with ClientId
	SET @WHERE = '
		WHERE	pi.ClientId = '+CAST(@ClientId AS NVARCHAR(10))+'
	'
	-- Filtering with ProductId
	IF LEN(@ProductId)>0
	BEGIN
		SET @WHERE = @WHERE + '
		AND		pi.ProductId = '''+@ProductId+'''
 		'
	END

	-- Filtering with Product Description
	IF LEN(@ProductDescription)>0
	BEGIN
		SET @WHERE = @WHERE + '
		AND		ISNULL(REPLACE(pi.ProductDescription,'' '',''''),'''') LIKE ''%'+REPLACE(@ProductDescription,' ','')+'%''
 		'
	END

	-- Filtering with AnalysisCode1
	IF LEN(@AnalysisCode1)>0
	BEGIN
		SET @WHERE = @WHERE + '
		AND		ISNULL(REPLACE(pi.AnalysisCode1,'' '',''''),'''') LIKE ''%'+REPLACE(@AnalysisCode1,' ','')+'%''
 		'
	END

	-- Filtering with AnalysisCode2
	IF LEN(@AnalysisCode2)>0
	BEGIN
		SET @WHERE = @WHERE + '
		AND		ISNULL(REPLACE(pi.AnalysisCode2,'' '',''''),'''') LIKE ''%'+REPLACE(@AnalysisCode2,' ','')+'%''
 		'
	END

	-- Filtering with AnalysisCode3
	IF LEN(@AnalysisCode3)>0
	BEGIN
		SET @WHERE = @WHERE + '
		AND		ISNULL(REPLACE(pi.AnalysisCode3,'' '',''''),'''') LIKE ''%'+REPLACE(@AnalysisCode3,' ','')+'%''
 		'
	END

	-- Filtering with AnalysisCode4
	IF LEN(@AnalysisCode4)>0
	BEGIN
		SET @WHERE = @WHERE + '
		AND		ISNULL(REPLACE(pi.AnalysisCode4,'' '',''''),'''') LIKE ''%'+REPLACE(@AnalysisCode4,' ','')+'%''
 		'
	END

	-- Filtering with AnalysisCode5
	IF LEN(@AnalysisCode5)>0
	BEGIN
		SET @WHERE = @WHERE + '
		AND		ISNULL(REPLACE(pi.AnalysisCode5,'' '',''''),'''') LIKE ''%'+REPLACE(@AnalysisCode5,' ','')+'%''
 		'
	END

	-- Filtering with Start date
	IF @StartDate IS NOT NULL
	BEGIN
		SET @WHERE = @WHERE + '
		AND		CONVERT(DATE,pi.ImportDate) >=  CONVERT(DATE,'''+CAST(@StartDate AS VARCHAR(100))+''')
		'
	END

	-- Filtering with End date
	IF @EndDate IS NOT NULL
	BEGIN
		SET @WHERE = @WHERE + '
		AND		CONVERT(DATE,pi.ImportDate) <=  CONVERT(DATE,'''+CAST(@EndDate AS VARCHAR(100))+''')
		'
	END



	-- Fetching the Total Count 
	SET @SQL = @COUNTPROJECTION + @FROM + @WHERE
	INSERT @TotalCount
	EXEC(@SQL)	

	-- Sorting the list based on the sort property and order.
	IF LEN(@SortProperty) > 0 AND EXISTS(SELECT 1 FROM @GridCols WHERE ColumnName = @SortProperty)
	BEGIN
		SET @WHERE = @WHERE + '
		ORDER BY '+ @SortProperty + ' ' +@SortOrder+ '
		'		
	END
	ELSE
	BEGIN
		SET @WHERE = @WHERE + '
		ORDER BY Id '+ @SortOrder + '
		'
	END
	SET @SQL = ''
	SET @PROJECTION = @PROJECTION + 
					  ','+ CAST((SELECT  ISNULL(TotalCount,0) FROM @TotalCount)AS VARCHAR(100))+' AS TotalCount
	'

	--Applying Pagination
	IF @Page IS NOT NULL AND @PageSize IS NOT NULL
	BEGIN
		DECLARE @Offset INT = (CASE WHEN @Page = 0 THEN 0 ELSE  @Page-1 END)*@PageSize
		SET @PAGINATION = '
		OFFSET '+CAST(@Offset AS VARCHAR(10))+' ROWS
		FETCH NEXT '+CAST(@PageSize AS VARCHAR(10))+' ROWS ONLY
		'
	END
	IF @ReturnASJson = 1
	BEGIN
		SET @SQL = '
		DECLARE @Result NVARCHAR(MAX) = ''''
		SET @Result = ('	+
			@PROJECTION		+
			@FROM			+
			@WHERE			+
			@PAGINATION		+
		'	
		FOR JSON PATH)
		SELECT @Result AS Result
		'
	END
	ELSE
	BEGIN
		SET @SQL = @PROJECTION + @FROM + @WHERE + @PAGINATION
	END

	--PRINT(@SQL)
	EXEC (@SQL)

END
