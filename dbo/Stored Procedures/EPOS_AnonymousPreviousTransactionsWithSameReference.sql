-- =============================================
-- ANISH	
-- Create date: <Create Date,,>
-- Description:i
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_AnonymousPreviousTransactionsWithSameReference] 
	-- Add the parameters for the stored procedure here
	(@TrxId INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRAN
	DECLARE @Reference VARCHAR(50)
	DECLARE @SiteId INT
	Declare @TrxTypeId INT
	Declare @ClientId INT
	select @Reference=reference,@SiteId=siteid ,@ClientId=clientid from Trxheader where TrxId=@TrxId
	select @TrxTypeId= trxtypeid from trxtype where name='void' and clientid=@ClientId
	Declare @TrxStatusCancelled INT
	select @TrxStatusCancelled= TrxStatusid from TrxStatus where name='Cancelled' and clientid=@ClientId
	if exists(select 1 from trxheader where Reference=@Reference and trxtypeid=@TrxTypeId)
	begin
	--UPDATE PREVIOUS PURCHASE
	UPDATE TrxHeader SET IsAnonymous=1 where reference=@Reference and isnull(IsAnonymous,0)=0 and trxid!=@TrxId and siteid=@SiteId and trxtypeid<>@TrxTypeId and TrxStatusTypeId=@TrxStatusCancelled
	--UPDATE PREVIOUS VOID
	UPDATE TrxHeader SET IsAnonymous=1 where reference=@Reference and isnull(IsAnonymous,0)=0 and trxid!=@TrxId and siteid=@SiteId and TrxTypeId=@TrxTypeId
	end
	COMMIT TRAN
    END TRY
	BEGIN CATCH
    --SELECT ERROR_NUMBER() AS ErrorNumber;
	ROLLBACK TRAN
    END CATCH;
END

