-- =============================================
-- Author:		Niall
-- Create date: 2020-08-12
-- Description:	Select the Fulfillment that have the Transaction created and have a RedeemPoints Trx (maybe should be delivered)
-- =============================================
CREATE PROCEDURE [SSISHelper].[OrderFulfillmentEmailSending]
	
AS
BEGIN
	
	Declare @trxtypeid_Delivery int, @trxtypeid_RedeemPoints int, @Status_EmailSent int=3, @Status_EmailToGo int=2

	select @trxtypeid_Delivery from trxtype where clientid = 1 and name = 'Delivery'
	select @trxtypeid_RedeemPoints = trxtypeid from trxtype where clientid = 1 and name = 'RedeemPoints'

    /*Format required for the email
	SELECT 'abdul.wahab@snipp.com' Email,'Abdul' FirstName, NEWID() ConfirmationId, 
	'Cat Food' ProductDescription, GETDATE() ShippingDate, NEWID() TrackingNumber
	*/
	IF OBJECT_ID(N'tempdb..#Data') IS NOT NULL
	BEGIN 
		DROP TABLE #Data 
	END
	select u.username Email, [Ship to First Name] as  FirstName, [Client Order #] as ConfirmationId, 
	[stock description] ProductDescription, convert(date,[Ship Date]) as ShippingDate,
	[Tracking Number(s)] as TrackingNumber 
	into #Data
	from SSISHelper.OrderFulfillment oful 
	join trxheader th on th.reference collate database_default=oful.[Client Order #] --<< Confirmation ID from Wayne!
	join device dv on dv.deviceid =th.deviceid
	join [user] u on u.userid = dv.userid 	
	where [status] = @Status_EmailToGo and TrxTypeId=@trxtypeid_RedeemPoints --Emails not yet sent
	/*
	Update the records so they will not be selected again
	*/
	update SSISHelper.OrderFulfillment set [status] = @Status_EmailSent 
	where [status]=@Status_EmailToGo and [Client Order #] in 
	(select ConfirmationId from #Data)

	select * from #Data
END
