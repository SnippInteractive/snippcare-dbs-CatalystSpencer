CREATE PROCEDURE dbo.AspNet_SqlCacheUnRegisterTableStoredProcedure 
             @tableName NVARCHAR(450) 
         AS
         BEGIN

         BEGIN TRAN
         DECLARE @triggerName AS NVARCHAR(3000) 
         DECLARE @fullTriggerName AS NVARCHAR(3000)
         SET @triggerName = REPLACE(@tableName, '[', '__o__') 
         SET @triggerName = REPLACE(@triggerName, ']', '__c__') 
         SET @triggerName = @triggerName + '_AspNet_SqlCacheNotification_Trigger' 
         SET @fullTriggerName = 'dbo.[' + @triggerName + ']' 

         /* Remove the table-row from the notification table */ 
         IF EXISTS (SELECT name FROM sysobjects WITH (NOLOCK) WHERE name = 'AspNet_SqlCacheTablesForChangeNotification' AND type = 'U') 
             IF EXISTS (SELECT name FROM sysobjects WITH (TABLOCKX) WHERE name = 'AspNet_SqlCacheTablesForChangeNotification' AND type = 'U') 
             DELETE FROM dbo.AspNet_SqlCacheTablesForChangeNotification WHERE tableName = @tableName 

         /* Remove the trigger */ 
         IF EXISTS (SELECT name FROM sysobjects WITH (NOLOCK) WHERE name = @triggerName AND type = 'TR') 
             IF EXISTS (SELECT name FROM sysobjects WITH (TABLOCKX) WHERE name = @triggerName AND type = 'TR') 
             EXEC('DROP TRIGGER ' + @fullTriggerName) 

         COMMIT TRAN
         END
