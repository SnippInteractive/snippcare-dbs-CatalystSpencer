
CREATE   FUNCTION [dbo].[Codes2Table] 
 (
  @sourceText  varchar(8000)
 )
RETURNS @retTable TABLE 
 (
  code  varchar(20)
 )
AS


BEGIN
	DECLARE @delimeter  char(1)
	DECLARE @tmpTxt  varchar(20)
	
	DECLARE @pos int

	SET @delimeter = ',' --default to comma delimited.
	SET @sourceText = LTRIM(RTRIM(@sourceText))+ @delimeter
	SET @pos = CHARINDEX(@delimeter, @sourceText, 1)

	IF REPLACE(@sourceText, @delimeter, '') <> ''
		BEGIN
			WHILE @Pos > 0
			BEGIN
				SET @tmpTxt = LTRIM(RTRIM(LEFT(@sourceText, @Pos - 1)))
				IF @tmpTxt <> ''
				BEGIN
					INSERT INTO @retTable (code) VALUES (@tmpTxt) 
				END
				SET @sourceText = RIGHT(@sourceText, LEN(@sourceText) - @Pos)
				SET @Pos = CHARINDEX(',', @sourceText, 1)

			END
		END	
	RETURN 
END

