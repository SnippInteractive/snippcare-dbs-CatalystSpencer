CREATE PROCEDURE [dbo].[GetShadowPurchaseDeviceId]          
 (          
          
 @TrxId INT     -- parent trxid
 ,@DeviceId varchar(50)   --parent deviceId
           
 )          
AS          
BEGIN          
 -- SET NOCOUNT ON added to prevent extra result sets from          
 -- interfering with SELECT statements.          
 SET NOCOUNT ON;          
          
         
 DECLARE @CallContextId varchar(50)          
          
 SET @CallContextId=(SELECT CallContextId FROM Trxheader 
                     WHERE TrxId=@TrxId and DeviceId=@DeviceId)


 SELECT top 1 deviceid FROM Trxheader 
 WHERE CallContextId=@CallContextId and TrxId !=@TrxId and deviceid!=@DeviceId
 
 
END 
