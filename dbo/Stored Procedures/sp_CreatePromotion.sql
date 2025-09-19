-- =============================================
-- Author:		Ulisses Franca
-- Create date: 2013-12-03
-- Description:	This Stored procedure creates promotions
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreatePromotion]
	-- Add the parameters for the stored procedure here
	@SiteId INT,
	@StartDate DATETIME,
	@EndDate DATETIME,
	@Name NVARCHAR(50),
	@Description NVARCHAR(50),
	@Miscode NVARCHAR(50),
	@Message NVARCHAR(50),
	@GroupItems BIT,
	@OfferValue FLOAT,
	@ClientId INT,
	@PromotionOfferTypeName NVARCHAR(50),
	@PromotionItemTypesList promotion_item_list READONLY,
	@Personalized BIT,
	--@PromotionValidationList promotion_validation_list READONLY,
	@PromotionThresholdValue FLOAT = NULL,
	@PromotionThresholdTypeName NVARCHAR(50) = NULL,
	@StartTime TIME = NULL,
	@EndTime TIME = null
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @PromotionId INT =0;
	DECLARE @PromotionThresholdTypeId INT = NULL;
	
	IF @PromotionThresholdTypeName IS NOT NULL
	BEGIN
		SELECT @PromotionThresholdTypeId = ID FROM dbo.PromotionThresholdType WHERE ClientId = @ClientId AND Name = @PromotionOfferTypeName;
	END

    -- Insert statements for procedure here
	INSERT INTO [dbo].[Promotion]
           ([Name]
           ,[Description]
           ,[SiteId]
           ,[StartDate]
           ,[EndDate]
           ,[StartTime]
           ,[EndTime]
           ,[Enabled]
           ,[DaysEnabled]
           ,[PromotionOfferTypeId]
           ,[PromotionOfferValue]
           ,[PromotionThreshold]
           ,[TotalOffers]
           ,[MisCode]
           ,[Message]
           ,[GroupItems]
		   ,Personalized)
     VALUES
           (@Name
           ,@Description
           ,@SiteId
           ,@StartDate
           ,@EndDate
           ,@StartTime
           ,@EndTime
           ,1
           ,NULL
           ,(SELECT Id FROM dbo.PromotionOfferType WHERE ClientId = @ClientId AND Name=@PromotionOfferTypeName)
           ,@OfferValue
           ,@PromotionThresholdValue
           ,0
           ,@Miscode
           ,@Message
           ,@GroupItems
		   ,@Personalized);
           
     SELECT @PromotionId = SCOPE_IDENTITY();
     
     -- lets add the Item list if any
     INSERT INTO [dbo].[PromotionItem]
           ([PromotionId]
           ,[PromotionItemTypeId]
           ,[Code])
		 SELECT @PromotionId,
				pit.Id,
				pl.code 
			FROM dbo.PromotionItemType pit JOIN @PromotionItemTypesList pl 
				ON pl.type_name = pit.Name AND ClientId=@ClientId;
	
	-- Validations		
	--IF @PromotionValidationList IS NOT NULL
	--BEGIN
	--	INSERT [dbo].[PromotionValidation]
 --          ([PromotionValidationTypeId]
 --          ,[PromotionId]
 --          ,[Value])
	--		SELECT pvt.Id,
	--			@PromotionId,
	--			pl.value
	--			FROM dbo.PromotionValidationType pvt JOIN @PromotionValidationList pl 
	--				ON pl.type_name = pvt.Name AND ClientId = @ClientId;
     
	--END
	
	--return the ID
	RETURN @PromotionId;
    
END
