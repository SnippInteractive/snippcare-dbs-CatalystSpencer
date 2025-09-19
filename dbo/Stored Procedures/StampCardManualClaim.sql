CREATE PROCEDURE [dbo].[StampCardManualClaim] (      											                                               
    @TrxId				INT,                                                       
    @StampId			INT,    
    @Quantity			INT,   
	@Value				FLOAT,
	@ClientId			INT,
	@ByUser				INT,
	@MemberId			INT = 0
 )                                                 
AS    
BEGIN    
     -- DECLARE @MemberId INT
    print @TrxId

	IF NOT EXISTS (SELECT 1 FROM VirtualStampCard WHERE TrxId = @TrxId)
	BEGIN

		DECLARE @PromotionValue		DECIMAL(18,2)
		DECLARE @StampCardType		NVARCHAR(25)
		DECLARE @PromotionOfferType	NVARCHAR(25)
		DECLARE @Promotionype		NVARCHAR(20)

		SELECT	@PromotionValue = p.PromotionOfferValue,
				@StampCardType =pc.[Name],
				@PromotionOfferType = ot.[Name], 
				@Promotionype = case p.PromotionTypeId when 0 then 'LineItem' when 1 then 'Basket' else '' end 
		FROM 
		Promotion p 
		inner join Promotioncategory pc on p.PromotioncategoryId = pc.Id
		inner join PromotionOfferType ot on p.PromotionOfferTypeId = ot.Id
		WHERE p.id=@StampId

		INSERT INTO VirtualStampCard(PromotionId,VoucherId,TrxId,LineNumber,PromotionValue,Quantity,NetValue,StampCardType,PromotionOfferType,PromotionType)
		VALUES(@StampId,null,@TrxId,1,@PromotionValue,@Quantity,@Value,@StampCardType,@PromotionOfferType,@Promotionype)
		
		IF ISNULL(@Value,0) < 0
		BEGIN
			DECLARE @AfterValue DECIMAL(18,2);
			SELECT TOP 1 @AfterValue = AfterValue FROM PromotionStampcounter WHERE PromotionId =  @StampId AND UserId = @MemberId
			
			IF ISNULL(@AfterValue,0) < ABS(ISNULL(@Value,0))
			BEGIN
				SET @AfterValue = 0;
			END
			ELSE
			BEGIN
				SET @AfterValue = @AfterValue - ABS(ISNULL(@Value,0))
			END

			UPDATE PromotionStampcounter SET AfterValue = @AfterValue WHERE PromotionId =  @StampId AND UserId = @MemberId
		END
		ELSE
		BEGIN
			PRINT 'PersonalizeStampCard'
			EXEC [PersonalizeStampCard] 0,@ClientId,@TrxId
		END
		
	END
  
END
