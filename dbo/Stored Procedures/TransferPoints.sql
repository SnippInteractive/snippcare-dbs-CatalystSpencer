
--USE [CatalystBaselineDEV]
--GO
--/****** Object:  StoredProcedure [dbo].[TransferPoints]    Script Date: 26-Apr-22 12:19:15 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
-- =============================================
-- Author:		Abdul Wahab
-- Create date: 10 March 2021
-- Description:	This procedure is to transfer the points between members
-- =============================================


CREATE PROCEDURE [dbo].[TransferPoints]
@ClientId INT,
@FromMemberId INT,
@ToMemberId INT,
@PointsToTransfer DECIMAL(18,2),
@FromMemberItemCode NVARCHAR(30)='',
@ToMemberItemCode NVARCHAR(30)='',
@MessageType NVARCHAR(50)='' OUTPUT,
@Message NVARCHAR(500)='' OUTPUT,
@Success BIT OUTPUT,
@NewFromMemberPointsBalance DECIMAL(18,2) OUTPUT,
@NewToMemberPointsBalance DECIMAL(18,2) OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE 
	@FromMemberDeviceId NVARCHAR(50),
	@ToMemberDeviceId NVARCHAR(50),
	@FromMemberAccountId INT,
	@ToMemberAccountId INT,
	@FromMemberPointsBalance DECIMAL(18,2),
	@ToMemberPointsBalance DECIMAL(18,2),
	@TransactionTypeId INT,
	@TransactionStatusId INT,
	@SiteId INT,
	@TerminalId NVARCHAR(20) = NULL, 
	@OpId NVARCHAR(50) = NULL, 
	@Reference NVARCHAR(50) = NEWID(),
	@FromMemberTransactionId INT,
	@ToMemberTransactionId INT,
	@PointsToTransferNegative DECIMAL(18,2) = @PointsToTransfer*-1,
	@ToMemberUserSubType NVARCHAR(20),
	@goal_points INT,
	@goal_points_total INT,
	@ToMemberName NVARCHAR(250),
	@FromMemberName NVARCHAR(250)
	

	DECLARE @FromMemberTrxIdTable TABLE (TrxId INT)
	DECLARE @ToMemberTrxIdTable TABLE (TrxId INT)


	-- first we will verify input data is valid
	IF @FromMemberId=0 OR @ToMemberId=0 OR @PointsToTransfer<=0
	BEGIN
		SET @MessageType='InvalidInputData'
		SET @Message='Input value is invalid'
	END
	
	ELSE
	BEGIN
		--storing in a temp table to avoid multiple queries to the table
		SELECT DPTT.[Name] TemplateType,D.UserId,D.DeviceId,D.AccountId, A.PointsBalance,S.SiteId  INTO #UserDeviceDetail 
		FROM [User] U 
		INNER JOIN Device D ON D.UserId = U.UserId
		INNER JOIN Account A ON A.AccountId = D.AccountId
		INNER JOIN [Site] S ON D.HomeSiteId = S.SiteId AND S.ClientId = @ClientId		
		INNER JOIN DeviceProfile DP ON D.Id = DP.DeviceId 
		INNER JOIN DeviceProfileTemplate DPT ON DPT.Id = DP.DeviceProfileId --DeviceProfileId is the foreign key here from DeviceProfileTemplate table		
		INNER JOIN DeviceProfileTemplateType DPTT ON DPTT.Id = DPT.DeviceProfileTemplateTypeId 
		WHERE D.DeviceStatusId IN (SELECT DeviceStatusId FROM DeviceStatus WHERE [Name] IN ('Active') AND Clientid=@ClientId)
		AND DP.StatusId IN (SELECT DeviceProfileStatusId FROM DeviceProfileStatus WHERE [Name] IN ('Active') AND Clientid=@ClientId) 
		AND DPT.StatusId IN (SELECT Id FROM DeviceProfileTemplateStatus WHERE [Name] IN ('Active') AND Clientid=@ClientId)
		AND U.UserStatusId IN (SELECT UserStatusId FROM UserStatus WHERE [Name] IN ('Active','ActiveUnverifiedAddress') AND Clientid=@ClientId)
		AND U.UserId IN (@FromMemberId,@ToMemberId)
		
		SELECT TOP 1 @SiteId=SiteId, @FromMemberDeviceId=DeviceId,@FromMemberAccountId=AccountId, @FromMemberPointsBalance = PointsBalance			
		FROM #UserDeviceDetail					  
		WHERE UserId = @FromMemberId
		AND TemplateType='Loyalty'
			
		SELECT TOP 1 @ToMemberDeviceId=DeviceId,@ToMemberAccountId=AccountId , @ToMemberPointsBalance = PointsBalance			
		FROM #UserDeviceDetail					  
		WHERE UserId = @ToMemberId
		AND TemplateType='Loyalty'
		
		-- From member should have a valid active device and of loyalty type
		IF NOT EXISTS(SELECT 1 FROM #UserDeviceDetail					  
						   WHERE UserId = @FromMemberId
					       AND TemplateType='Loyalty')				  
		BEGIN
			SET @MessageType = 'InvalidFromMember'--InvalidUser
			SET @Message='From member is not a valid loyalty member or member/device is not active'
		END

		-- To member should have a valid active device and of loyalty type
		ELSE IF NOT EXISTS(SELECT 1 FROM #UserDeviceDetail					  
						   WHERE UserId = @ToMemberId
					       AND TemplateType='Loyalty')					  
					  
		BEGIN
			SET @MessageType = 'InvalidToMember'--InvalidUser
			SET @Message='To member is not a valid loyalty member or member/device is not active'
		END

		--verify if the member has enough points to transfer
		ELSE IF @FromMemberPointsBalance < @PointsToTransfer
		BEGIN
			SET @MessageType = 'NotEnoughPointsBalance'--InvalidUser
			SET @Message='Member doesn''t have enough points balance to transfer. Current points balance:'+ CAST(@FromMemberPointsBalance AS VARCHAR)
		END
		ELSE 
		BEGIN		
		
			SET @TransactionTypeId=(SELECT TrxTypeId FROM trxtype WHERE [name]='PointsTransfer' AND ClientId = @ClientId)
			SET @TransactionStatusId=(SELECT TrxStatusId FROM TrxStatus WHERE [name]='Completed' AND ClientId = @ClientId)
			
			BEGIN TRY
				BEGIN TRAN								
					--********************** Source member - START *******************************************-
					--if shelter, take name from extension table
					SET @ToMemberUserSubType=(select top 1 us.[Name] from [User] u inner join UserSubType us on u.UserSubTypeId = us.UserSubTypeId where u.userid = @ToMemberId)
					IF @ToMemberUserSubType = 'Shelter'
					BEGIN
						SELECT @ToMemberName =  PropertyValue from UserLoyaltyExtensiondata where UserLoyaltyDataId = (select top 1 UserLoyaltyDataId from [User] where userid = @ToMemberId) and PropertyName = 'name'				
					END
					ELSE
					BEGIN
						select @ToMemberName = FirstName + ' ' + LastName from PersonalDetails where PersonalDetailsId = (select top 1 PersonalDetailsId from [User] where userid = @ToMemberId)
					END

					INSERT INTO TrxHeader (ClientId, DeviceId, TrxTypeId, TrxDate, SiteId, TerminalId, TerminalDescription, Reference, OpId, TrxStatusTypeId)
					OUTPUT INSERTED.[TrxId] INTO @FromMemberTrxIdTable						
					VALUES (@ClientId, @FromMemberDeviceId, @TransactionTypeId, GETDATE(), @SiteId, @TerminalId, NULL, @Reference, @OpId, @TransactionStatusId)
					
					SET @FromMemberTransactionId = (SELECT TrxId FROM @FromMemberTrxIdTable)					

					--negative entry for the source member
					INSERT INTO TrxDetail ([Version], TrxID, LineNumber, ItemCode, [Description], Quantity, [Value], EposDiscount, Points, PromotionId, PromotionalValue, LoyaltyDiscount)
					VALUES ('1', @FromMemberTransactionId, 1, @FromMemberItemCode, 'Points transferred to ' + @ToMemberName, 1, 0, 0, @PointsToTransferNegative, NULL, NULL, 0)

					-- update the source member's account with latest points balance
					UPDATE Account 
					SET @NewFromMemberPointsBalance = (ISNULL(PointsBalance,0) - @PointsToTransfer), 
					PointsBalance = (ISNULL(PointsBalance,0) - @PointsToTransfer)					 
					WHERE  AccountId= @FromMemberAccountId
					AND UserId = @FromMemberId

					-- audit the account table
					EXEC Insert_Audit 'U', @FromMemberId, @SiteId, 'Account', 'PointsBalance',@NewFromMemberPointsBalance,@FromMemberPointsBalance
				
					--********************** Source member - END *******************************************-
					
					--********************** Destination member - START *******************************************-
					--if shelter, take name from extension table
					SET @ToMemberUserSubType=(select top 1 us.[Name] from [User] u inner join UserSubType us on u.UserSubTypeId = us.UserSubTypeId where u.userid = @FromMemberId)
					IF @ToMemberUserSubType = 'Shelter'
					BEGIN
						SELECT @FromMemberName =  PropertyValue from UserLoyaltyExtensiondata where UserLoyaltyDataId = (select top 1 UserLoyaltyDataId from [User] where userid = @FromMemberId) and PropertyName = 'name'				
					END
					ELSE
					BEGIN
						select @FromMemberName = FirstName + ' ' + LastName from PersonalDetails where PersonalDetailsId = (select top 1 PersonalDetailsId from [User] where userid = @FromMemberId)
					END

					INSERT INTO TrxHeader (ClientId, DeviceId, TrxTypeId, TrxDate, SiteId, TerminalId, TerminalDescription, Reference, OpId, TrxStatusTypeId)
					OUTPUT INSERTED.[TrxId] INTO @ToMemberTrxIdTable						
					VALUES (@ClientId, @ToMemberDeviceId, @TransactionTypeId, GETDATE(), @SiteId, @TerminalId, NULL, @Reference, @OpId, @TransactionStatusId)
					
					SET @ToMemberTransactionId = (SELECT TrxId FROM @ToMemberTrxIdTable)

					INSERT INTO TrxDetail ([Version], TrxID, LineNumber, ItemCode, [Description], Quantity, [Value], EposDiscount, Points, PromotionId, PromotionalValue, LoyaltyDiscount)
					VALUES ('1', @ToMemberTransactionId, 1, @ToMemberItemCode,  'Points transferred from '+@FromMemberName, 1, 0, 0, @PointsToTransfer, NULL, NULL, 0)					

					-- update the destination member's account with latest points balance
					UPDATE Account 
					SET @NewToMemberPointsBalance = ISNULL(PointsBalance,0)+ @PointsToTransfer, 
					PointsBalance = (ISNULL(PointsBalance,0) + @PointsToTransfer)					 
					WHERE  AccountId= @ToMemberAccountId
					AND UserId = @ToMemberId

					-- audit the account table
					EXEC Insert_Audit 'U', @ToMemberId, @SiteId, 'Account', 'PointsBalance',@NewToMemberPointsBalance,@ToMemberPointsBalance
				
					--********************** Destination member - END *******************************************-
					

					--To Link both Transactions - Update the InitialTransaction of Source & Destination Member

					UPDATE TrxHeader SET InitialTransaction=@ToMemberTransactionId WHERE TrxId=@FromMemberTransactionId
					UPDATE TrxHeader SET InitialTransaction=@FromMemberTransactionId WHERE TrxId=@ToMemberTransactionId

					--if shelter, update usergoals table
					SET @ToMemberUserSubType=(select top 1 us.[Name] from [User] u inner join UserSubType us on u.UserSubTypeId = us.UserSubTypeId where u.userid = @ToMemberId)
					IF @ToMemberUserSubType = 'Shelter'
					BEGIN
						IF EXISTS (select 1 from UserGoals Where userid = @ToMemberId and lower(goal_active) = 'y')
						BEGIN
							Select top 1 @goal_points = goal_points,@goal_points_total = points_total from UserGoals Where userid = @ToMemberId and lower(goal_active) = 'y'
							IF @goal_points_total<= @goal_points + @PointsToTransfer
							BEGIN
								Set @goal_points = @goal_points_total
							END
							ELSE
							BEGIN
								Set @goal_points = @goal_points + @PointsToTransfer
							END
							Update UserGoals Set goal_points = @goal_points  Where userid = @ToMemberId and lower(goal_active) = 'y'
						END						
					END


					DROP TABLE #UserDeviceDetail

					SET @Success=1
					
				COMMIT
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK TRANSACTION
				END
				SET @Success=0
				SET @MessageType='InternalServerError'				
				SET @Message=(SELECT  CAST (ERROR_NUMBER() AS VARCHAR)) +',' + (SELECT CAST (ERROR_SEVERITY() AS VARCHAR)) +',' + (SELECT CAST(ERROR_STATE() AS VARCHAR)) +',' + (SELECT ERROR_PROCEDURE())
							  +',' + (SELECT CAST (ERROR_LINE() AS VARCHAR)) +',' + (SELECT ERROR_MESSAGE())							  
			END CATCH
		END
	END

	print @MessageType
END
