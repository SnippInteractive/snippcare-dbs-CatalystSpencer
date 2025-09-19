CREATE PROCEDURE dbo.AspNet_SqlCacheQueryRegisteredTablesStoredProcedure 
         AS
         SELECT tableName FROM dbo.AspNet_SqlCacheTablesForChangeNotification
