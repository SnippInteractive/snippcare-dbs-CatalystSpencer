CREATE PROCEDURE [DBHelper].[RebuildAllindexes] 
AS
BEGIN 
	--SET NOCOUNT ON
	
	DECLARE @szsql nvarchar(200), @idx_Name nvarchar(100), @TableName nvarchar(100)

	DECLARE TableCursor CURSOR FOR
	SELECT TABLE_NAME,IndexName  FROM information_schema.tables i join (select tablename,avg_fragmentation_in_percent,IndexName   from (
	SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName, 
	ind.name AS IndexName, indexstats.index_type_desc AS IndexType, 
	indexstats.avg_fragmentation_in_percent 
	FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
	INNER JOIN sys.indexes ind  
	ON ind.object_id = indexstats.object_id 
	AND ind.index_id = indexstats.index_id 
	WHERE indexstats.avg_fragmentation_in_percent > 3 and ind.name is not null
	--ORDER BY indexstats.avg_fragmentation_in_percent DESC
	) x where tablename  not like 'tmp%'
	group by tablename,avg_fragmentation_in_percent ,IndexName
		) x on i.table_name = x.tablename
		WHERE table_type = 'base table' and TABLE_SCHEMA = 'DBO'
		and TABLE_NAME not like '[_]%' 
		--and TABLE_NAME  in 		('Account','Device','DeviceProfile','TrxHeader','TrxDetail','PromotionStampCounter','VirtualStampCard')
		

	
	
	

	OPEN TableCursor

	FETCH NEXT FROM TableCursor INTO @TableName,@idx_Name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @szsql = 'ALTER INDEX [' + @idx_Name + '] ON [' + @TableName + '] REBUILD;'
		print @szsql
		EXEC sp_executesql @szsql

	--DBCC DBREINDEX(@TableName,' ',95)
	FETCH NEXT FROM TableCursor INTO @TableName,@idx_Name
	END

	CLOSE TableCursor

	DEALLOCATE TableCursor


END
