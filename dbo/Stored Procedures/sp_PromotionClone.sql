-- =============================================      
-- Author:  SREEJITH REGHU     
-- Create date: 25/07/2016      
-- Description: To create a clone of a promotion      
-- =============================================      
CREATE PROCEDURE [dbo].[sp_PromotionClone]          
 @PromotionId INT    
AS      
BEGIN       
BEGIN TRY      
BEGIN TRAN   
    
  DECLARE @NewPromotionId INT;
  INSERT INTO [Promotion]([Version],Name,[Description],SiteId,StartDate,EndDate,StartTime,EndTime,[Enabled],DaysEnabled,PromotionOfferTypeId,PromotionOfferValue,PromotionThreshold,TotalOffers,MisCode,[Message],GroupItems,Personalized,PromotionItemFlagAnd,PromotionTypeId,VoucherProfileId,IncludePromotionItems)
           (SELECT [Version],Name,[Description],SiteId,StartDate,EndDate,StartTime,EndTime,[Enabled],DaysEnabled,PromotionOfferTypeId,PromotionOfferValue,PromotionThreshold,TotalOffers,MisCode,[Message],GroupItems,Personalized,PromotionItemFlagAnd,PromotionTypeId,VoucherProfileId,IncludePromotionItems 
            FROM [Promotion] 
            WHERE Id=@PromotionId);
  
  SET @NewPromotionId=SCOPE_IDENTITY();
  
  INSERT INTO [PromotionItem]([Version],PromotionId,PromotionItemTypeId,Code,FilterType)
           (SELECT [Version],@NewPromotionId,PromotionItemTypeId,Code,FilterType
            FROM [PromotionItem]
            WHERE PromotionId=@PromotionId);
            
  INSERT INTO [PromotionSites]([Version],SiteId,PromotionId) 
           (SELECT [Version],SiteId,@NewPromotionId
           FROM [PromotionSites]
           WHERE PromotionId=@PromotionId)
      
 COMMIT TRAN      
END TRY      
BEGIN CATCH      
    ROLLBACK TRAN      
END CATCH      
END
