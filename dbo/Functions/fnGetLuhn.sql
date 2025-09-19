--select * from Device

--USE [CatalystTP]
--GO

--/****** Object:  UserDefinedFunction [dbo].[fnGetLuhn]    Script Date: 15-Jul-19 7:09:19 PM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


CREATE FUNCTION [dbo].[fnGetLuhn]
(
    @Luhn VARCHAR(7999)
)
RETURNS VARCHAR(8000)
AS
BEGIN
    IF @Luhn LIKE '%[^0-9]%'
        RETURN @Luhn

    DECLARE @Index SMALLINT,
        @Multiplier TINYINT,
        @Sum INT,
        @Plus TINYINT

    SELECT  @Index = LEN(@Luhn),
        @Multiplier = 2,
        @Sum = 0

    WHILE @Index >= 1
        SELECT  @Plus = @Multiplier * CAST(SUBSTRING(@Luhn, @Index, 1) AS TINYINT),
            @Multiplier = 3 - @Multiplier,
            @Sum = @Sum + @Plus / 10 + @Plus % 10,
            @Index = @Index - 1

    RETURN  @Luhn + CASE WHEN @Sum % 10 = 0 THEN '0' ELSE CAST(10 - @Sum % 10 AS CHAR) END
END



