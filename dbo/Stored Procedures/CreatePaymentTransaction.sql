-- =============================================
-- Author:		Abdul Wahab
-- Create date: 2022-04-06
-- Description:	Create payment transaction. This will create an entry in TrxHeader, TrxDetail & TrxPayment,
-- =============================================
--DECLARE @MessageType NVARCHAR(25),
--@Reference NVARCHAR(100)
--EXEC CreatePaymentTransaction 1,1404613,'EFT','',100,'','marketing',@messagetype OUTPUT, @Reference OUTPUT
--SELECT @MessageType
--SELECT @Reference

--Modified by: Abdul Wahab
--Modification date: 2022-05-05
--Description: Added a default currency based on member country

--Modified by: Abdul Wahab
--Modification date: 2022-05-24
--Description: added duplicate check. Note: storing the clienttransactionId that will be passed by the API
--             from consumers and storing in BatchId field in TrxHeader			

--Modified by: Abdul Wahab
--Modification date: 2022-06-29
--Description: if payment type is EFT then the status should be HOLD as it has to go through SSO-2FA

--Modified by: Abdul Wahab
--Modification date: 2022-07-19
--Description: added cheque no in EPOSTrxId

CREATE PROCEDURE [dbo].[CreatePaymentTransaction]
@ClientId INT,
@MemberId INT,
@PaymentType NVARCHAR(50),
@AuthorizationNumber NVARCHAR(60)=NULL,
@PaymentAmount FLOAT,
@Currency NVARCHAR(6),
@ExtraInfo NVARCHAR(200),
@ClientTransactionId NVARCHAR(100),
@MessageType NVARCHAR(25) OUTPUT,
@Reference NVARCHAR(100) OUTPUT
	
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @DeviceId NVARCHAR(50),
	@DevicestatusId INT,
	@DeviceProfileTemplateTypeId INT,
	@TrxTypeRewardId INT,
	@TrxStatus INT,
	@PosDescription NVARCHAR(100) = null,
	@PosId NVARCHAR(20) = NULL,	
	@OpId NVARCHAR(50) = NULL,
	@TrxId INT,
	@PaymentTypeId INT,
	@ItemCode NVARCHAR(100) = (@PaymentType+'-'+@Currency),
	@UserSiteId INT,
	@CountryCode VARCHAR(10),
	@ChequeNo BIGINT
	
	IF ISNULL(@ClientTransactionId,'')<>'' AND EXISTS(SELECT 1 FROM TrxHeader WHERE BatchId=@ClientTransactionId)
	BEGIN
		SET @MessageType='DuplicateTransaction'
		RETURN
	END
	IF ISNULL(LTRIM(RTRIM(@Currency)),'')=''
	BEGIN
		SELECT @CountryCode = C.CountryCode FROM [Address] A JOIN UserAddresses UA ON A.AddressId=UA.AddressId 
		JOIN Country C ON C.CountryId = A.CountryId
		WHERE UserId=@MemberId
	
		IF @CountryCode='US'
		BEGIN
			SET @Currency='USD'
		END
		ELSE IF @CountryCode='CA'
		BEGIN
			SET @Currency='CAD'
		END
		ELSE
		BEGIN
			SET @MessageType='NoCountryFoundForMember'
			RETURN
		END
	END
	SET @Reference=LOWER(NEWID())
	
	SET @ItemCode = (@PaymentType+'-'+@Currency)
	

	SELECT @DevicestatusId= devicestatusid FROM devicestatus WHERE [name]='Active' AND clientid=@ClientId
	SELECT @DeviceProfileTemplateTypeId= Id FROM DeviceProfileTemplateType WHERE [Name]='Loyalty' and ClientId=@ClientId
	SELECT @TrxTypeRewardId= TrxTypeId FROM TrxType WHERE [Name]=(CASE WHEN @ExtraInfo='marketing' THEN 'MktFundsClaim' WHEN @ExtraInfo='Rebate' THEN 'Rebate' ELSE 'Reward' END) and ClientId=@ClientId
	SELECT @UserSiteId = SiteId FROM [User] WHERE UserId=@MemberId
	--if payment type is EFT then the status should be HOLD as it has to go through SSO-2FA
	SELECT @TrxStatus= TrxStatusId FROM TrxStatus WHERE [name]=(CASE WHEN @PaymentType='EFT' THEN 'Hold' ELSE 'Pending' END) AND Clientid = @ClientId
	SELECT @PaymentTypeId = TenderTypeId FROM TenderType WHERE [name]=@PaymentType AND ClientId = @ClientId

	SET @DeviceId= (SELECT TOP 1 D.DeviceId
					FROM Device d 							
					INNER JOIN DeviceProfile dp on d.Id=dp.DeviceId 
					INNER JOIN DeviceProfileTemplate dpt on dpt.Id=dp.DeviceProfileId 
					AND dpt.DeviceProfileTemplateTypeId = @DeviceProfileTemplateTypeId
					WHERE d.UserId = @MemberId AND d.DeviceStatusId=@DevicestatusId)
     
	IF ISNULL(@DeviceId,'')=''
	BEGIN
		SET @MessageType='InvalidMember'
		RETURN
	END

	ELSE IF @PaymentTypeId IS NULL
	BEGIN
		SET @MessageType='InvalidPaymentType'
		RETURN
	END
	
	IF @PaymentType='Cheque'
	BEGIN
		SELECT @ChequeNo=MAX(ISNULL(TH.EPosTrxId,0))+1 FROM TrxHeader TH INNER JOIN TrxPayment TP
		ON TH.TrxId = TP.TrxId
		WHERE TP.TenderTypeId=@PaymentTypeId
	END

	DECLARE @TrxHeaderInserted AS TABLE (TrxId INT);
	BEGIN TRY
		BEGIN TRAN
			INSERT TrxHeader
			(ClientId,DeviceId,TrxTypeId,TrxDate,SiteId,TerminalId,TerminalDescription,BatchId,Reference,OpId,TrxStatusTypeId,TrxCommitDate, EposTrxId)
			OUTPUT Inserted.TrxId INTO @TrxHeaderInserted
			VALUES      
			(@ClientId,@DeviceId,@TrxTypeRewardId,GETDATE(),@UserSiteId,@PosId,@PosDescription,@ClientTransactionId,@Reference,@OpId,@Trxstatus,GETDATE(),@ChequeNo);

			SELECT @TrxId = TrxId FROM @TrxHeaderInserted

			INSERT TrxDetail
			([Version], TrxID,LineNumber,ItemCode,[DESCRIPTION],Anal1,Anal2,Quantity,[VALUE],Points)--,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10,Anal11,Anal12,Anal13,Anal14,Anal15)
			VALUES ('1', @TrxId,1,@ItemCode,@ExtraInfo,@PaymentType,@Currency,1,@PaymentAmount,0);
		
			INSERT TrxPayment 
			([Version],TrxId,TenderTypeId,TenderAmount,Currency,ExtraInfo,AuthNr)
			VALUES(1, @TrxId, @PaymentTypeId, @PaymentAmount, @Currency, @ExtraInfo,@AuthorizationNumber)

		COMMIT 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION				
		SET @MessageType='InternalServerError'
		PRINT ERROR_Message()
		INSERT INTO [Audit] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,SiteId)
			Values (1,@MemberId,@ItemCode, @PaymentTypeId, @ExtraInfo, GETDATE(), @MemberId,'Failed, Can not create a payment transaction.',@UserSiteId)
			
	END CATCH
END
