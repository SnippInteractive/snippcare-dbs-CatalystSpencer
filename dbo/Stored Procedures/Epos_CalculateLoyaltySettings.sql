-- =============================================
-- Author:		BINU JACOB SCARIA
-- Create date: 10-11-2023
-- Description:	Allways Call from CalculateLoyalty
-- =============================================
CREATE PROCEDURE [dbo].[Epos_CalculateLoyaltySettings]
	-- Add the parameters for the stored procedure here
	(@TrxId INT,@MemberId INT,@DeviceId nvarchar(25), @Method nvarchar(25),@ClientId INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF ISNULL(@Method,'') = 'Clear' AND ISNULL(@TrxId,0) > 0
	BEGIN
		delete from [VirtualPointPromotions] 
		where trxid=@TrxId

		delete from [VirtualStampCard] 
		where trxid=@TrxId

		IF ISNULL(@MemberId,0) > 0
		BEGIN
			UPDATE PromotionStampCounter SET BeforeValue = 0,OnTheFlyQuantity = 0 WHERE UserId = @MemberId
		END
		ELSE IF ISNULL(@DeviceId,'') <> ''
		BEGIN
			DECLARE @DeviceIdentifier INT
			SELECT TOP 1 @DeviceIdentifier = Id FROM Device where DeviceId = @DeviceId
			IF ISNULL(@DeviceIdentifier,0) > 0
			BEGIN
				UPDATE PromotionStampCounter SET BeforeValue = 0,OnTheFlyQuantity = 0 WHERE DeviceIdentifier = @DeviceIdentifier
			END
		END
	END
	
END
