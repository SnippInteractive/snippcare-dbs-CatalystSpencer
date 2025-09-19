-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CreateErrorForMissingTrx](@trxId int,@statuscode int,@description nvarchar(500))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   insert into Error_MissingTrx(CreateDate,TrxId,statusCode,Description) values (GETDATE(),@trxId,@statuscode,@description)
END
