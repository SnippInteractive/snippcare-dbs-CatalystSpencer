



--select [dbo].[fnSplit] ('1,0,1095')

CREATE FUNCTION [dbo].[fnSplit](
    @sInputList VARCHAR(15) -- List of delimited items
 ) 
RETURNS nvarchar(15)
AS
BEGIN

--declare @sInputList VARCHAR(15) = '0,0,1095'
Declare @sDelimiter nvarchar(1) =','
Declare @Yr int, @Mt int, @Dy int
Declare @YrPos int, @MtPos int, @DyPos int
select @YrPos = CHARINDEX(@sDelimiter,@sInputList,0) 
select @Yr=left (@sInputList,@YrPos-1) 
set @sInputList = right(@sInputList,len(@sInputList)-@YrPos)

select @MtPos = CHARINDEX(@sDelimiter,@sInputList,0) 
select @Mt=left (@sInputList,@MtPos-1) 
set @Dy = right(@sInputList,len(@sInputList)-@MtPos)


Declare @CompareDate nvarchar(10) =  convert(nvarchar(10),dateadd(day,-@Dy,dateadd(month,-@mt,dateadd(year,-@yr,GetDate()))),121)
RETURN @CompareDate 
END

