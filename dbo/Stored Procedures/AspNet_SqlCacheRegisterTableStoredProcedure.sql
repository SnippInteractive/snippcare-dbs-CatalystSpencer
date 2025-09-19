CREATE PROCEDURE [dbo].[AspNet_SqlCacheRegisterTableStoredProcedure] 
             @tableName NVARCHAR(450) 
         AS
         BEGIN

         DECLARE @triggerName AS NVARCHAR(3000) 
         DECLARE @fullTriggerName AS NVARCHAR(3000)
         DECLARE @canonTableName NVARCHAR(3000) 
         DECLARE @quotedTableName NVARCHAR(3000) 
		
--Vivek Start --Added A
		 DECLARE @schemaName NVARCHAR(3000)
		IF(CHARINDEX('.',@tableName) <> 0) 
		BEGIN
			SET @schemaName = SUBSTRING(@tableName,0,CHARINDEX('.',@tableName))
			SET @tableName =  SUBSTRING(@tableName,CHARINDEX('.',@tableName) + 1,LEN(@tableName) - CHARINDEX('.',@tableName))
		END
--Vivek END A
		

         /* Create the trigger name */ 
         SET @triggerName = REPLACE(@tableName, '[', '__o__') 
         SET @triggerName = REPLACE(@triggerName, ']', '__c__') 
         SET @triggerName = @triggerName + '_AspNet_SqlCacheNotification_Trigger' 
         --Vivek Commented --SET @fullTriggerName = 'dbo[' + @triggerName + ']' 
		 IF(@schemaName IS NOT NULL)
			SET @fullTriggerName ='[' + @schemaName + '].[' + @triggerName + ']' 
		 ELSE
			SET @fullTriggerName = 'dbo.[' + @triggerName + ']' 

         /* Create the cannonicalized table name for trigger creation */ 
         /* Do not touch it if the name contains other delimiters */ 
         IF (CHARINDEX('.', @tableName) <> 0 OR 
             CHARINDEX('[', @tableName) <> 0 OR 
             CHARINDEX(']', @tableName) <> 0) 
             SET @canonTableName = @tableName 
         ELSE 
             SET @canonTableName = '[' + @schemaName + '].[' + @tableName + ']' 

		 /* First make sure the table exists */ 
         --Vivek Commented --IF (SELECT OBJECT_ID(@tableName, 'U')) IS NULL 
			               --BEGIN 
                           --  RAISERROR ('00000001', 16, 1) 
                           --  RETURN 
                           --END 
--Vivek Start --Added B
		 IF(@schemaName IS NULL)
			BEGIN
				IF (SELECT OBJECT_ID(@tableName, 'U')) IS NULL 
				BEGIN 
                   RAISERROR ('00000001', 16, 1) 
                   RETURN 
                END
			END
		 ELSE
			BEGIN
				IF (SELECT OBJECT_ID(@schemaName + '.' + @tableName, 'U')) IS NULL 
				BEGIN 
					RAISERROR ('00000001', 16, 1) 
					RETURN 
				END 
			END
		 
--Vivek End B
		 

         BEGIN TRAN
         /* Insert the value into the notification table */ 
         IF NOT EXISTS (SELECT tableName FROM dbo.AspNet_SqlCacheTablesForChangeNotification WITH (NOLOCK) WHERE tableName = @tableName) 
             IF NOT EXISTS (SELECT tableName FROM dbo.AspNet_SqlCacheTablesForChangeNotification WITH (TABLOCKX) WHERE tableName = @tableName) 
                 INSERT  dbo.AspNet_SqlCacheTablesForChangeNotification 
                 VALUES (@tableName, GETDATE(), 0)

         /* Create the trigger */ 
         SET @quotedTableName = QUOTENAME(@tableName, '''') 
         IF NOT EXISTS (SELECT name FROM sysobjects WITH (NOLOCK) WHERE name = @triggerName AND type = 'TR') 
             IF NOT EXISTS (SELECT name FROM sysobjects WITH (TABLOCKX) WHERE name = @triggerName AND type = 'TR') 
                 EXEC('CREATE TRIGGER ' + @fullTriggerName + ' ON ' + @canonTableName +'
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N' + @quotedTableName + '
                       END
                       ')
         COMMIT TRAN
         END
