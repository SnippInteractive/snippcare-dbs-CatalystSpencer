CREATE FUNCTION dbo.udf_GetGS1EAN13CheckDigit
(
  @ACode AS VARCHAR(12)
) 
RETURNS SMALLINT
AS BEGIN
  /*
    Author: Sergio Govoni
    Notes: Calculate the check-digit of a GS1 EAN13 code
    Version: 1.0
  */
  DECLARE
    @tmpCode AS VARCHAR(12)
    ,@tmpMulSup AS VARCHAR(8000)
    ,@tmp AS VARCHAR(8000)
    ,@i AS INT
    ,@j AS INT
    ,@z AS INT
    ,@SumDEven AS INT
    ,@SumDOdd AS INT
    ,@List AS VARCHAR(8000)
    ,@tmpList AS VARCHAR(8000)
    ,@CheckSum AS SMALLINT
 
  SET @SumDEven = 0
  SET @SumDOdd = 0
  SET @List = ''
  SET @tmpList = ''
  SET @tmp = ''
  SET @tmpCode = @ACode
 
  /* 0. List builder */
  SET @j = LEN(@tmpCode) + 1
  SET @i = 1
  WHILE (@i <= LEN(@tmpCode)) BEGIN SET @List = @List + '|' + LTRIM(RTRIM(STR(@j))) + ';' + SUBSTRING(@tmpCode, @i, 1) SET @j = (@j - 1) SET @i = (@i + 1) END /* 1. Add up the digits in even position */ SET @i = 1 SET @tmpList = @List WHILE (CHARINDEX('|', @tmpList) > 0)
  BEGIN
    SET @j = CHARINDEX('|', @tmpList)
    SET @z = CHARINDEX(';', @tmpList)
    IF (CAST(SUBSTRING(@tmpList, (@j + 1), (@z - (@j + 1))) AS INTEGER) % 2) = 0
    BEGIN
      SET @SumDEven = @SumDEven + CAST(SUBSTRING(@tmpList, (@z + 1), 1) AS INTEGER)
    END
    SET @tmpList = SUBSTRING(@tmpList, (@z + 2), LEN(@tmpList))
  END
 
  /* 2. Multiply the result of the previous step (the first step) to 3 (three) */
  SET @SumDEven = (@SumDEven * 3)
 
  /* 3. Add up the digits in the odd positions */
  SET @i = 1
  SET @tmpList = @List
  WHILE (CHARINDEX('|', @tmpList) > 0)
  BEGIN
    SET @j = CHARINDEX('|', @tmpList)
    SET @z = CHARINDEX(';', @tmpList)
    IF (CAST(SUBSTRING(@tmpList, (@j + 1), (@z - (@j + 1))) AS INTEGER) % 2) <> 0
    BEGIN
      SET @SumDOdd = @SumDOdd + CAST(SUBSTRING(@tmpList, (@z + 1), 1) AS INTEGER)
    END
    SET @tmpList = SUBSTRING(@tmpList, (@z + 2), LEN(@tmpList))
  END
 
  /* 4. Add up the results obtained in steps two and three */
  SET @CheckSum = (@SumDEven + @SumDOdd)
 
 /* 5. Subtract the upper multiple of 10 from the result obtained in step four */
  IF ((@CheckSum % 10) = 0)
  BEGIN
    /* If the result of the four step is a multiple of Ten (10), like
       Twenty, Thirty, Forty and so on,
       the check-digit will be equal to zero, otherwise the check-digit will be
       the result of the fifth step
    */
    SET @CheckSum = 0
  END
  ELSE BEGIN
    SET @tmpMulSup = LTRIM(RTRIM(STR(@CheckSum)))
    
    SET @i = 0
    WHILE @i <= (LEN(@tmpMulSup) - 1)
    BEGIN
      SET @tmp = @tmp + SUBSTRING(@tmpMulSup, @i, 1)
      IF (@i = LEN(@tmpMulSup) - 1)
      BEGIN
        SET @tmp = LTRIM(RTRIM(STR(CAST(@tmp AS INTEGER) + 1)))
        SET @tmp = @tmp + '0'
      END
      SET @i = (@i + 1)
    END
    SET @CheckSum = CAST(@tmp AS INTEGER) - @CheckSum
  END
  RETURN @CheckSum
END;