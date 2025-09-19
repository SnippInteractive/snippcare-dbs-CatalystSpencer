-- =============================================
-- Author:		Wei Liu
-- Create date: 07 Dec 2020
-- Description:	This procedure is to pay with points
-- =============================================
--SuccessCode
--------
--200 = Point deducted/redeemed
--------
--ErrorCodes
--------
--100 = InvalidUser, not an active/loyalty device
--101 = Not enough points
--500 = InternalServerError

CREATE PROCEDURE [dbo].[API_PaymentWithPoints]
@ClientId INT,
@DeviceId NVARCHAR(25), 
@ProductPoints float,
@ItemDescription NVARCHAR(200),
@ConfirmationId NVARCHAR(100),
@ExtraInfo NVARCHAR(100),
@Code INT OUTPUT,
@PointBalance float OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE 
	@AccountId INT,
	@UserId INT,
	@TransactionTypeId INT,
	@TransactionStatusId INT,
	@SiteId INT,
	@TerminalId NVARCHAR(20) = NULL, 
	@OpId NVARCHAR(50) = NULL,
	@TransactionId INT,
	@PointsValue FLOAT, -- source
	@Points FLOAT, --actual points calculation
	@PointsBalance FLOAT,
	@NewPointsBalance FLOAT

	
	DECLARE @TrxIdTable TABLE (TrxId INT)

	SELECT @UserId = userid from device where DeviceId = @DeviceId

	SET @PointBalance = 0

	--storing in a temp table to avoid multiple queries to the table
	SELECT DPTT.[Name] TemplateType,D.UserId,D.DeviceId,D.AccountId, u.SiteId INTO #UserDeviceDetail 
	FROM Device D 
	INNER JOIN [Site] S ON D.HomeSiteId = S.SiteId AND S.ClientId = @ClientId		
	INNER JOIN DeviceProfile DP ON D.Id = DP.DeviceId 
	INNER JOIN DeviceProfileTemplate DPT ON DPT.Id = DP.DeviceProfileId --DeviceProfileId is the foreign key here from DeviceProfileTemplate table
	INNER JOIN DeviceProfileTemplateType DPTT ON DPTT.Id = DPT.DeviceProfileTemplateTypeId 
	INNER JOIN [User] u on u.userid = D.userid
	WHERE D.DeviceStatusId IN (SELECT DeviceStatusId FROM DeviceStatus WHERE [Name] IN ('Active','Ready') AND Clientid=@ClientId)
	AND DP.StatusId IN (SELECT DeviceProfileStatusId FROM DeviceProfileStatus WHERE [Name] IN ('Active','Ready') AND Clientid=@ClientId) 
	AND DPT.StatusId IN (SELECT Id FROM DeviceProfileTemplateStatus WHERE [Name] IN ('Active','Ready') AND Clientid=@ClientId)
	AND d.DeviceId = @DeviceId 

	-- user should have a valid active device and of loyalty type
	IF NOT EXISTS(SELECT 1 FROM #UserDeviceDetail					  
						   WHERE UserId = @UserId
					       AND TemplateType='Loyalty')	
	BEGIN
			SET @Code = 100 --InvalidUser
			SELECT @PointBalance = ISNULL(PointsBalance, 0) from Account where UserId = @UserId
		END
	ELSE
	BEGIN

		SELECT @PointsBalance = a.PointsBalance From Account a 
		where a.AccountStatusTypeId = 2 and a.Userid = @UserId
		-- Verify if the user have enough points to redeem
		IF (@PointsBalance < @ProductPoints)
		BEGIN
			SET @Code = 101  --Not enough points
			SELECT @PointBalance = PointsBalance from Account where UserId = @UserId
		END			  				  	
		ELSE 
		BEGIN		
			--get the deviceId & accountid of user
			SELECT TOP 1 @DeviceId=DeviceId,@AccountId=AccountId , @SiteId = SiteId			
			FROM #UserDeviceDetail					  
			WHERE UserId = @UserId
			AND TemplateType='Loyalty'
			
			SET @TransactionTypeId=(SELECT TrxTypeId FROM trxtype WHERE [name]='RedeemPoints' AND ClientId = @ClientId)
			SET @TransactionStatusId=(SELECT TrxStatusId FROM TrxStatus WHERE [name]='Completed' AND ClientId = @ClientId)
			
			BEGIN TRY
				BEGIN TRAN
					INSERT INTO TrxHeader (ClientId, DeviceId, TrxTypeId, TrxDate, SiteId, TerminalId, TerminalDescription, Reference, OpId, TrxStatusTypeId, TerminalExtra3)
					OUTPUT INSERTED.[TrxId] INTO @TrxIdTable						
					VALUES (@ClientId, @DeviceId, @TransactionTypeId, GETDATE(), @SiteId, @TerminalId, NULL, @ConfirmationId, @OpId, @TransactionStatusId, @ExtraInfo)
					
					SET @TransactionId = (SELECT TrxId FROM @TrxIdTable)
					
					INSERT INTO TrxDetail ([Version], TrxID, LineNumber, ItemCode, [Description], Quantity, [Value], EposDiscount, Points, PromotionId, PromotionalValue, LoyaltyDiscount)
					VALUES ('1', @TransactionId, 1, @ConfirmationId, @ItemDescription, 1, 0, 0, (@ProductPoints * -1), NULL, NULL, 0)
					
					-- update the user's account with latest points balance
					UPDATE Account 
					SET @PointsBalance = ISNULL(PointsBalance,0), 
					PointsBalance = (ISNULL(PointsBalance,0) - @ProductPoints),
					@NewPointsBalance = (ISNULL(PointsBalance,0) - @ProductPoints)
					WHERE  AccountId= @AccountId 
					AND UserId = @UserId

					-- audit the account table
					EXEC Insert_Audit 'U', @UserId, @SiteId, 'Account', 'PointsBalance',@NewPointsBalance,@PointsBalance

					DROP TABLE #UserDeviceDetail
					SET @Code = 200  --Success
					SELECT @PointBalance = PointsBalance from Account where UserId = @UserId				
				COMMIT
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK TRANSACTION
				END
				SET @Code = 500  --InternalServerError
			END CATCH
		END
	END
END
