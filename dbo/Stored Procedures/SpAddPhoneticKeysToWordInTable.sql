
-- ===============================================================================================================================
-- Author:		Franca, Ulisses
-- Create date: 2013-02-14
-- Description:	This stored procedure Creates the PrimaryKey, AlternativeKey for the column that has a word,
--				Using the double metaphone algorithm.
--				Its a batch update sp, only updates @BatchSize elements at a time.
--
--				@WordTableName					- Its the name of the table where we want to create the keys
--				@WordColumnName					- The Column that holds the word to create the keys.
--				@KeysPrimaryColumnName			- The column that will hold the Primary key for the double metaphone algorithm.
--				@KeysAlternativeColumnName		- the column that will hold the alternative key for the double metaphone algorithm
--				@BatchSize						- The batch size for each turn.
--				@Catalog						- The catalog where the tble is.
--				@Schema							- The schema where the table is.
--
-- Dependicies: This stored procedure has a dependency on a CLR function [ComputeDoubleMetaphoneKeys] that implements he double 
--				metaphone algorithm.
-- ================================================================================================================================
CREATE PROCEDURE [dbo].[SpAddPhoneticKeysToWordInTable]
	-- Add the parameters for the stored procedure here
	@WordTableName					nvarchar(MAX), 
	@WordColumnName					nvarchar(MAX),
	@KeysPrimaryColumnName			nvarchar(MAX),
	@KeysAlternativeColumnName		nvarchar(MAX),
	@BatchSize						int,
	@Catalog						nvarchar(50)='Catalyst2Dev',
	@Schema							nvarchar(50)='dbo'
AS
DECLARE @numberRecordsToProcess int;
DECLARE @minRecord int;
DECLARE @sqlCommand nvarchar(MAX);
DECLARE @RecordsUpdated int;
DECLARE @TablePrimaryKeyCOlumnName nvarchar(100);
DECLARE @tmp nvarchar(150);
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--validate input
	IF (not EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES   
			WHERE TABLE_CATALOG = @Catalog 
				AND TABLE_SCHEMA = @Schema 
					AND TABLE_NAME = @WordTableName))
	BEGIN
		
			SET @tmp='Table not found: ['+@Catalog+'].['+@Schema+']['+@WordTableName+'] not found';
			RAISERROR (@tmp,10,    1); 
	END
	
	
    SET @sqlCommand = N'SELECT @numberRecordsToProcess = COUNT(*) FROM ' + @WordTableName  
	--get the total number records to process
    EXEC sp_executesql 
        @query = @sqlCommand, 
        @params = N'@numberRecordsToProcess INT OUTPUT', 
        @numberRecordsToProcess = @numberRecordsToProcess OUTPUT ;
        
    PRINT 'PersonalDetails Has records to process: '+cast(@numberRecordsToProcess as nvarchar(10));
	if(@numberRecordsToProcess>0)
	BEGIN
		--get the table primarykey name
		SELECT @TablePrimaryKeyCOlumnName=column_name
				FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
					WHERE OBJECTPROPERTY(OBJECT_ID(constraint_name), 'IsPrimaryKey') = 1
						AND table_name = @WordTableName;
		PRINT @TablePrimaryKeyCOlumnName;
		IF(@TablePrimaryKeyCOlumnName is null or @TablePrimaryKeyCOlumnName='')
		BEGIN
			SET @tmp='No primary key found to table: '+@WordTableName;
			RAISERROR (@tmp,10,    1); 
		END

		set @minRecord=0;
		WHILE(@minRecord-@BatchSize<@numberRecordsToProcess)
		BEGIN
			begin transaction
			PRINT 'Start Batch update from: ' + cast(@minRecord as nvarchar(20)) +' to '+ cast((@minRecord+@BatchSize) as nvarchar(20));
			
			SET @sqlCommand ='update '+@WordTableName+'
								set '+@KeysPrimaryColumnName+'=(SELECT PrimaryKey FROM [ComputeDoubleMetaphoneKeys] ('+@WordColumnName+')),
								'+@KeysAlternativeColumnName+'=(SELECT SecondaryKey FROM [ComputeDoubleMetaphoneKeys] ('+@WordColumnName+'))
								where '+@TablePrimaryKeyCOlumnName+' 
									IN (
										select '+@TablePrimaryKeyCOlumnName+' FROM
											(select '+@TablePrimaryKeyCOlumnName+',Row_Number() over (order by '+@TablePrimaryKeyCOlumnName+' asc) as row_num from '+
								@WordTableName+') as tbl
											where  row_num>='+cast(@minRecord as nvarchar(10))+' and row_num<'+Cast((@minRecord+@BatchSize) as nvarchar(10))+'
										)';
										
			PRINT @sqlCommand;
			EXEC sp_executesql @query = @sqlCommand;
										
										
										
			PRINT 'End Batch update from: ' + cast(@minRecord as nvarchar(20)) +' to '+ cast((@minRecord+@BatchSize) as nvarchar(20));

			SET @minRecord=@minRecord+@BatchSize;
			Commit transaction
		END
		
		
		
	END
	PRINT 'End Processing....'
END
