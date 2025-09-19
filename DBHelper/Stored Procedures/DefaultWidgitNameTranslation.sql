
CREATE PROC [DBHelper].[DefaultWidgitNameTranslation]
@ClientId int,
@translationGroupKeyPrefix nvarchar(50),
@widgitName nvarchar(30),
@translationValue nvarchar(500),
@version int,
@widgitId int
AS
set xact_abort on;
BEGIN TRANSACTION;

print @widgitName; -- print all the widgits!

DECLARE @translationId int
DECLARE @metadataId int

IF NOT EXISTS(SELECT * FROM  [dbo].[Translations] WHERE ClientId  = @ClientId   AND TranslationGroupKey COLLATE DATABASE_DEFAULT = (@widgitName) COLLATE DATABASE_DEFAULT AND TranslationGroup COLLATE DATABASE_DEFAULT =  'WidgitMetaData_' + @translationGroupKeyPrefix COLLATE DATABASE_DEFAULT AND LanguageCode COLLATE DATABASE_DEFAULT  = 'en' COLLATE DATABASE_DEFAULT and UserEdited = 1)
BEGIN

IF NOT EXISTS(SELECT * FROM  [dbo].[Translations] WHERE ClientId  = @ClientId  AND Value COLLATE DATABASE_DEFAULT = @translationValue COLLATE DATABASE_DEFAULT AND TranslationGroupKey COLLATE DATABASE_DEFAULT = (@widgitName) COLLATE DATABASE_DEFAULT AND TranslationGroup COLLATE DATABASE_DEFAULT =  'WidgitMetaData_' + @translationGroupKeyPrefix COLLATE DATABASE_DEFAULT AND LanguageCode COLLATE DATABASE_DEFAULT  = 'en' COLLATE DATABASE_DEFAULT)
BEGIN

INSERT INTO [dbo].[Translations] (Version,[ClientId],[TranslationGroup],[LanguageCode],[Value],[TranslationGroupKey]) VALUES (@Version, @ClientId, 'WidgitMetaData_' + @translationGroupKeyPrefix, 'en', @translationValue, @widgitName);
END

SELECT @translationId = (SELECT  TranslationId FROM  [dbo].[Translations] WHERE ClientId  = @ClientId  AND Value COLLATE DATABASE_DEFAULT = @translationValue COLLATE DATABASE_DEFAULT AND TranslationGroupKey COLLATE DATABASE_DEFAULT = (@widgitName) COLLATE DATABASE_DEFAULT AND TranslationGroup COLLATE DATABASE_DEFAULT =  'WidgitMetaData_' + @translationGroupKeyPrefix COLLATE DATABASE_DEFAULT AND LanguageCode COLLATE DATABASE_DEFAULT  = 'en' COLLATE DATABASE_DEFAULT);

INSERT INTO [dbo].[WidgitMetaData] (Version, WidgitId, [Key], Value) VALUES (@version, @widgitId, 'widgitName', @widgitName);
SELECT @metadataId = scope_identity();
INSERT INTO [dbo].[WidgitMetaDataTranslation] ([WidgitMetaDataId],[TranslationId]) VALUES (@metadataId, @translationId);

 
END

COMMIT;
