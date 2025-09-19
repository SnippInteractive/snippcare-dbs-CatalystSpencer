-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Epos_BasketPointOffers]
	-- Add the parameters for the stored procedure here
	(@TrxId INT,@PromotionId INT,@VoucherId Varchar(50),@PromotionValue decimal(18,2),@LineNumber INT,@Clear INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF ISNULL(@Clear,0) = 1
	BEGIN
		delete from [VirtualPointPromotions] 
		where trxid=@TrxId --and Linenumber=@LineNumber
	END

		--delete from [VirtualPointPromotions] 
		--where trxid=@TrxId and Linenumber=@LineNumber

		INSERT INTO [VirtualPointPromotions]
			   ([PromotionId]
			   ,[VoucherId]
			   ,[TrxId]
			   ,[LineNumber]
			   ,[PromotionValue])
		 VALUES
			   (@PromotionId
			   ,@VoucherId
			   ,@TrxId
			   ,@LineNumber
			   ,@PromotionValue)

END

