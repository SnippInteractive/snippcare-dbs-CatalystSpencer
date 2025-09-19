
CREATE FUNCTION [dbo].[TaskUsage]   
(  
 @Userid int =0,@TaskId int
)  
  
RETURNS INT  
AS  
BEGIN  
	Declare @TaskUsage INT = 0,@UsageLimit INT, @MaxUsagePerMember  INT
	
	SELECT @UsageLimit = UsageLimit ,@MaxUsagePerMember  = MaxUsagePerMember FROM Promotiontasks WHERE Id = @TaskId

IF ISNULL(@Userid,0) > 0
BEGIN
	IF @MaxUsagePerMember > 0
	BEGIN
		SET @TaskUsage = (SELECT Count (TaskItemId) FROM UserTaskItem uti Inner Join  PromotionTasksItem pti on uti.TaskItemId = pti.Id WHERE  TaskId = @TaskId AND TargetAchieved = 1 AND UserId = @Userid)
	END
	ELSE
	BEGIN
		SET @TaskUsage = 0 
	END
END
ELSE
BEGIN
	IF @UsageLimit > 0
	BEGIN
		SET @TaskUsage = (SELECT Count (TaskItemId) FROM UserTaskItem uti Inner Join  PromotionTasksItem pti on uti.TaskItemId = pti.Id WHERE  TaskId = @TaskId AND TargetAchieved = 1)
	END
	ELSE
	BEGIN
		SET @TaskUsage = 0 
	END
END

  RETURN ISNULL(@TaskUsage,0);    
      
End
