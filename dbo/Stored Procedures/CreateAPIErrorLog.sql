-- =============================================
-- Author:		Bibin Abraham
-- Create date: 24/07/2020
-- Description:	Capture all the exceptions happened in calling epos from Receipt sumbission API
-- =============================================
CREATE PROCEDURE [dbo].[CreateAPIErrorLog]
	(@uniquerequestId nvarchar(50),@requestData nvarchar(MAX),@responseData nvarchar(MAX),@reference nvarchar(50),
	@statusCode int,@statusDescription nvarchar(200),@method nvarchar(50),@source nvarchar(50),@deviceId nvarchar(50),
	@type nvarchar(30)='Receipt')
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO ApiErrorLog(RequestId,Request,Response,CreateDate,Reference,StatusCode,StatusDescription,
				Method,Source,Deviceid,Type, Processed) VALUES
				(@uniquerequestId,@requestData,@responseData,GETDATE(),@reference,@statusCode,
				@statusDescription,@method,@source,@deviceId,@type, 0)
END
