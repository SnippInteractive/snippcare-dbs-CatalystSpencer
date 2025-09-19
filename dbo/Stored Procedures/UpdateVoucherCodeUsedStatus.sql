CREATE PROCEDURE [dbo].[UpdateVoucherCodeUsedStatus](@Code nvarchar(100),@ClientId int, @SiteId int)
AS
BEGIN
	SET NOCOUNT ON;
	Declare @TrxId int
	-- Changing status to unused
	Update VoucherCodes Set Userid = null,DateUsed = null,usage_id = null where DeviceId = @Code --and clientId = @ClientId

	select top 1 @TrxId = TrxID from TrxDetail where itemcode = @Code

	DECLARE @trxDate DATETIME
	Declare @tempTable table(Result int)
	SET @trxDate = GETDATE()
	--void 'ing the transaction
	insert @tempTable(Result)
	exec Epos_VoidFinalizedTransaction @TrxId, @SiteId, @trxDate, 0, 1

	SELECT DeviceId, UserId,convert(varchar(10), ExpirationDate, 120) ExpirationDate ,ExtReference,[Value],ValueType, convert(varchar(10), DateUsed, 120) DateUsed,code_id as CodeId,usage_id as UsageId 
	FROM VoucherCodes 
	WHERE DeviceId = @Code --AND ClientID = @ClientId
END
