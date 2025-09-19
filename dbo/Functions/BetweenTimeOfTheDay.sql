
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[BetweenTimeOfTheDay] 
(
	-- Add the parameters for the function here
	@StartTime time(7),
	@EndTime time(7),
	@TimeToEvaluate time(7)
)
RETURNS bit
AS
BEGIN
	if (@StartTime is not null and @EndTime is not null and @TimeToEvaluate is not null)
	BEGIN
		if(@TimeToEvaluate>=@StartTime and @TimeToEvaluate<=@EndTime)
		BEGIN
			return 1;
		END
		IF(@EndTime<@StartTime)
		BEGIN
			IF(@EndTime>=@TimeToEvaluate or @StartTime<=@TimeToEvaluate)
			BEGIN
				return 1;
			END
		END
	END
	
	return 0;
END
