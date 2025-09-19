CREATE function [dbo].[getWeekDay]( @var_weeknum int, @var_weekday int)
returns datetime
as
BEGIN
 declare @cnt int
 declare @startDay int
 declare @DayDiffrence int 
 declare @ReturnDate datetime,@var_date datetime
 select @var_date=getdate()
 set @cnt = 1
 set @startday =  datepart(dw, dateadd(mm, datediff(mm, 0, @var_Date),0))
 set @DayDiffrence = @var_weekday - @startday
 set @ReturnDate = dateadd(mm, datediff(mm, 0, @var_date),0)
 
 if(@DayDiffrence > 0)
 begin
  set @ReturnDate = dateadd(d,@DayDiffrence,@ReturnDate)
  set @ReturnDate = dateadd(wk,@var_weeknum - 1,@ReturnDate)
 end
 else
 begin
  set @ReturnDate = dateadd(d,7 - (@DayDiffrence * -1),@ReturnDate)
  set @ReturnDate = dateadd(wk,@var_weeknum - 1,@ReturnDate)
 end
 
return @ReturnDate
END
