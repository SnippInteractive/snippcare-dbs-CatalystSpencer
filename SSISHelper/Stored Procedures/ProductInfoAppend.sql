CREATE PROCEDURE [SSISHelper].[ProductInfoAppend]
As
delete from productinfo where productid in (select productid collate Database_default  from ssishelper.ProductInfo_import )

INSERT INTO [ProductInfo]
           ([Version],[ClientID],[ProductID],[ProductDescription],[AnalysisCode1],[AnalysisCode2],[AnalysisCode3]
           ,[AnalysisCode4],[AnalysisCode5],[AnalysisCode6],[AnalysisCode7],[AnalysisCode8],[AnalysisCode9],[AnalysisCode10]
           ,[AnalysisCode11],[AnalysisCode12],[AnalysisCode13],[AnalysisCode14],[AnalysisCode15],[ImportDate])
     
           (SELECT  [Version],[ClientID],[ProductID],[ProductDescription],[AnalysisCode1],[AnalysisCode2],[AnalysisCode3],[AnalysisCode4]
      ,[AnalysisCode5],[AnalysisCode6],[AnalysisCode7],[AnalysisCode8],[AnalysisCode9],[AnalysisCode10],[AnalysisCode11]
      ,[AnalysisCode12],[AnalysisCode13],[AnalysisCode14],[AnalysisCode15],[ImportDate]
  FROM ssishelper.[ProductInfo_Import] )
  
  
  /*
Declare @AnalysisCode nvarchar(2), @ID nvarchar(2), @BigSQl NVARCHAR(MAX)

Declare LU_AC CURSOR FAST_FORWARD FOR
SELECT  top 20  right([name],len([Name])-12) as AC, id FROM [CatalystMail_AnalysisCodes] as Lu_AC
OPEN LU_AC
	FETCH NEXT FROM LU_AC 	INTO @AnalysisCode,@ID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @BigSQL = 'INSERT INTO [CatalystMail_SubAnalysisCode] ([Version],[CatalystMailAnalysisCodeId],[Value]) ' 
		SET @BigSQL = @BIGSQL + '(SELECT distinct 0,' + @ID + ',[AnalysisCode' + @AnalysisCode + '] FROM [ProductInfo] where [AnalysisCode' + @AnalysisCode + '] not in (  ' 
		SET @BigSQL = @BIGSQL + 'SELECT [Value] FROM [CatalystMail_SubAnalysisCode] where [CatalystMailAnalysisCodeId] = ''' + @ID + ''')) '
		print @bigsql
		EXEC (@bigsql)
	FETCH NEXT FROM LU_AC 	INTO @AnalysisCode,@ID
	end 
CLOSE LU_AC
DEALLOCATE LU_AC
*/