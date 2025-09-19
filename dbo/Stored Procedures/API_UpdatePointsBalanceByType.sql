CREATE PROCEDURE [dbo].[API_UpdatePointsBalanceByType] (@ClientId int, @UserId int,  @Type nvarchar(100),
	@ConfirmationId nvarchar(500), @PointsDeducted decimal, @TrxType NVARCHAR(1000), @AdditionDetails NVARCHAR(max),  @Code INT OUTPUT, @TrxHeaderId INT OUTPUT )
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @SiteId INT,@ParentId INT, @SiteRef NVARCHAR(1000), 
		@DeviceId nvarchar(100),@TransactionId INT ,@TransactionTypeId INT, @TransactionStatusId INT, @TenderTypeId INT,
		@UserLoyaltyDataId INT, @CurrentPointBalance FLOAT

    DECLARE @TrxIdTable TABLE (TrxId INT)  


    Select @SiteId = SiteId from [Site] where Channel = @Type

	IF @SiteId is null
	BEGIN
		Select @SiteRef = Value from ClientConfig where [Key]='ReceiptHeadSiteRef' and ClientId=@ClientId
		Select @ParentId = SiteId from [Site] where SiteRef=@SiteRef and ClientId=@ClientId
		SELECT @SiteId = ISNULL(SiteId, 0) FROM [SITE] Where ClientId = @ClientId and ParentId = @ParentId
	END
	
	SELECT @CurrentPointBalance = PointsBalance FROM Account WHERE UserId = @UserId

	SELECT TOP 1 @DeviceId=DeviceId
    FROM Device         
    WHERE UserId = @UserId 
    
	SET @UserLoyaltyDataId = (SELECT UserLoyaltyDataID FROM [User] where UserId = @UserId)
	SET @TenderTypeId = (SELECT TenderTypeId FROM TenderType where [Name] = 'Points' and ClientId = @ClientId)
    SET @TransactionTypeId= (SELECT TrxTypeId FROM trxtype WHERE [name]= @TrxType AND ClientId = @ClientId)  
    SET @TransactionStatusId=(SELECT TrxStatusId FROM TrxStatus WHERE [name]='Completed' AND ClientId = @ClientId)  
  
    BEGIN TRY  
     BEGIN TRAN
	 
      INSERT INTO TrxHeader (ClientId, DeviceId, TrxTypeId, TrxDate, SiteId, TerminalId, TerminalDescription, Reference, OpId, TrxStatusTypeId, TerminalExtra3, TerminalExtra2, AccountPointsBalance)  
      OUTPUT INSERTED.[TrxId] INTO @TrxIdTable        
      VALUES (@ClientId, @DeviceId, @TransactionTypeId, GETDATE(), @SiteId, null, @AdditionDetails, @Type, '', @TransactionStatusId, '', @ConfirmationId, @CurrentPointBalance)  
       
      SET @TransactionId = (SELECT TrxId FROM @TrxIdTable)  
       
      INSERT INTO TrxDetail ([Version], TrxID, LineNumber, ItemCode, [Description], Quantity, [Value], EposDiscount, Points, PromotionId, PromotionalValue, LoyaltyDiscount)  
      VALUES ('1', @TransactionId, 1, @ConfirmationId, @Type, 1, 0, 0, (@PointsDeducted * -1), NULL, NULL, 0)  
      
	  INSERT INTO TrxPayment ([Version], TrxID, TenderTypeId, TenderAmount, Currency, TenderDeviceId, ExtraInfo)
	  VALUES ('1', @TransactionId, @TenderTypeId, @PointsDeducted, '', @DeviceId, @ConfirmationId)

	  EXEC TriggerActionsBasedOnTransactionHit @ClientId, @UserId, @TransactionId
	  
     -- audit the account table  
     EXEC Insert_Audit 'U', @UserId, @SiteId, 'Account', @Type, @PointsDeducted, @PointsDeducted
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
