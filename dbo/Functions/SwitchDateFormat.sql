-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[SwitchDateFormat]
(
	-- Add the parameters for the function here
	@x nvarchar(15)

)
RETURNS nvarchar(15)
AS


BEGIN
	Declare @TheDate nvarchar(15)
	select @TheDate = right(@x,4) +'-'+ right(left(@x,5) ,2) +'-'+ left(@x,2) 
	-- Return the result of the function
	RETURN @TheDate 

END

