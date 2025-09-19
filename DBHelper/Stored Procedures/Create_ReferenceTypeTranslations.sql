
CREATE PROCEDURE [DBHelper].[Create_ReferenceTypeTranslations] 
(
@TypeName nvarchar(100),
@TypeValues string_list2 READONLY,
@ClientId int,
@LanguageCode varchar(2)
)
AS

BEGIN

INSERT INTO Translations  (ClientId, TranslationGroup, LanguageCode, Value, TranslationGroupKey)
SELECT @ClientId, @TypeName, @LanguageCode, dbo.fn_CamelCaseToSpace(value), value2 From @TypeValues 
  
END
