-- =============================================
-- Author:		Binu Jacob Scaria
-- Create date: 08-03-2022
-- Description:	BatchTransfer - taskrunner
-- =============================================
CREATE PROCEDURE [dbo].[bws_UpdateVoucherStatusToUsed] 	(@userId int,@voucherId nvarchar(MAX),@TrxId INT,@clientId INT)
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	
	DECLARE @DeviceStatusExpired INT
	SELECT @DeviceStatusExpired = DeviceStatusId FROM DeviceStatus WHERE [Name] = 'Expired' AND ClientId = @clientId

	DECLARE @Voucher NVARCHAR(25)
	DECLARE OnlineCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
 SELECT value FROM  STRING_SPLIT ( @voucherId , ',' )                             
OPEN OnlineCursor                                                  
	FETCH NEXT FROM OnlineCursor           
	INTO @Voucher                               
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		INSERT INTO TrxVoucherDetail (TrxDetailId,TrxVoucherId,Version,VoucherAmount)
		SELECT TOP 1 TrxDetailID,@Voucher,0,0 FROM TrxDetail WHERE TrxId = @TrxId AND Anal10 IS NOT NULL

		UPDATE Device SET ExpirationDate = GETDATE(),DeviceStatusId = @DeviceStatusExpired Where Deviceid = @Voucher
		FETCH NEXT FROM OnlineCursor     
		INTO @Voucher  
	END     
CLOSE OnlineCursor;    
DEALLOCATE OnlineCursor; 

END
