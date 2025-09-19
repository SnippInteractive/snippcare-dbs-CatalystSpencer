 CREATE PROCEDURE [DBHelper].[Create_SystemListEntryFromScratch]
(
@LookupType varchar(50),
@Name varchar(75), 
@ClientId INT = 1
)
AS
BEGIN

DECLARE @SqlStatement varchar(2000) 
DECLARE @SqlStatement2 varchar(2000) 

Set @SqlStatement = 'INSERT INTO [' +  @LookupType  +  '] (Name,ClientId)
	values (  ''' + @Name + ''', ' +  Convert(varchar(2),@ClientId) + ')'
	
--PRINT @SqlStatement	
EXEC (@SqlStatement)
END
