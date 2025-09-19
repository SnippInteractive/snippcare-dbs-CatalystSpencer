CREATE PROCEDURE [DBHelper].[Create_SystemListEntry] 
(
@LegacyLookupType varchar(50) = 'ADDRESS_CATEGORY',
@LookupType varchar(50) = 'AddressType',
@ClientId INT = 1
)
AS
BEGIN
DECLARE @SqlStatement varchar(1000)

Set @SqlStatement = '
    SET IDENTITY_INSERT ' + @LookupType + ' ON
     
	INSERT INTO [' +  @LookupType  +  '] (' +   @LookupType  + 'Id , Name,ClientId)
	select lt.Code, lt.Description, ' +  Convert(varchar(2),@ClientId) + '
	from 
	(select l.*,n.Language,n.Description from [LoebSPSProd-20120529].dbo.lookup l inner join [LoebSPSProd-20120529].dbo.lookupI8n n on n.lookupid = l.lookupid 
	where l.lookuptype = ''' + @LegacyLookupType + ''' and n.Language = ''en'' and ClientId = ' +  Convert(varchar(2),@ClientId) + ' and [Description] is not null and [Description] <> '''') as lt order by lt.Code asc'

--PRINT @SqlStatement	
EXEC (@SqlStatement)
	
END
