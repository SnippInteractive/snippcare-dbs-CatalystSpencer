-- =============================================
-- Author:		Bibin
-- Create date: 28/09/2021
-- Description:	Validate ReceiptId passed to EPOS
-- =============================================
CREATE PROCEDURE [dbo].[ValidateReceipt](@ReceiptId int , @DeviceId nvarchar(25)) 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--For loyalty transaction , validate receiptid exists and belongs to the user whos deviceid is passed in begin trx 
	DECLARE @UserId INT

	IF len(@deviceid) > 0
	BEGIN
		Select @UserId = UserId from Device where DeviceId=@deviceid
	END

	IF ISNULL(@UserId,0) > 0 and len(@receiptId) > 0 
	BEGIN
		IF EXISTS (SELECT 1 FROM Receipt where ReceiptId=@receiptId and SnippUserId = @UserId )--(Select UserId from Device where DeviceId=@deviceid))
		BEGIN
			SELECT 1 AS Result
		END
		ELSE
		BEGIN
			SELECT 0 AS Result
		END
	END
	--For Anonymise transaction ,just validate receiptid
	ELSE IF len(@receiptId) > 0
	BEGIN
		IF EXISTS (SELECT 1 FROM Receipt where ReceiptId=@receiptId)
		BEGIN
			SELECT 1 AS Result
		END
		ELSE
		BEGIN
			SELECT 0 AS Result
		END
	END

END
