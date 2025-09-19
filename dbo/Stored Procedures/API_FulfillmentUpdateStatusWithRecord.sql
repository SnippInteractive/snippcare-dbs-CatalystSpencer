-- =============================================
-- Author:		Wei Liu
-- Create date: 09/10/21
-- Description:	To update fulfilled rebates and create record in audits
-- =============================================
CREATE PROCEDURE [dbo].[API_FulfillmentUpdateStatusWithRecord] (@ClientId int, @UserId int, @TrxId int, @ConfirmationId nvarchar(500), @Result BIT OUTPUT)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @TrxStatusId INT, @SQL NVARCHAR(MAX), @SiteId INT, @SiteRef NVARCHAR(1000), @ParentId INT, @ImportUniqueId NVARCHAR(1000), @TrxTypeId INT

	BEGIN TRY  
    
	Select @SiteRef = Value from ClientConfig where [Key]='ReceiptHeadSiteRef' and ClientId=@ClientId
    Select @ParentId = SiteId from [Site] where SiteRef=@SiteRef and ClientId=@ClientId
	SELECT @SiteId = ISNULL(SiteId, 0) FROM [SITE] Where ClientId = @ClientId and ParentId = @ParentId
	SELECT @TrxTypeId = TrxTypeId FROM trxtype Where Name = 'Reward' and ClientId = @ClientId
	SELECT @TrxStatusId = TrxStatusId from TrxStatus where [Name] = 'Completed' and ClientId = @ClientId
	SELECT @ImportUniqueId = ImportUniqueId from Trxheader where trxid = @TrxId

	Update Trxheader SET TrxStatusTypeId = @TrxStatusId WHERE ImportUniqueId = @ImportUniqueId and TrxTypeId = @TrxTypeId
	EXEC [Insert_Audit] '', @UserId, @SiteId, 'TrxHeader', @TrxId, 'Rebate Fulfilled', 'Awaiting Fulfillment', @ConfirmationId

	SET @Result = 1
	
   END TRY  
   BEGIN CATCH      
    SET @Result = 0 
   END CATCH 
END
