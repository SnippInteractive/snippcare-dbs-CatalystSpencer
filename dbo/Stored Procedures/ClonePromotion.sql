/*---------------------------------- 
Written : Sreejith
Date : 08 Feb 2024
Details : used in catalyst->Promotion
-----------------------------------*/
CREATE PROCEDURE [dbo].[ClonePromotion]
(
	@PromotionId		INT,
	@CloneName			NVARCHAR(250),
	@StartDate			NVARCHAR(50),
	@EndDate			NVARCHAR(50),
	@ClientId			INT,
	@ByUserId			INT
)
AS
BEGIN

	DECLARE @Success NVARCHAR(50), @NewPromotionId INT

	IF EXISTS(SELECT 1 FROM Promotion WHERE [Name] = @CloneName)
	BEGIN
		SET @Success = 'PromotionNameExists'
	END
	ELSE
	BEGIN

		INSERT INTO Promotion([Name],[Description],	SiteId,	StartDate,	EndDate,	StartTime,	EndTime,	[Enabled],	DaysEnabled,	PromotionOfferTypeId,	PromotionOfferValue,	PromotionThreshold,	TotalOffers
			,MisCode,	[Message],	GroupItems,	Personalized,	PromotionItemFlagAnd,	PromotionTypeId,	VoucherProfileId,	IncludePromotionItems,	IsTemplate,	IsBonusRedemption,	IsIndustryPromo,	
			MaxUsagePerMember,	OverrideBasePointRestriction,	PromotionUsageLimit,	Quantity,	PromotionCategoryId,	QualifyingProductQuantity,	EmailTemplateId,	SmsTemplateId,	PushTemplateId,	
			MaxPromoApplicationOnSameBasket,	PromoApplicationMaxValue,	MaxUsagePerBasket,	CriteriaId,	Cumulation,	Reward,	ActivityTypeId,	ActivityReference,	ActivityCategoryId,	ActivityCategoryTypeId,	
			ImageName,	ImageUrl,	ActivityConfiguration,	PromotionHitLimitTypeId,	TimeZoneId,	Config,	StampCardMultiplier,	ParentPromotionId)
		SELECT 		@CloneName,	[Description],	SiteId,	@StartDate,	@EndDate,	StartTime,	EndTime,	[Enabled],	DaysEnabled,	PromotionOfferTypeId,	PromotionOfferValue,	PromotionThreshold,	TotalOffers
			,MisCode,	[Message],	GroupItems,	Personalized,	PromotionItemFlagAnd,	PromotionTypeId,	VoucherProfileId,	IncludePromotionItems,	IsTemplate,	IsBonusRedemption,	IsIndustryPromo,	
			MaxUsagePerMember,	OverrideBasePointRestriction,	PromotionUsageLimit,	Quantity,	PromotionCategoryId,	QualifyingProductQuantity,	EmailTemplateId,	SmsTemplateId,	PushTemplateId,	
			MaxPromoApplicationOnSameBasket,	PromoApplicationMaxValue,	MaxUsagePerBasket,	CriteriaId,	Cumulation,	Reward,	ActivityTypeId,	ActivityReference,	ActivityCategoryId,	ActivityCategoryTypeId,	
			ImageName,	ImageUrl,	ActivityConfiguration,	PromotionHitLimitTypeId,	TimeZoneId,	Config,	StampCardMultiplier,	ParentPromotionId
		FROM Promotion
		WHERE Id = @PromotionId

		SET @NewPromotionId = SCOPE_IDENTITY();

		INSERT INTO PromotionItem ([Version],PromotionId,PromotionItemTypeId,Code,FilterType,Quantity,ItemIncludeExclude,PromotionItemGroupId,LogicalAnd,Mode)
		SELECT 0,@NewPromotionId,PromotionItemTypeId,Code,FilterType,Quantity,ItemIncludeExclude,PromotionItemGroupId,LogicalAnd,Mode
		FROM PromotionItem
		WHERE PromotionId = @PromotionId

		INSERT INTO PromotionSites([Version],SiteId,PromotionId)
		SELECT 0,SiteId, @NewPromotionId
		FROM PromotionSites 
		WHERE PromotionId = @PromotionId

		INSERT INTO PromotionLoyaltyProfiles ([Version], PromotionId,LoyaltyProfileId)
		SELECT  0,@NewPromotionId,LoyaltyProfileId
		FROM PromotionLoyaltyProfiles
		WHERE PromotionId = @PromotionId

		INSERT INTO promotionMemberProfileItem([Version],PromotionId,PromotionCategoryId,ItemId,ItemName,ClientId,ItemValue)
		SELECT 0,@NewPromotionId,PromotionCategoryId,ItemId,ItemName,ClientId,ItemValue
		FROM promotionMemberProfileItem 
		WHERE PromotionId = @PromotionId

		INSERT INTO PromotionRegion ([Version],PromotionId,RegionId,Region)
		SELECT 0, @NewPromotionId,RegionId,Region
		FROM PromotionRegion
		WHERE PromotionId = @PromotionId

		INSERT INTO PromotionLocation ([Version],PromotionId,LocationId,[Location],[Description])
		SELECT 0,@NewPromotionId, LocationId,[Location],[Description]
		FROM PromotionLocation
		WHERE PromotionId = @PromotionId

		INSERT INTO PromotionProductFamilies([Version],PromotionId,ProductFamilySubTypeId)
		SELECT 0,@NewPromotionId,ProductFamilySubTypeId
		FROM PromotionProductFamilies
		WHERE PromotionId = @PromotionId

		INSERt INTO PromotionSegments ([Version],PromotionId,SegmentId)
		SELECT 0, @NewPromotionId,SegmentId
		FROM PromotionSegments
		WHERE PromotionId = @PromotionId

		INSERT INTO PromotionHtml ([Version],PromotionId,HtmlContent,ClientId)
		SELECT 0,@NewPromotionId,HtmlContent,ClientId
		FROM PromotionHtml
		WHERE PromotionId = @PromotionId


		--Audit 
		INSERT INTO AUDIT 
		(
			[Version], UserId, FieldName,NewValue,OldValue,ChangeDate,
			ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser
		)
		VALUES
		(
			1,@ByUserId,'ClonePromotion','','',GETDATE(), 
			@ByUserId,'PromotionId:'+CAST(@PromotionId as varchar(10))+', NewPromotionId:'+ CAST(@NewPromotionId as varchar(10)),'',NULL,NULL,'Promotion',-1
		)

		SET @Success = 'Success'
	END

	SELECT @Success AS Result
END
