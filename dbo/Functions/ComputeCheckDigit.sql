CREATE FUNCTION [dbo].[ComputeCheckDigit] (@InString varchar(50))
RETURNS varchar(1)
AS
BEGIN
    DECLARE @CheckDigit varchar(1);
    WITH numbers(seqnum) AS
    (
        SELECT 1 AS seqnum UNION ALL
        SELECT seqnum+1 AS seqnum FROM numbers
        WHERE seqnum <= LEN(@InString)
    )
    SELECT @CheckDigit = CHAR(48+(10-(SUM(CASE WHEN (seqnum % 2) = 1 THEN chr*2-9*(chr/5) ELSE chr END)%10))%10) FROM
    (
      SELECT ASCII(SUBSTRING(REVERSE(UPPER(@InString)),seqnum,1))-48 AS chr,seqnum
      FROM numbers
    ) a;
    RETURN @CheckDigit
END

