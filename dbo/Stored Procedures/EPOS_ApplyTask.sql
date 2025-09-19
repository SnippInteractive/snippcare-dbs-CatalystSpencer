-- =============================================
-- Author:		Binu Jacob Scaria
-- Create date: 04-08-2022
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_ApplyTask]
	-- Add the parameters for the stored procedure here
	@MemberId INT,
	@TrxTypeId INT,
	@ClientId INT,
	@PromotionId INT
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

	IF (SELECT [Value] FROM ClientConfig WITH (NOLOCK) WHERE [Key]='EnableTaskProcess' AND ISNULL([VALUE],'') <> '' AND ClientId = @ClientId) = 'True'
	BEGIN

		DECLARE @TaskTypeId INT
		DECLARE @TASK TABLE (TaskItemId INT,TaskId INT,TaskItemTypeId INT,Quantity INT,MaxUsagePerMember INT ,UsageLimit INT)

		IF ISNULL(@TrxTypeId,0) > 0
		BEGIN
			SELECT @TaskTypeId = Id FROM TaskType Where Name = 'TrxType' And ClientId = @ClientId
			PRINT @TaskTypeId
			--DROP TABLE #TASK
			INSERT INTO @TASK
			SELECT pti.Id TaskItemId, pti.TaskId, pti.TaskItemTypeId,ISNULL(pti.Quantity,0)Quantity ,ISNULL(pt.MaxUsagePerMember,0)MaxUsagePerMember,ISNULL(pt.UsageLimit,0) UsageLimit
			FROM PromotionTasks pt inner join PromotionTasksItem pti on pt.Id = pti.TaskId
			WHERE pti.TaskTypeId = @TaskTypeId AND TaskItemTypeId = @TrxTypeId AND pt.Enabled  = 1  AND StartDate <= getdate() AND EndDate >= getdate()
		END
		IF ISNULL(@PromotionId,0) > 0
		BEGIN
			SELECT @TaskTypeId = Id FROM TaskType Where Name = 'Promotion' And ClientId = @ClientId
			--PRINT @TaskTypeId
			INSERT INTO @TASK
			SELECT pti.Id TaskItemId, pti.TaskId, pti.TaskItemTypeId,ISNULL(pti.Quantity,0)Quantity ,ISNULL(pt.MaxUsagePerMember,0)MaxUsagePerMember,ISNULL(pt.UsageLimit,0) UsageLimit
			FROM PromotionTasks pt inner join PromotionTasksItem pti on pt.Id = pti.TaskId
			WHERE pti.TaskTypeId = @TaskTypeId AND TaskItemTypeId = @PromotionId AND pt.Enabled  = 1  AND StartDate <= getdate() AND EndDate >= getdate()
		END
		--SELECT * FROM #TASK
		
		DECLARE @TaskItemId INT,@TaskId INT,@TaskItemTypeId INT,@Quantity INT,@MaxUsagePerMember INT ,@UsageLimit INT

		DECLARE TaskCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR        
		SELECT  TaskItemId, TaskId, TaskItemTypeId,Quantity,ISNULL(MaxUsagePerMember,0)MaxUsagePerMember,ISNULL(UsageLimit,0)UsageLimit FROM @TASK                             
		OPEN TaskCursor                                                  
		FETCH NEXT FROM TaskCursor           
		INTO @TaskItemId ,@TaskId ,@TaskItemTypeId ,@Quantity,@MaxUsagePerMember ,@UsageLimit                              
		WHILE @@FETCH_STATUS = 0 
		BEGIN 
				DECLARE @validSegment smallint = 1, @validProfile smallint = 1 , @validLimit smallint = 1,@UsageCount INT = 0
				--Check Segment Restriction  
				IF EXISTS (SELECT 1 FROM TaskSegments WHERE TaskId = @TaskId)
				BEGIN
					IF EXISTS (SELECT 1 FROM TaskSegments TS INNER JOIN SegmentUsers SU ON TS.SegmentId = SU.SegmentId WHERE TS.TaskId = @TaskId AND SU.UserId = @MemberId)
					BEGIN
						SET @validSegment = 1
					END
					ELSE
					BEGIN
						SET @validSegment = 0
						PRINT 'INVALID Segment'
					END
				END
				--Check LoyaltyProfiles Restriction 
				IF EXISTS (SELECT 1 FROM TaskLoyaltyProfiles WHERE TaskId = @TaskId)
				BEGIN
					IF EXISTS (SELECT 1 FROM TaskLoyaltyProfiles TL 
								INNER JOIN DeviceProfileTemplate DPT on TL.LoyaltyProfileId	= DPT.Id
								INNER JOIN DeviceProfile DP on dpt.Id = dp.DeviceProfileId 
								INNER JOIN Device D on dp.DeviceId = D.Id 
								WHERE D.UserId = @MemberId AND TL.TaskId = @TaskId)
					BEGIN
						SET @validProfile = 1
					END
					ELSE
					BEGIN
						SET @validProfile = 0
						PRINT 'INVALID Profile'
					END
				END
				--LIMIT checking
				IF ISNULL(@UsageLimit,0) > 0
				BEGIN
					SET @UsageCount = [dbo].[TaskUsage]( 0,@TaskId)
					IF ISNULL(@UsageCount,0) >= @UsageLimit
					BEGIN
						SET @validLimit = 0
						PRINT 'INVALID Limit'
					END
				END
				IF ISNULL(@MaxUsagePerMember,0) > 0 AND ISNULL(@validLimit,0) = 1
				BEGIN
					SET @UsageCount = [dbo].[TaskUsage]( @MemberId,@TaskId)
					IF ISNULL(@UsageCount,0) >= @MaxUsagePerMember
					BEGIN
						SET @validLimit = 0
						PRINT 'INVALID Limit/Member'
					END
				END

				IF ISNULL(@validSegment,0) = 1 AND ISNULL(@validProfile,0) = 1 AND ISNULL(@validLimit,0) = 1
				BEGIN
					IF EXISTS (SELECT 1  FROM UserTaskItem WHERE UserId = @MemberId AND TaskItemId = @TaskItemId AND TargetAchieved = 0)
					BEGIN
						--PRINT 'UPDATE'
						UPDATE UserTaskItem SET TaskCompleted = isnull(TaskCompleted,0) + 1 WHERE UserId = @MemberId AND TaskItemId = @TaskItemId AND TargetAchieved = 0
					END
					ELSE
					BEGIN
						--PRINT 'INSERT'
						INSERT INTO [UserTaskItem]([TaskItemId],[UserId],[TaskCompleted],[TargetAchieved],[CreatedDateTime])
						VALUES(@TaskItemId,@MemberId,1,0,getdate())
					END
				END
			FETCH NEXT FROM TaskCursor     
			INTO @TaskItemId ,@TaskId ,@TaskItemTypeId ,@Quantity  ,@MaxUsagePerMember ,@UsageLimit       
		END     
		CLOSE TaskCursor;    
		DEALLOCATE TaskCursor; 

		IF ISNULL(@MemberId,0) >0
		BEGIN
			exec [EPOS_TaskPromotions] @ClientId ,@MemberId
		END

	END
END
