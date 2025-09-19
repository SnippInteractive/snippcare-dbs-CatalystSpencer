CREATE PROCEDURE [dbo].[RedeemPoints]  
@ClientId INT,  
@UserId INT,  
@ProductId NVARCHAR(100),   
@ItemCode NVARCHAR(1000),  
@ProductPoints DECIMAL(10,2),  
@ItemDescription NVARCHAR(50),  
@ConfirmationId NVARCHAR(max),  
@ImageUrl NVARCHAR(max),  
@Qty INT=1,  
@Code INT OUTPUT,  
@TrxHeaderId INT OUTPUT  
AS  
BEGIN  
   
 SET NOCOUNT ON;  
   
 DECLARE   
 @DeviceId NVARCHAR(50),  
 @AccountId INT,  
 @TransactionTypeId INT,  
 @TransactionStatusId INT,  
 @SiteId INT,  
 @TerminalId NVARCHAR(20) = NULL,   
 @OpId NVARCHAR(50) = NULL,  
 @TransactionId INT,  
 @PointsValue FLOAT, -- source  
 @Points FLOAT, --actual points calculation  
 @PointsBalance FLOAT,  
 @NewPointsBalance FLOAT,  
 @OrderIdPrefix NVARCHAR(50), -- this will mainly have the SKU Id   
 @CurrentPointBalance FLOAT



 IF EXISTS(SELECT TOP 1 [VALUE] FROM ClientConfig WITH (NOLOCK) WHERE [Key]='OrderFulfillmentProvider' AND ISNULL([VALUE],'') <> '')  
 BEGIN  
  SET @OrderIdPrefix = (SELECT [value] FROM OpenJson(  
  (SELECT TOP 1 [VALUE] FROM ClientConfig WHERE [Key]='OrderFulfillmentProvider')  
  ) WHERE [key]='OrderIdPrefix')  
 END  
   
 DECLARE @TrxIdTable TABLE (TrxId INT)  
  
 --storing in a temp table to avoid multiple queries to the table  
 SELECT DPTT.[Name] TemplateType,D.UserId,D.DeviceId,D.AccountId, u.SiteId, a.PointsBalance INTO #UserDeviceDetail   
 FROM Device D WITH (NOLOCK)  
 INNER JOIN [Site] S WITH (NOLOCK) ON D.HomeSiteId = S.SiteId AND S.ClientId = @ClientId    
 INNER JOIN DeviceProfile DP WITH (NOLOCK) ON D.Id = DP.DeviceId   
 INNER JOIN DeviceProfileTemplate DPT WITH (NOLOCK) ON DPT.Id = DP.DeviceProfileId --DeviceProfileId is the foreign key here from DeviceProfileTemplate table  
 INNER JOIN DeviceProfileTemplateType DPTT WITH (NOLOCK) ON DPTT.Id = DPT.DeviceProfileTemplateTypeId   
 INNER JOIN [User] u WITH (NOLOCK) on u.userid = D.userid 
 INNER JOIN Account a WITH(NOLOCK) on a.UserId = u.UserId
 WHERE D.DeviceStatusId IN (SELECT DeviceStatusId FROM DeviceStatus WHERE [Name] IN ('Active','Ready') AND Clientid=@ClientId)  
 AND DP.StatusId IN (SELECT DeviceProfileStatusId FROM DeviceProfileStatus WHERE [Name] IN ('Active','Ready') AND Clientid=@ClientId)   
 AND DPT.StatusId IN (SELECT Id FROM DeviceProfileTemplateStatus WHERE [Name] IN ('Active','Ready') AND Clientid=@ClientId)  
 AND u.UserId=@UserId  
  
 -- user should have a valid active device and of loyalty type  
 IF NOT EXISTS(SELECT 1 FROM #UserDeviceDetail         
         WHERE UserId = @UserId  
            AND TemplateType='Loyalty')   
 BEGIN  
   SET @Code = 100 --InvalidUser  
  END  
 ELSE  
 BEGIN  
  
  SELECT @PointsBalance = a.PointsBalance From Account a WITH (NOLOCK)  
  join  #UserDeviceDetail udd WITH (NOLOCK) on udd.deviceId = a.extRef  
  where a.AccountStatusTypeId = (SELECT AccountStatusId FROM AccountStatus WITH (NOLOCK) WHERE [name]='Enable' AND ClientId = @ClientId) and a.Userid = @UserId and udd.TemplateType='Loyalty'  
  -- Verify if the user have enough points to redeem  
  IF (@PointsBalance < @ProductPoints)  
  BEGIN  
   SET @Code = 101  --Not enough points  
  
  END              
  ELSE   
  BEGIN    
   --get the deviceId & accountid of user  
   SELECT TOP 1 @DeviceId=DeviceId,@AccountId=AccountId , @SiteId = SiteId, @CurrentPointBalance = PointsBalance     
   FROM #UserDeviceDetail         
   WHERE UserId = @UserId  
   AND TemplateType='Loyalty'  
     
   SET @TransactionTypeId=(SELECT TrxTypeId FROM trxtype WITH (NOLOCK) WHERE [name]='RedeemPoints' AND ClientId = @ClientId)  
   SET @TransactionStatusId=(SELECT TrxStatusId FROM TrxStatus WITH (NOLOCK) WHERE [name]='Completed' AND ClientId = @ClientId)  
  
   BEGIN TRY  
    BEGIN TRAN  
     INSERT INTO TrxHeader (ClientId, DeviceId, TrxTypeId, TrxDate, SiteId, TerminalId, TerminalDescription, Reference, OpId, TrxStatusTypeId, TerminalExtra3, TerminalExtra2, AccountPointsBalance)  
     OUTPUT INSERTED.[TrxId] INTO @TrxIdTable        
     VALUES (@ClientId, @DeviceId, @TransactionTypeId, GETDATE(), @SiteId, @TerminalId, null, @ItemDescription, @OpId, @TransactionStatusId, @ImageUrl, @ConfirmationId, @CurrentPointBalance)  
       
     SET @TransactionId = (SELECT TrxId FROM @TrxIdTable)  
       
     INSERT INTO TrxDetail ([Version], TrxID, LineNumber, ItemCode,Anal16, [Description], Quantity, [Value], EposDiscount, Points, PromotionId, PromotionalValue, LoyaltyDiscount)  
     VALUES ('1', @TransactionId, 1, @ItemCode, @ProductId, @ItemDescription, @Qty, 0, 0, (@ProductPoints * -1), NULL, NULL, 0)  
       
     IF @OrderIdPrefix IS NOT NULL  
     BEGIN  
      UPDATE TrxHeader SET TerminalDescription=(@OrderIdPrefix+(CAST (@TransactionId AS VARCHAR))) WHERE TrxId=@TransactionId  
     END  
	  -- update the user's account with latest points balance  
	 UPDATE Account   
	 SET @PointsBalance = ISNULL(PointsBalance,0),   
	 PointsBalance = (ISNULL(PointsBalance,0) - @ProductPoints),  
	 @NewPointsBalance = (ISNULL(PointsBalance,0) - @ProductPoints)  
	 WHERE  AccountId= @AccountId   
	 AND UserId = @UserId 
	 
	 EXEC TriggerActionsBasedOnTransactionHit @ClientId, @UserId, @TransactionId
   
     -- audit the account table  
     EXEC Insert_Audit 'U', @UserId, @SiteId, 'Account', 'PointsBalance',@NewPointsBalance,@PointsBalance  
  
     DROP TABLE #UserDeviceDetail  
     SET @TrxHeaderId = @TransactionId  
     SET @Code = 200  --Valid  
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
