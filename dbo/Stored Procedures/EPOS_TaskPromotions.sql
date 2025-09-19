-- =============================================
-- Author:		Binu Jacob Scaria
-- Create date: 04-08-2022
-- Description:	Calling from EPOS_ApplyTask
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_TaskPromotions]
	-- Add the parameters for the stored procedure here
	@ClientId INT = 1,
	@Userid INT = 0
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
--DECLARE @Userid INT = 2500662,@ClientId INT = 16
--BEGIN TRY                                                        
--BEGIN TRAN  

DECLARE @UserTaskItem TABLE (UserTaskItemId INT,TaskCompleted INT,Quantity INT,TaskItemId INT,TaskId INT,TaskTypeId INT,TaskType VARCHAR(50), UserId INT,ValidSegment INT,ValidLoyaltyProfile INT,UsageCount INT)
DECLARE @Tasks TABLE (TaskId INT,TaskItemId INT,OfferValue float,TaskName nvarchar(500),OfferType nvarchar(20),RewardId INT,RewardName VARCHAR(150),RewardCostPrice Decimal(18,2),UsageLimit INT,MaxUsagePerMember INT,UsageCount INT)

DECLARE @TrxTypeIdTaskPoints INT,@TrxStatusIdCompleted INT, @TrxTypeIdReward INT,@TrxStatusIdStarted INT

SELECT @TrxTypeIdTaskPoints  = TrxTypeId FROM TrxType with(nolock) where ClientId = @ClientId AND Name = 'TaskPoints'
SELECT @TrxTypeIdReward  = TrxTypeId FROM TrxType with(nolock) where ClientId = @ClientId AND Name = 'Reward'

SELECT @TrxStatusIdStarted = TrxStatusId FROM TrxStatus with(nolock) WHERE [name]='Started' AND clientid = @ClientId
SELECT @TrxStatusIdCompleted = TrxStatusId FROM TrxStatus with(nolock) WHERE [name]='Completed' AND clientid = @ClientId

IF ISNULL(@Userid,0) > 0
BEGIN
	INSERT INTO @UserTaskItem 
	SELECT ut.Id UserTaskItemId,TaskCompleted,pti.Quantity,pti.Id As TaskItemId,pti.TaskId,tt.Id TaskTypeId ,tt.Name TaskType,ut.UserId, 1 ValidSegment , 1 ValidLoyaltyProfile,0 UsageCount
	FROM UserTaskItem ut with(nolock) 
	INNER JOIN PromotionTasksItem pti with(nolock) on ut.TaskItemId = pti.Id 
	INNER JOIN TaskType tt with(nolock) on pti.TaskTypeId = tt.Id
	WHERE ut.TargetAchieved = 0 and pti.Quantity <= ut.TaskCompleted And tt.ClientId = @ClientId AND ut.userid = @Userid 
END  
ELSE
BEGIN
	INSERT INTO @UserTaskItem 	
	SELECT ut.Id UserTaskItemId,TaskCompleted,Quantity,pti.Id As TaskItemId,pti.TaskId,tt.Id TaskTypeId ,tt.Name TaskType,ut.UserId, 1 ValidSegment , 1 ValidLoyaltyProfile,0 UsageCount
	FROM UserTaskItem ut with(nolock) 
	INNER JOIN PromotionTasksItem pti with(nolock) on ut.TaskItemId = pti.Id 
	INNER JOIN TaskType tt with(nolock) on pti.TaskTypeId = tt.Id
	WHERE ut.TargetAchieved = 0 and pti.Quantity <= ut.TaskCompleted And tt.ClientId = @ClientId
END

 
INSERT INTO @Tasks
SELECT DISTINCT pti.TaskId,pti.Id TaskItemId,pt.OfferValue,ISNULL(pt.Name,'') AS TaskName,pot.Name OfferType,ISNULL(pt.RewardId ,0) RewardId
,null RewardName ,0 RewardCostPrice,ISNULL(pt.UsageLimit,0)UsageLimit,ISNULL(pt.MaxUsagePerMember,0)MaxUsagePerMember,0 UsageCount
FROM PromotionTasks pt inner join PromotionTasksItem pti on pt.Id = pti.TaskId inner join PromotionOfferType pot on pt.OfferTypeId = pot.Id
inner join @UserTaskItem uti on pt.id = uti.TaskId


UPDATE T
SET T.RewardName = RI.RewardName,
T.RewardCostPrice = RIO.RewardCostPrice
FROM @Tasks T 
INNER JOIN RewardItems RI with(nolock) on T.RewardId = RI.RewardItemId
INNER JOIN RewardItemsOptions RIO with(nolock) ON RI.RewardItemId = RIO.RewardItemId
WHERE T.RewardId > 0

UPDATE T
SET T.ValidSegment = 0
FROM @UserTaskItem T
INNER JOIN TaskSegments TS with(nolock) on T.TaskId = TS.TaskId

UPDATE T
SET T.ValidSegment = 1
FROM @UserTaskItem T
INNER JOIN TaskSegments TS with(nolock) on T.TaskId = TS.TaskId
INNER JOIN SegmentUsers SU with(nolock) ON TS.SegmentId = SU.SegmentId
WHERE SU.UserId = T.UserId

DELETE @UserTaskItem WHERE ValidSegment = 0;

UPDATE T
SET T.ValidLoyaltyProfile = 0
FROM @UserTaskItem T
INNER JOIN TaskLoyaltyProfiles TL with(nolock) on T.TaskId = TL.TaskId

UPDATE T
SET T.ValidLoyaltyProfile = 1
FROM @UserTaskItem T
INNER JOIN TaskLoyaltyProfiles TL with(nolock) on T.TaskId = TL.TaskId
--INNER JOIN LoyaltyDeviceProfileTemplate LDPT on TL.LoyaltyProfileId	= LDPT.Id
INNER JOIN DeviceProfileTemplate DPT with(nolock) on TL.LoyaltyProfileId	= DPT.Id
INNER JOIN DeviceProfile DP with(nolock) on dpt.Id = dp.DeviceProfileId 
INNER JOIN Device D with(nolock) on dp.DeviceId = D.Id 
WHERE D.UserId = T.UserId

DELETE @UserTaskItem WHERE ValidLoyaltyProfile = 0;

UPDATE UT
SET UT.UsageCount = isnull([dbo].[TaskUsage]( UT.UserId,UT.TaskId),0)
FROM @UserTaskItem UT
INNER JOIN @Tasks TS on UT.TaskId = TS.TaskId
WHERE TS.MaxUsagePerMember > 0 AND ISNULL(UT.UsageCount,0) = 0

UPDATE @Tasks
SET UsageCount = isnull([dbo].[TaskUsage]( 0,TaskId),0)
WHERE ISNULL(UsageLimit,0) > 0 AND ISNULL(UsageCount,0) = 0


--SELECT * FROM @UserTaskItem 
--SELECT * FROM @Tasks

IF EXISTS (SELECT 1 FROM @Tasks)
BEGIN
	DECLARE @TaskItemCount INT = 0, @UserTaskItemCount INT = 0,@OfferValue float,@TaskName NVARCHAR(500),@OfferType NVARCHAR(20)
	DECLARE @RewardId INT,@RewardName VARCHAR(150),@RewardCostPrice Decimal(18,2),@RewardIdAndCostPrice NVARCHAR(100)='',@UsageLimit INT,@UsageCount INT,@MaxUsagePerMember INT,@MaxUsagePerMemberCount INT,@LimitCheckValid INT = 1

	DECLARE @AccountId INT,@DeviceId NVARCHAR(25),@SiteId INT,@AccountPointsBalance float,@NewTrxId INT,@NewAccountPointsBalance float
	DECLARE @TaskId INT,@MemberId INT
	DECLARE TaskCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
	SELECT TaskId,UserId FROM @UserTaskItem Group By TaskId,UserId                            
	OPEN TaskCursor                                                  
		FETCH NEXT FROM TaskCursor           
		INTO @TaskId ,@MemberId                       
		WHILE @@FETCH_STATUS = 0 
		BEGIN 


			SET @TaskItemCount = 0
			SET @UserTaskItemCount = 0
			SET @UsageLimit = 0
			SET @MaxUsagePerMember = 0

			SELECT	@TaskItemCount = count(TaskItemId), 
					@OfferValue = MAX(ISNULL(OfferValue,0)),
					@TaskName = MAX(ISNULL(TaskName,'')),
					@OfferType = MAX(ISNULL(OfferType,'')), 
					@RewardId = MAX(ISNULL(RewardId,0)),
					@RewardName = MAX(ISNULL(RewardName,'')),
					@RewardCostPrice= MAX(ISNULL(RewardCostPrice,0)),
					@UsageLimit =  MAX(ISNULL(UsageLimit,0)),
					@UsageCount = MAX(ISNULL(UsageCount,0)),
					@MaxUsagePerMember =  MAX(ISNULL(MaxUsagePerMember,0))
			FROM @Tasks WHERE Taskid = @TaskId

			IF @UsageCount > 0
			BEGIN
				SET @UsageCount = @UsageCount / ISNULL(@TaskItemCount,1);
			END

			IF @UsageLimit <= @UsageCount AND @UsageLimit > 0
			BEGIN
				SET @LimitCheckValid = 0
			END
			IF @MaxUsagePerMember > 0 AND @LimitCheckValid = 1
			BEGIN
				SELECT Top 1 @MaxUsagePerMemberCount = ISNULL(UsageCount,0)  FROM @UserTaskItem WHERE Taskid = @TaskId AND UserId = @MemberId

				IF @MaxUsagePerMemberCount> 0
				BEGIN
					SET @MaxUsagePerMemberCount = @MaxUsagePerMemberCount / ISNULL(@TaskItemCount,1)
				END

				IF @MaxUsagePerMember <= @MaxUsagePerMemberCount
				BEGIN
					SET @LimitCheckValid = 0
				END
			END
			--SET @LimitCheckValid = 0
			IF @LimitCheckValid = 1
			BEGIN
				SELECT @UserTaskItemCount = count(TaskItemId) FROM @UserTaskItem WHERE Taskid = @TaskId AND UserId = @MemberId

				IF isnull(@TaskItemCount,0) != isnull(@UserTaskItemCount,0) OR isnull(@UserTaskItemCount,0) = 0
				BEGIN
					PRINT '--------------------'
					PRINT 'TASK OFFER IN-VALID' 
					PRINT @TaskId 
					PRINT @MemberId  
					PRINT @OfferValue
					PRINT @TaskItemCount
					PRINT @UserTaskItemCount
					PRINT '--------------------'
				END
				ELSE IF isnull(@TaskItemCount,0) = isnull(@UserTaskItemCount,0)
				BEGIN
					--SELECT * FROM #Tasks
					select TOP (1) @AccountId = a.AccountId,@DeviceId = d.DeviceId,@SiteId = d.HomeSiteId,@AccountPointsBalance = ISNULL(PointsBalance,0)
					from [Account] a  WITH(NOLOCK)
						inner join [AccountStatus] ast WITH(NOLOCK) on a.AccountStatusTypeId = ast.AccountStatusId
						inner join [Device] d WITH(NOLOCK) on a.AccountId = d.AccountId
						inner join [DeviceProfile] dp WITH(NOLOCK) on d.id = dp.DeviceId
						inner join [DeviceProfileTemplate] dpt WITH(NOLOCK) on dpt.Id = dp.DeviceProfileId
						inner join [DeviceProfileTemplateType] dptt WITH(NOLOCK) on dpt.DeviceProfileTemplateTypeId = dptt.Id
					where  a.UserId = @MemberId and ast.Name = 'Enable' and dptt.Name = 'Loyalty' AND dptt.ClientId = @ClientId

					IF ISNULL(@AccountId,0) > 0 AND ISNULL(@OfferType,'') = 'Points'
					BEGIN
				
						PRINT '--------------------'
						PRINT 'TASK OFFER VALID POINTS' 
						PRINT @TaskId 
						PRINT @MemberId  
						PRINT @OfferValue
						PRINT @TaskItemCount
						PRINT @UserTaskItemCount
						PRINT '--------------------'

						UPDATE UT
						SET UT.TargetAchieved = 1,UT.UpdatedDatetime = GETDATE()
						FROM UserTaskItem UT
						INNER JOIN @UserTaskItem TI ON	UT.TaskItemId = TI.TaskItemId
						WHERE UT.UserId = @MemberId AND TI.TaskId = @TaskId AND UT.TargetAchieved = 0

						SET @NewAccountPointsBalance = ISNULL(@AccountPointsBalance,0) + ISNULL(@Offervalue,0)

						UPDATE Account SET  PointsBalance = @NewAccountPointsBalance WHERE AccountId  = @AccountId

						INSERT INTO TrxHeader(ClientId,DeviceId,TrxTypeId,TrxDate,SiteId,TerminalId,TerminalDescription,Reference,OpId,TrxStatusTypeId,TrxCommitDate, AccountPointsBalance)
						VALUES(@ClientId,@DeviceId,@TrxTypeIdTaskPoints,getdate(),@SiteId,'','', '','',@TrxStatusIdCompleted,GETDATE(), @NewAccountPointsBalance)
		
						SELECT @NewTrxId = Scope_identity();
						IF ISNULL(@NewTrxId,0)>0
						BEGIN
							INSERT INTO TrxDetail([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,PromotionItemId)
							VALUES ('1' , @NewTrxId ,1 ,'Task-' + CONVERT(Varchar(10),@TaskId) + '-' + @TaskName, 'Points',1,0,0,@Offervalue,0, @Offervalue, @TaskId)
						END
					END
					IF ISNULL(@AccountId,0) > 0 AND ISNULL(@OfferType,'') = 'Reward' AND ISNULL(@RewardId,0) > 0 AND ISNULL(@RewardCostPrice,0) > 0
					BEGIN

						IF ISNULL(@RewardCostPrice,0) > 0 AND ISNULL(@RewardId,0) > 0
						BEGIN
							SET @RewardIdAndCostPrice =  CONVERT(NVARCHAR(10),@RewardId) + '/' +  CONVERT(NVARCHAR(10),@RewardCostPrice)
						END

						PRINT '--------------------'
						PRINT 'TASK OFFER VALID REWARD' 
						PRINT @TaskId 
						PRINT @MemberId  
						PRINT @OfferValue
						PRINT @TaskItemCount
						PRINT @UserTaskItemCount
						PRINT '--------------------'

						UPDATE UT
						SET UT.TargetAchieved = 1,UT.UpdatedDatetime = GETDATE()
						FROM UserTaskItem UT
						INNER JOIN @UserTaskItem TI ON	UT.TaskItemId = TI.TaskItemId
						WHERE UT.UserId = @MemberId AND TI.TaskId = @TaskId AND UT.TargetAchieved = 0

						--UPDATE Account SET @AccountPointsBalance = ISNULL(PointsBalance,0) + @Offervalue, PointsBalance = ISNULL(PointsBalance,0) + @Offervalue WHERE AccountId  = @AccountId

						INSERT INTO TrxHeader(ClientId,DeviceId,TrxTypeId,TrxDate,SiteId,TerminalId,TerminalDescription,Reference,OpId,TrxStatusTypeId,TrxCommitDate, AccountPointsBalance)
						VALUES(@ClientId,@DeviceId,@TrxTypeIdReward,getdate(),@SiteId,'','', '','',@TrxStatusIdStarted,GETDATE(), @AccountPointsBalance)
		
						SELECT @NewTrxId = Scope_identity();
						IF ISNULL(@NewTrxId,0)>0
						BEGIN
							INSERT INTO TrxDetail([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,PromotionItemId,AuthorisationNr)
							VALUES ('1' , @NewTrxId ,1 ,'Task-' + CONVERT(Varchar(10),@TaskId) + '-' + @TaskName, 'Reward - ' + @RewardName,1,0,0,0,0, @RewardCostPrice, @TaskId,@RewardIdAndCostPrice)
						END
					END
				END

			END
			ELSE
			BEGIN
				PRINT 'LimitCheckValid'
				PRINT @TaskItemCount
				PRINT @UsageLimit
				PRINT @UsageCount
				PRINT @MaxUsagePerMember
				PRINT @MaxUsagePerMemberCount
			END
			FETCH NEXT FROM TaskCursor     
			INTO @TaskId ,@MemberId   
		END     
	CLOSE TaskCursor;    
	DEALLOCATE TaskCursor; 
END
--PRINT 'COMMIT'
--COMMIT TRAN
--END TRY                                                        
--BEGIN CATCH   
--	PRINT 'ERROR'      
--	PRINT ERROR_NUMBER() 
--	PRINT ERROR_SEVERITY()  
--	PRINT ERROR_STATE()
--	PRINT ERROR_PROCEDURE() 
--	PRINT ERROR_LINE()  
--	PRINT ERROR_MESSAGE()                                           
--    ROLLBACK TRAN                                                        
--END CATCH 
END
