
------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[EPOS_ShadowPointTransfer]      
 (@UserId INT,      
 @LoyaltyDeviceId varchar(50),      
 @TrxId INT      
       
 )      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
 BEGIN TRY
 BEGIN TRAN     
 Declare @PointsEarned Money      
 Declare @ShadowAccountId INT      
 Declare @ParentUserId INT      
 DECLARE @ParentLoyaltyAccountId INT      
 DECLARE @ParentLoyaltyDeviceId varchar(50)      
      
 SET @PointsEarned=(select sum(points) from trxheader th inner join trxdetail td on th.trxid=td.trxid where th.trxid=@TrxId)      
 SET @ShadowAccountId=(select top 1 accountid from device where deviceid=@LoyaltyDeviceId)      
 SET @ParentUserId=(select top 1 m.MemberId1 from memberlink m inner join       
                    memberlinktype mt on m.linktype=mt.MemberLinkTypeId where name='Community' and MemberId2=@Userid and CommunityId is not null)      
      
 select top 1 @ParentLoyaltyAccountId=d.AccountId,@ParentLoyaltyDeviceId=d.DeviceId from device d with(nolock)inner join devicestatus ds on d.devicestatusid=ds.DeviceStatusId      
                        inner join deviceprofile dp on d.id=dp.DeviceId      
         inner join DeviceProfileTemplate dpt on dp.deviceprofileid=dpt.id      
         inner join DeviceProfileTemplateType dptp on dpt.DeviceProfileTemplateTypeId=dptp.Id where dptp.Name='Loyalty' and d.userid=@ParentUserId  and ds.name='active'             
      
         if(len(@ParentLoyaltyAccountId)>0)      
         begin      
         DECLARE @TrxType INT      
         DECLARE @CurrentBalance Money      
         SET @TrxType=(select top 1 TrxTypeId from TrxType where name='ShadowPurchase')      
         UPDATE Account SET PointsBalance=PointsBalance+isnull(@PointsEarned,0) where accountid=@ParentLoyaltyAccountId               
         UPDATE Account SET PointsBalance=PointsBalance-isnull(@PointsEarned,0) where accountid=@ShadowAccountId      
         SET @CurrentBalance=(select PointsBalance from Account where accountid=@ParentLoyaltyAccountId)      
         DECLARE @NewTrxId INT      
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
           ,[ReservationId])     
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
           ,Getdate()      
           ,[InitialTransaction]      
           ,[DeviceIdentity]      
           ,[CallContextId]      
           ,[TerminalExtra]      
           ,[AccountCashBalance]      
           ,@CurrentBalance      
           ,[ImportUniqueId]      
           ,[EposTrxId]      
           ,[TerminalExtra2]      
           ,[TerminalExtra3]      
           ,[MemberId]      
           ,[TotalPoints]      
           ,@TrxId    
           ,[LastUpdatedDate]
           ,IsAnonymous,[ReservationId] from Trxheader where trxId=@TrxId      
      
      
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
      
         end      
 COMMIT TRAN

 END TRY
 BEGIN CATCH
    Rollback Tran
 END CATCH;
 END 

 --------------------------------------------------------------------------------------------------------------------------

