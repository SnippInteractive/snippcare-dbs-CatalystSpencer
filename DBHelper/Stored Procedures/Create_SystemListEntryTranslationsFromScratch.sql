 CREATE PROCEDURE [DBHelper].[Create_SystemListEntryTranslationsFromScratch]
(
@LookupType varchar(50),
@Name varchar(75),
@TranslationValue varchar(75),
@LanguageCode char(2) = 'en',
@ClientId INT = 1
)
AS
BEGIN

DECLARE @SqlStatement varchar(2000)  
DECLARE @SqlStatement2 varchar(2000)  

 
SET @SqlStatement = 'INSERT INTO Translations (ClientId, TranslationGroup, LanguageCode, Value, TranslationGroupKey)
select ' +  Convert(varchar(2),@ClientId) + ', ''' + @LookupType + 'SystemList'', ''' + @LanguageCode + ''', ''' + @TranslationValue +  ''',''' +  @Name + ''''


--PRINT @SqlStatement
EXEC (@SqlStatement)

SET @SqlStatement2 = 'INSERT INTO ' + @LookupType + 'Translation  (' +  @LookupType  + 'Id , translationid)
select  ett.' + @LookupType + 'Id, ett.TranslationId
from 
(
  select ' + @LookupType + 'Id  ,t.* from ' + @LookupType + ' et join Translations t on t.TranslationGroupKey = et.Name 
  where t.LanguageCode =  '''  +  @LanguageCode + '''  and t.TranslationGroup = ''' + @LookupType + 'SystemList'' 
) as ett'


--PRINT @SqlStatement2
EXEC (@SqlStatement2)

END
