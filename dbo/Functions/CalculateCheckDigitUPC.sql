CREATE FUNCTION dbo.CalculateCheckDigitUPC
(
    @StringToCheck VARCHAR(8000)
)
RETURNS TABLE WITH SCHEMABINDING
RETURN
-- Calculate the check digit for a UPC
WITH Tally (n) AS
(
    SELECT TOP (LEN(@StringToCheck))
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    -- 8,000 row tally table
    FROM (VALUES (0),(0),(0),(0),(0),(0),(0),(0)) a(n)
    CROSS JOIN (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) b(n)
    CROSS JOIN (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) c(n)
    CROSS JOIN (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) d(n)
)
SELECT StringToCheck=@StringToCheck
    ,CheckDigit = (10 -
        SUM(CASE n%2 
            WHEN 1 THEN 3 
            ELSE 1 END * SUBSTRING(@StringToCheck, n, 1))
        % 10
        ) % 10 -- When check digit is 10 (remainder=0) use 0 as the check digit
FROM Tally;
