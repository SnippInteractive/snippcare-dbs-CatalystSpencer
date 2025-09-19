Create PROCEDURE [dbo].[SaveBonusRedPromotionsettings] 
( 
  @siteId int,
  @Id int, 
  @coupon1Id int,
  @voucher1Id int,
  @offerText1 nvarchar(max),
  @coupon2Id int,
  @voucher2Id int,
  @offerText2 nvarchar(max),
  @coupon3Id int,
  @Promotion3Id int,
  @coupon4Id int,
  @Promotion4Id int,
  @offerText4 nvarchar(max),
  @IdWb int, 
  @coupon1IdWb int,
  @voucher1IdWb int,
  @offerText1Wb nvarchar(max),
  @coupon2IdWb int,
  @voucher2IdWb int,
  @offerText2Wb nvarchar(max),
  @coupon3IdWb int,
  @Promotion3IdWb int,
  @coupon4IdWb int,
  @Promotion4IdWb int,
  @offerText4Wb nvarchar(max)
 )    
                                                  
                                                  
AS    
  BEGIN    
      
          
  SET NOCOUNT ON;    
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
  BEGIN TRY    
  BEGIN TRAN      
    IF not exists(select id from BonusRedemptionAdmin where Id=@Id)
     begin
		INSERT INTO BonusRedemptionAdmin( [Version],SiteId,[Type],Coupon1,Voucher1,OfferText1,Coupon2,Voucher2,OfferText2,
											Coupon3,Promotion3,Coupon4,Promotion4,OfferText4)
		VALUES(0,@siteId,1,@coupon1Id,@voucher1Id,@offerText1,@coupon2Id,@voucher2Id,@offerText2,
										@coupon3Id,@Promotion3Id,@coupon4Id,@Promotion4Id,@offerText4);
     end
     ELSE
     begin
        UPDATE BonusRedemptionAdmin
        SET Coupon1=@coupon1Id,
			Voucher1=@voucher1Id,
			OfferText1=@offerText1,
			Coupon2=@coupon2Id,
			Voucher2=@voucher2Id,
			OfferText2=@offerText2,
			Coupon3=@coupon3Id,
			Promotion3=@Promotion3Id,
			Coupon4=@coupon4Id,
			Promotion4=@Promotion4Id,
			OfferText4=@offerText4
		WHERE Id=@Id;
            
     end
     
     IF not exists(select id from BonusRedemptionAdmin where Id=@IdWb)
     begin
		INSERT INTO BonusRedemptionAdmin( [Version],SiteId,[Type],Coupon1,Voucher1,OfferText1,Coupon2,Voucher2,OfferText2,
											Coupon3,Promotion3,Coupon4,Promotion4,OfferText4)
		VALUES(0,@siteId,2,@coupon1IdWb,@voucher1IdWb,@offerText1Wb,@coupon2IdWb,@voucher2IdWb,@offerText2Wb,
										@coupon3IdWb,@Promotion3IdWb,@coupon4IdWb,@Promotion4IdWb,@offerText4Wb);
     end
     ELSE
     begin
        UPDATE BonusRedemptionAdmin
        SET Coupon1=@coupon1IdWb,
			Voucher1=@voucher1IdWb,
			OfferText1=@offerText1Wb,
			Coupon2=@coupon2IdWb,
			Voucher2=@voucher2IdWb,
			OfferText2=@offerText2Wb,
			Coupon3=@coupon3IdWb,
			Promotion3=@Promotion3IdWb,
			Coupon4=@coupon4IdWb,
			Promotion4=@Promotion4IdWb,
			OfferText4=@offerText4Wb
		WHERE Id=@IdWb;
            
     end
     
     
  COMMIT TRAN    
  END TRY    
  BEGIN CATCH    
   ROLLBACK TRAN    
  END CATCH    
     
  END

