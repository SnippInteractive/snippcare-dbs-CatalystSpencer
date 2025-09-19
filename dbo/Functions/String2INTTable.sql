


create   FUNCTION [dbo].[String2INTTable] 
 (
  @commaseperatedstring  varchar(1000)
 )
RETURNS @retTable TABLE 
 (
  code  int
 )
AS


BEGIN
	DECLARE @delimeter  char(1)
	DECLARE @tmpTxt  varchar(20)
	
	DECLARE @pos int

	SET @delimeter = ',' --default to comma delimited.
	SET @commaseperatedstring = LTRIM(RTRIM(@commaseperatedstring))+ @delimeter
	SET @pos = CHARINDEX(@delimeter, @commaseperatedstring, 1)

	IF REPLACE(@commaseperatedstring, @delimeter, '') <> ''
		BEGIN
			WHILE @Pos > 0
			BEGIN
				SET @tmpTxt = LTRIM(RTRIM(LEFT(@commaseperatedstring, @Pos - 1)))
				IF @tmpTxt <> ''
				BEGIN
					INSERT INTO @retTable (code) VALUES (cast (@tmpTxt as int)) 
				END
				SET @commaseperatedstring = RIGHT(@commaseperatedstring, LEN(@commaseperatedstring) - @Pos)
				SET @Pos = CHARINDEX(',', @commaseperatedstring, 1)

			END
		END	
	RETURN 
END

