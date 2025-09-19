CREATE PROCEDURE [dbo].[bws_ShadowPointTransferCommunity]          
 (@SourceUserId INT,      --2791260    
  @DestinationUserId INT,  --2803068,    
  @Result INT OUTPUT    
 )          
AS          
BEGIN          
 -- SET NOCOUNT ON added to prevent extra result sets from          
 -- interfering with SELECT statements.          
 SET NOCOUNT ON;          
          
     
 -- 1. Transfer all transaction to paren with TrxType - ShadowPurchase    
 BEGIN TRY    
 BEGIN TRAN    

 DECLARE @TrxType INT
 SET @TrxType=(select top 1 TrxTypeId from TrxType where name='ShadowPurchase') 

 select distinct trxid into #Trxtransfer from TrxHeader th join device d on th.DeviceId=d.deviceid where d.UserId=@SourceUserId and  isnull(th.IsTransferred,0)=0    
                                                            and th.TrxId not in (select OLD_TrxId from TrxHeader where OLD_TrxId is not null and TrxTypeId = @TrxType)               
    
       
 DECLARE @ParentLoyaltyDeviceId varchar(50)       
 DECLARE @ParentLoyaltyAccountId INT            
 select top 1 @ParentLoyaltyAccountId=d.AccountId,@ParentLoyaltyDeviceId=d.DeviceId from device d with(nolock)inner join devicestatus ds on d.devicestatusid=ds.DeviceStatusId          
                        inner join deviceprofile dp on d.id=dp.DeviceId          
         inner join DeviceProfileTemplate dpt on dp.deviceprofileid=dpt.id          
         inner join DeviceProfileTemplateType dptp on dpt.DeviceProfileTemplateTypeId=dptp.Id where dptp.Name='Loyalty' and d.userid=@DestinationUserId    
     
  Declare @PointsEarned Money       
  SET @PointsEarned=(select sum(a.pointsbalance) from device d with(nolock)inner join devicestatus ds on d.devicestatusid=ds.DeviceStatusId          
                        inner join deviceprofile dp on d.id=dp.DeviceId      
      inner join Account a on d.AccountId=a.AccountId        
         inner join DeviceProfileTemplate dpt on dp.deviceprofileid=dpt.id          
         inner join DeviceProfileTemplateType dptp on dpt.DeviceProfileTemplateTypeId=dptp.Id where dptp.Name='Loyalty' and d.userid=@SourceUserId)     
     
  UPDATE Account SET PointsBalance=PointsBalance+isnull(@PointsEarned,0) where accountid=@ParentLoyaltyAccountId     
      
     
 DECLARE @ShadowLoyaltyAccountId INT     
 select top 1 @ShadowLoyaltyAccountId=d.AccountId from device d with(nolock)inner join devicestatus ds on d.devicestatusid=ds.DeviceStatusId          
                        inner join deviceprofile dp on d.id=dp.DeviceId          
         inner join DeviceProfileTemplate dpt on dp.deviceprofileid=dpt.id          
         inner join DeviceProfileTemplateType dptp on dpt.DeviceProfileTemplateTypeId=dptp.Id where dptp.Name='Loyalty' and d.userid=@SourceUserId    
    
UPDATE Account SET PointsBalance=0 where accountid=@ShadowLoyaltyAccountId       
    
       
   
    
DECLARE @NewTrxId INT         
DECLARE @TrxId INT      
DECLARE db_cursor CURSOR FOR      
SELECT TrxId from #Trxtransfer     
OPEN db_cursor      
FETCH NEXT FROM db_cursor INTO @TrxId      
    
WHILE @@FETCH_STATUS = 0      
BEGIN      
			DECLARE @CurrentBalance Decimal(18,2);
            SELECT @CurrentBalance = ISNULL(PointsBalance,0) FROM Account WHERE AccountId = @ParentLoyaltyAccountId

         insert into trxheader     
    ([Version]    
           ,[DeviceId]    
           ,[TrxTypeId]    
           ,[TrxDate]    
           ,[ClientId]    
           ,[SiteId]    
           ,[TerminalId]    
           ,[Reference]    
           ,[OpId]    
           ,[TrxStatusTypeId]    
           ,[CreateDate]    
           ,[TerminalDescription]    
           ,[BatchId]    
           ,[Batch_Urn]    
           ,[TrxCommitDate]    
           ,[InitialTransaction]    
           ,[DeviceIdentity]    
           ,[CallContextId]    
           ,[TerminalExtra]    
           ,[AccountCashBalance]    
           ,[AccountPointsBalance]    
           ,[ImportUniqueId]    
           ,[EposTrxId]    
           ,[TerminalExtra2]    
           ,[TerminalExtra3]    
           ,[MemberId]    
           ,[TotalPoints]    
           ,[OLD_TrxId]    
           ,[LastUpdatedDate]    
           ,[IsAnonymous]    
           ,[ReservationId]    
     ,[IsTransferred])         
       select [Version]          
           ,@ParentLoyaltyDeviceId          
           ,@TrxType          
           ,TrxDate          
           ,[ClientId]          
           ,SiteId          
           ,[TerminalId]          
           ,[Reference]          
           ,[OpId]          
           ,[TrxStatusTypeId]      
           ,isnull(TrxCommitDate,CreateDate)-- TrxCommitDate is null in case of manual claim       
           ,[TerminalDescription]          
           ,[BatchId]          
           ,[Batch_Urn]          
           ,GetDate()       
           ,[InitialTransaction]          
           ,[DeviceIdentity]          
           ,[CallContextId]          
           ,[TerminalExtra]          
           ,[AccountCashBalance]          
           ,ISNULL(@CurrentBalance,0)
           ,[ImportUniqueId]          
           ,[EposTrxId]          
           ,[TerminalExtra2]          
           ,[TerminalExtra3]          
           ,[MemberId]          
           ,[TotalPoints]          
           ,@TrxId        
           ,[LastUpdatedDate]    
           ,IsAnonymous    
     ,[ReservationId]    
     ,1    
     from Trxheader where trxId=@TrxId          
          
          
         SELECT @NewTrxId=SCOPE_IDENTITY()          
          
         INSERT INTO [dbo].[TrxDetail]          
           ([Version]    
           ,[TrxID]    
           ,[LineNumber]    
           ,[ItemCode]    
           ,[Description]    
           ,[Anal1]    
           ,[Anal2]    
           ,[Anal3]    
           ,[Anal4]    
           ,[Quantity]    
           ,[Value]    
           ,[Points]    
           ,[PromotionID]    
           ,[PromotionalValue]    
           ,[EposDiscount]    
           ,[LoyaltyDiscount]    
           ,[AuthorisationNr]    
           ,[status]    
           ,[BonusPoints]    
           ,[PromotionItemId]    
           ,[VAT]    
           ,[VATPercentage]    
           ,[OriginalTrxDetailId]    
           ,[Anal5]    
           ,[Anal6]    
           ,[Anal7]    
           ,[Anal8]    
           ,[Anal9]    
           ,[Anal10]    
           ,[HomeCurrencyCode]    
           ,[ConvertedNetValue]    
           ,[Anal11]    
           ,[Anal12]    
           ,[Anal13]    
           ,[Anal14]    
           ,[Anal15]    
           ,[Anal16])    
    
     SELECT [Version]    
      ,@NewTrxId    
      ,[LineNumber]    
      ,[ItemCode]    
      ,[Description]    
      ,[Anal1]    
      ,[Anal2]    
      ,[Anal3]    
      ,[Anal4]    
      ,[Quantity]    
      ,[Value]    
      ,[Points]    
      ,[PromotionID]    
      ,[PromotionalValue]    
      ,[EposDiscount]    
      ,[LoyaltyDiscount]    
      ,[AuthorisationNr]    
      ,[status]    
      ,[BonusPoints]    
      ,[PromotionItemId]    
      ,[VAT]    
      ,[VATPercentage]    
      ,[OriginalTrxDetailId]    
      ,[Anal5]    
      ,[Anal6]    
      ,[Anal7]    
      ,[Anal8]    
      ,[Anal9]    
      ,[Anal10]    
      ,[HomeCurrencyCode]    
      ,[ConvertedNetValue]    
      ,[Anal11]    
      ,[Anal12]    
      ,[Anal13]    
      ,[Anal14]    
      ,[Anal15]    
      ,[Anal16]    
  FROM [dbo].[TrxDetail]  where trxid=@trxid       
               
   INSERT INTO [dbo].[TrxPayment]    
           ([Version]    
           ,[TrxID]    
           ,[TenderTypeId]    
           ,[TenderAmount]    
           ,[Currency]    
           ,[TenderDeviceId]    
           ,[AuthNr]    
           ,[TenderProcessFlags]    
           ,[ExtraInfo])    
    
     SELECT [Version]    
      ,@NewTrxId    
      ,[TenderTypeId]    
      ,[TenderAmount]    
      ,[Currency]    
      ,[TenderDeviceId]    
      ,[AuthNr]    
      ,[TenderProcessFlags]    
      ,[ExtraInfo]    
       FROM [dbo].[TrxPayment] where TrxId=@TrxId       
    
    UPDATE TrxHeader set IsTransferred=1 where TrxId=@TrxId    
    
       FETCH NEXT FROM db_cursor INTO @TrxId      
END      
    
CLOSE db_cursor      
DEALLOCATE db_cursor     
    
COMMIT TRAN    
Select 1 As Result, 'Success' AS [Message]    
END TRY    
BEGIN CATCH    
    Rollback Tran    
END CATCH;    
END
