CREATE PROCEDURE [DBHelper].[Create_CultureInfo] 
(
@CultureInfo Culture_Info READONLY,
@ClientId int
)
AS

BEGIN


---COUNTRY
IF NOT EXISTS (select 1 from Country where Name = (select countryname from @CultureInfo) AND ClientId = @ClientId)
BEGIN
	INSERT INTO Country ([Name], [CountryCode], [ClientId],  [Display]) 
	SELECT (select CountryName from @CultureInfo), (select CountryCode from @CultureInfo), @ClientId, 1

	INSERT INTO Translations  (ClientId, TranslationGroup, LanguageCode, Value, TranslationGroupKey)
	SELECT @ClientId, 'Country', 'en', (select CountryName from @CultureInfo), (select  CountryName from @CultureInfo )
END


--NATIONALITY
IF NOT EXISTS (select 1 from Nationality where Name = (select Nationality from @CultureInfo) AND ClientId = @ClientId)
BEGIN
	INSERT INTO Nationality  ([Name], [ShortCode], [CountryId], [ClientId], [Display]) 
	SELECT (select Nationality from @CultureInfo), (select NationalityShortCode from @CultureInfo), (Select countryId from Country where ClientId=@ClientId and CountryCode = (select NationalityShortCode from @CultureInfo)), @ClientId, 1

	INSERT INTO Translations  (ClientId, TranslationGroup, LanguageCode, Value, TranslationGroupKey)
	SELECT @ClientId, 'Nationality', 'en', (select Nationality from @CultureInfo), (select Nationality from @CultureInfo)
END
  
-- LANGUAGE - Language may be present multiple times in input so dedupe
IF NOT EXISTS (select 1 from Language where Name = (select LanguageName from @CultureInfo) AND ClientId = @ClientId)
BEGIN
	INSERT INTO [Language] ([Name], [LanguageCode], [ClientId], [Display])  
	SELECT (select LanguageName from @CultureInfo), (select LanguageCode from @CultureInfo), @ClientId, 1
	
	INSERT INTO Translations (ClientId, TranslationGroup, LanguageCode, Value, TranslationGroupKey)
	SELECT @ClientId, 'Language', 'en',  (select LanguageName from @CultureInfo),  (select LanguageName from @CultureInfo)
END

-- CURRENCY - Currency may be present multiple times in input so dedupe
IF NOT EXISTS (select 1 from Currency where Code = (select CurrencyCode from @CultureInfo) AND ClientId = @ClientId)
BEGIN
	INSERT INTO CURRENCY ([Code], [Name], [ModifiedDate], [ClientId], [Display])
	SELECT (select CurrencyCode from @CultureInfo), (select CurrencyName from @CultureInfo), GetDATE(), @ClientID, 1

	INSERT INTO Translations (ClientId, TranslationGroup, LanguageCode, Value, TranslationGroupKey)
	SELECT @ClientId, 'Currency', 'en',  (select CurrencyName from @CultureInfo),  (select CurrencyName from @CultureInfo)
END
  
END
