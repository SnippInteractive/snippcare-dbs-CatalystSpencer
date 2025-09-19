-- =============================================
-- Author:		Bibin Abraham
-- Create date: 28/09/2016
-- Description:	Create a transaction for the initial 499  points during registeration
-- =============================================
CREATE PROCEDURE [dbo].[CreateDeviceInitialPointsTrx](@clientid int,@deviceId varchar(20),@reference varchar (50),@PromotionApplied int = 0)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @trxTypeId int;	
	Declare @homeSiteId int;
	Declare @trxStatusTypeId int,@accountId int;
	Declare @pointBalance decimal(18,2);
	Declare @trxId int;

	select @homeSiteId = HomeSiteId ,@accountId= AccountId from Device where DeviceId=@deviceId;
	select @pointBalance =PointsBalance from Account where accountid=@accountId;
	select @trxStatusTypeId = TrxStatusId from TrxStatus where Name = 'Completed' and ClientId=@clientid;
	select @trxTypeId = TrxTypeId from TrxType where ClientId = @clientid and Name = 'InitialPointsBalanceSet';
	
	IF @PromotionApplied = 0
	BEGIN
		set @PromotionApplied = NULL
	END
	ELSE
	BEGIN
	    select @pointBalance = PromotionOfferValue from Promotion where Id=@PromotionApplied;
	END
	-- if account exist then its a valid device
	if @accountId > 0 
	 BEGIN
		insert into TrxHeader (version, DeviceId, TrxTypeId, TrxDate, ClientId, SiteId, Reference, TrxStatusTypeId, CreateDate, CallContextId, AccountPointsBalance, LastUpdatedDate)
		values
		(0, @DeviceId, @trxTypeId, GETDATE(), @ClientId, @homeSiteId, @reference, @trxStatusTypeId, GETDATE(), NEWID(), @pointBalance, GETDATE())
		SELECT @trxId=SCOPE_IDENTITY();

		insert into TrxDetail (Version, TrxID, LineNumber, ItemCode, Description, Quantity, Value, Points, ConvertedNetValue,VAT,VATPercentage,PromotionID)
		values
		(0, @trxId, 1, 'DefaultPoints', 'Initial Points', 1, 0, @pointBalance, 0,0,0,@PromotionApplied)
	END
END

