CREATE PROC [DBHelper].[LanguageSpecificWidgitTranslation]
@ClientId int,
@translationGroupKeyPrefix varchar(50),
@LanguageCode varchar(2) = 'de',
@widgitName nvarchar(30),
@translationValue nvarchar(50),
@version int,
@widgitId int
AS
set xact_abort on;
BEGIN TRANSACTION;

IF NOT EXISTS(SELECT * FROM  [dbo].[Translations] WHERE ClientId = @ClientId AND Value = @translationValue AND TranslationGroupKey = @widgitName AND TranslationGroup = 'WidgitMetaData_' + @translationGroupKeyPrefix AND LanguageCode = @LanguageCode)
BEGIN

DECLARE @translationId int
DECLARE @metadataid int

INSERT INTO  [dbo].[Translations] (Version,[ClientId],[TranslationGroup],[LanguageCode],[Value],[TranslationGroupKey]) VALUES (@Version, @ClientId, 'WidgitMetaData_' + @translationGroupKeyPrefix, @LanguageCode, @translationValue, @widgitName);
END

SELECT @translationId = (SELECT TranslationId FROM  [dbo].[Translations] WHERE ClientId = @ClientId AND Value = @translationValue AND 
TranslationGroupKey = @widgitName
AND TranslationGroup = 'WidgitMetaData_' + @translationGroupKeyPrefix AND LanguageCode  = @LanguageCode );

select @metadataid = (select widgitMetadataid from widgitmetadata where [key] = 'widgitName' and widgitId = @widgitId)

INSERT INTO  [dbo].[WidgitMetaDataTranslation] ([WidgitMetaDataId],[TranslationId]) VALUES (@metadataId, @translationId);
COMMIT;
