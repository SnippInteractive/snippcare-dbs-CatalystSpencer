  
-- =============================================  
-- Author:  Abdul Wahab  
-- Create date: 22-06-21  
-- Description: This procedure is to know if there is any transaction based promotion on purchases, and if a user qualifies for it  
-- =============================================  
  
CREATE PROCEDURE [dbo].[CheckUserQualifiesForPurchaseTransactionBasedPromotion]  
@ClientId INT,  
@UserId INT,  
@DeviceId NVARCHAR(100),  
@IsQualified BIT=0 OUTPUT,  
@PromotionOfferValue FLOAT OUTPUT  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 --TEST---  
 --declare @IsQualified BIT=0 ,  
 --@PromotionOfferValue FLOAT   
 --exec [dbo].[CheckUserQualifiesForPurchaseTransactionBasedPromotion] 1, 0, 'V59147855', @IsQualified Output, @PromotionOfferValue output  
 --select @IsQualified, @PromotionOfferValue  
  
 DECLARE @PromotionCount INT=0,  
 @TrxCount INT=0  
  
 --first check if there is any promotion exists  
 SELECT P.*,PIT.[Name] PromotionItemType INTO #Promotion FROM Promotion P   
 INNER JOIN PromotionItem PItem ON P.Id = PItem.PromotionId  
 INNER JOIN PromotionItemType PIT ON PIT.Id= PItem.PromotionItemTypeId  
 --in future if there is a fourth,fifth... transaction, then make sure to add it here.  
 WHERE PIT.[Name] IN ('FirstTransaction','SecondTransaction','ThirdTransaction')   
 AND ClientId=@ClientId AND P.[Enabled]=1  
  
 SET @PromotionCount = (SELECT COUNT(*) FROM #Promotion)  
  
    IF @PromotionCount > 0  
 BEGIN   
  
  SET @TrxCount = (SELECT COUNT(*) FROM TrxHeader TH  
       INNER JOIN TrxType TT ON TH.TrxTypeId = TT.TrxTypeId AND TT.ClientId=@ClientId  
       WHERE TT.[Name]='Receipt' AND (TH.DeviceID = @DeviceId or TH.DeviceId IN (SELECT DeviceId FROM Device WHERE UserId= @UserId))   
       AND Th.TrxStatusTypeId in (SELECT TrxStatusId from TrxStatus where [Name] = 'Completed' AND ClientId=@ClientId))  
  
  IF @PromotionCount>=@TrxCount  
  BEGIN  
   SET @IsQualified = 1  
   --in future if there is a fourth,fifth... transaction, then make sure to add it here.  
   IF @TrxCount = 1  
   BEGIN  
    SET @PromotionOfferValue = (SELECT PromotionOfferValue FROM #Promotion WHERE PromotionItemType='FirstTransaction')  
   END  
   ELSE IF @TrxCount = 2  
   BEGIN  
    SET @PromotionOfferValue = (SELECT PromotionOfferValue FROM #Promotion WHERE PromotionItemType='SecondTransaction')  
   END  
   ELSE IF @TrxCount = 3  
   BEGIN  
    SET @PromotionOfferValue = (SELECT PromotionOfferValue FROM #Promotion WHERE PromotionItemType='ThirdTransaction')  
   END     
  END  
 END    
END