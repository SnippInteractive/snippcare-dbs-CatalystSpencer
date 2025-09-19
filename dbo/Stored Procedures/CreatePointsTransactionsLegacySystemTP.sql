-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <26/09/2016>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CreatePointsTransactionsLegacySystemTP]
	(
		@DeviceId varchar(50),
		@PointsBalance int, 
		@SiteRef varchar(100)
	)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @trxTypeId int;
	Declare @trxStatusTypeId int;
	Declare @trxId int;
	Declare @trxAccountPointsBalance float;
	DECLARE @homeSiteId int;
	DECLARE @accoutId int; 

	SELECT @accoutId = accountId FROM  Device WHERE Deviceid = @DeviceId;

	SELECT @homeSiteId = siteid FROM Site WHERE siteref = @SiteRef;
				
	SELECT TOP 1 @trxAccountPointsBalance = PointsBalance FROM dbo.Account a WHERE a.AccountId = @accoutId;

	select @trxStatusTypeId = TrxStatusId from TrxStatus where Name = 'Completed';
	Select @trxTypeId = TrxTypeId from TrxType where ClientId = 1 and Name = 'PointsAdjustment'; 

	insert into 
		TrxHeader (version, DeviceId, TrxTypeId, TrxDate, ClientId, SiteId, Reference, TrxStatusTypeId, CreateDate, CallContextId, AccountPointsBalance, LastUpdatedDate)
	values
		(0, @DeviceId, @trxTypeId, convert(datetime,'2017/05/31 00:00:00', 120), 1, @homeSiteId, 'DB', @trxStatusTypeId,convert(datetime,'2017/05/31 00:00:00', 120)
		, NEWID(), (@PointsBalance + @trxAccountPointsBalance), convert(datetime,'2017/05/31 00:00:00', 120))
	SELECT @trxId = SCOPE_IDENTITY();

	insert into TrxDetail (Version, TrxID, LineNumber, ItemCode, Description, Quantity, Value, Points, ConvertedNetValue)
	VALUES
	(0, @trxId, 1, NULL, 'Übertrag Punkte aus Altsystem', 1, 0, @PointsBalance, 0);

	UPDATE Account SET PointsBalance = (@PointsBalance + @trxAccountPointsBalance) WHERE accountId = @accoutId;

	print @trxId;
	print @DeviceId;
	PRINT @trxAccountPointsBalance;
END
