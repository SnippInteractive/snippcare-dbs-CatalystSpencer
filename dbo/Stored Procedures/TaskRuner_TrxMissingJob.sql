-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TaskRuner_TrxMissingJob] 
	@pos_trans_num INT,@newTrxId INT,@method NVARCHAR(50),@reference nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF ISNULL(@method,'') = 'finaliseSuccess'
	BEGIN
		Update TrxMissingJOB SET is_processed = 1 , processed_date = getdate(),newTrxId = @newTrxId where reference = @reference
	END

	 IF ISNULL(@method,'') = 'finalizeFailed'
	BEGIN
		update TrxHeader set TrxStatusTypeId = 1 where trxid = @newTrxId
		Update TrxMissingJOB SET is_processed = 4 , processed_date = getdate() where reference = @reference
	END

	 IF ISNULL(@method,'') = 'calculateLoyaltyFailed'
	BEGIN
		Update TrxMissingJOB SET is_processed = 3 , processed_date = getdate(),newTrxId = @newTrxId where reference = @reference
	END

END
