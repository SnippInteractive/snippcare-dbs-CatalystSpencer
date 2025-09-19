-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <26/09/2016>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[CreateInitialPointsTransactionsBatch]
	(
		@ClientId int,
		@DeviceLotId int,
		@PointsBalance int
	)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @trxTypeId int;
	Declare @devices table (id int, deviceId varchar(30));
	Declare @i int = 1;
	Declare @homeSiteId int;
	Declare @trxStatusTypeId int;

	insert into @devices
	select ROW_NUMBER() OVER(order by Id), DeviceId 
	from Device 
	where DeviceLotId = @DeviceLotId 
	and userid is not null;

	select @homeSiteId = SiteId from Site where SiteTypeId in (select SiteTypeId from SiteType where Name = 'HeadOffice');
	select @trxStatusTypeId = TrxStatusId from TrxStatus where Name = 'Completed';
	Select @trxTypeId = TrxTypeId from TrxType where ClientId = @ClientId and Name = 'InitialPointsBalanceSet';
	
	Declare @DeviceId varchar(30);

	WHILE @i <=  (select count(1) from @devices)
		BEGIN
			select @DeviceId = deviceId from @devices where id = @i;
			
			Declare @trxId int;

			insert into TrxHeader (version, DeviceId, TrxTypeId, TrxDate, ClientId, SiteId, Reference, TrxStatusTypeId, CreateDate, CallContextId, AccountPointsBalance, LastUpdatedDate)
			values
			(0, @DeviceId, @trxTypeId, GETDATE(), @ClientId, @homeSiteId, 'DB', @trxStatusTypeId, GETDATE(), NEWID(), @PointsBalance, GETDATE())
			SELECT @trxId=SCOPE_IDENTITY();

			insert into TrxDetail (Version, TrxID, LineNumber, ItemCode, Description, Quantity, Value, Points, ConvertedNetValue)
			VALUES
			(0, @trxId, 1, NULL, 'Initial Points', 1, 0, @PointsBalance, 0)

			print @DeviceId;
			SET @i = @i + 1
		END
END
