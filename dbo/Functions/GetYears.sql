
CREATE FUNCTION [dbo].[GetYears] ()
RETURNS @retTable TABLE 
 (
  Id int,
  Description varchar(4)
  )
AS


BEGIN

	declare @yearFrom int;
	declare @yearTo int;
	select @yearTo=DATEPART(year,getdate())
	
	
	select @yearFrom=2009

	while @yearFrom <= @yearTo
	begin
		INSERT INTO @retTable (Id,Description) values (@yearTo,@yearTo)
		select @yearTo=@yearTo-1
	end
	
	RETURN 
END
