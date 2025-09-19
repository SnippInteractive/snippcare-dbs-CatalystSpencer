-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <26/09/2016>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CreateInitialPointsTransactionsSingleUser]
	(
		@DeviceId varchar(50),
		@PointsBalance int,
		@HomeSiteId int
	)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @trxTypeId int;
	Declare @trxStatusTypeId int;
	Declare @trxId int;

	select @trxStatusTypeId = TrxStatusId from TrxStatus where Name = 'Completed';
	Select @trxTypeId = TrxTypeId from TrxType where ClientId = 1 and Name = 'InitialPointsBalanceSet';
			
	insert into TrxHeader (version, DeviceId, TrxTypeId, TrxDate, ClientId, SiteId, Reference, TrxStatusTypeId, CreateDate, CallContextId, AccountPointsBalance, LastUpdatedDate)
	values
	(0, @DeviceId, @trxTypeId, GETDATE(), 1, @homeSiteId, 'DB', @trxStatusTypeId, GETDATE(), NEWID(), @PointsBalance, GETDATE())
	SELECT @trxId=SCOPE_IDENTITY();

	insert into TrxDetail (Version, TrxID, LineNumber, ItemCode, Description, Quantity, Value, Points, ConvertedNetValue)
	VALUES
	(0, @trxId, 1, NULL, 'Initial Points', 1, 0, @PointsBalance, 0)

	print @trxId;
	print @DeviceId;
END
