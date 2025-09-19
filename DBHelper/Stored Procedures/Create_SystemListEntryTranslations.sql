CREATE PROCEDURE [DBHelper].[Create_SystemListEntryTranslations]
(
@LegacyLookupType varchar(50) = 'Account_Status',
@LookupType varchar(50) = 'AccountStatus',
@LanguageCode char(2) = 'de',
@ClientId INT = 1
)
AS
BEGIN
DECLARE @SqlStatement varchar(2000)
DECLARE @SqlStatement2 varchar(2000)

SET @SqlStatement = '
insert into Translations (ClientId, TranslationGroup, LanguageCode, Value, TranslationGroupKey)
select  ' +  Convert(varchar(2),@ClientId) + ', ''' + @LookupType + 'SystemList'', ''' + @LanguageCode + ''', lt.Description, lt2.EngDescription
from
(select l.*,n.Language,n.Description from [LoebSPSProd-20120529].dbo.lookup l inner join [LoebSPSProd-20120529].dbo.lookupI8n n on n.lookupid = l.lookupid 
where l.lookuptype = ''' + @LegacyLookupType + ''' and n.Language = ''' + @LanguageCode + '''and ClientId = ' +  Convert(varchar(2),@ClientId) + ') as lt 
join (select n.LookupId,n.Description as EngDescription from [LoebSPSProd-20120529].dbo.lookup l inner join [LoebSPSProd-20120529].dbo.lookupI8n n on n.lookupid = l.lookupid 
where l.lookuptype = ''' + @LegacyLookupType + ''' and n.Language = ''en'' and ClientId = ' +  Convert(varchar(2),@ClientId) + ') as lt2 on lt.LookupId = lt2.LookupId'

--PRINT @SqlStatement
EXEC (@SqlStatement)

SET @SqlStatement2 = '
insert into ' + @LookupType + 'Translation  (' +  @LookupType  + 'Id , translationid)
select  ett.' + @LookupType + 'Id, ett.TranslationId
from 
(
  select ' + @LookupType + 'Id  ,t.* from ' + @LookupType + ' et join Translations t on t.TranslationGroupKey = et.Name 
  where t.LanguageCode =  '''  +  @LanguageCode + '''  and t.TranslationGroup = ''' + @LookupType + 'SystemList'' 
) as ett'


--PRINT @SqlStatement2
EXEC (@SqlStatement2)

END
