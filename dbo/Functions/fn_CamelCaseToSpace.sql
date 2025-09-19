CREATE function  [dbo].[fn_CamelCaseToSpace] (@x varchar(500)) RETURNS varchar(500)
AS
BEGIN
	DECLARE @y varchar(500)
		, @z int
		, @i int
		, @a varchar(2)
		, @b int
		, @c int
		, @d int
	SELECT	@y = ''
		, @z = datalength(@x)
		, @i = 1
	WHILE	@i <= @z
	BEGIN	SELECT @a = substring(@x, @i, 1)
		SET @b = ascii(@a)
		IF @i > 1
		BEGIN	SELECT	@c = ascii(substring(@x, @i - 1, 1))
				, @d = ascii(substring(@x, @i + 1, 1))
			IF @b BETWEEN 65 AND 90			-- Uppercase characters
			BEGIN	IF @c NOT BETWEEN 65 AND 90 AND @c NOT IN (36, 45, 95) -- the "-" (hyphen)
					SET @y = @y + ' '
				IF @d NOT BETWEEN 65 AND 90 AND @d NOT IN (36, 45, 95) -- the "-" (hyphen)
					SET @y = @y + ' '			
			END
			ELSE IF  @b = 36 				-- the "$"
				SET @y = @y + ' '
			ELSE IF  @b = 46 						-- the "."
			BEGIN	IF 	@c NOT BETWEEN 48 AND 57
				AND	@d NOT BETWEEN 48 AND 57
				BEGIN   IF @d NOT BETWEEN 48 AND 57
						SET @a = @a + ' '
				END
			END
			ELSE IF @b BETWEEN 48 AND 57 -- Numbers
			BEGIN	IF @c NOT BETWEEN 48 AND 57 AND @c NOT IN (36, 46)
				OR ascii(substring(@x, @i + 1, 1)) NOT BETWEEN 48 AND 57
					SET @y = @y + ' '
			END
		END
		SELECT	@y = @y + @a
			, @i = @i + 1
	END
	SELECT	@y = ltrim(replace(replace(@y, '   ', ' '), '  ', ' '))
	RETURN (@y)
END
