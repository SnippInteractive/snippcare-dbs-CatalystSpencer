
CREATE PROCEDURE [dbo].[UploadItemCode]
(
	@MasterId					INT,			-- promotionId/profileId
	@ItemCode					NVARCHAR(MAX),
	@ClientId					INT,
	@Master						NVARCHAR(20)='' -- promotion/profile
)
AS
BEGIN
	BEGIN TRY
		/*-------------------------------------------------
		CHECKING WHETHER THE GIVEN STRING IS IN JSON FORMAT
		---------------------------------------------------*/
		IF ISJSON(@ItemCode)= 0 OR ISNULL(ISJSON(@ItemCode),'')= ''
		BEGIN
			SELECT '0'
			RETURN
		END
	
		BEGIN TRAN
		DECLARE @result varchar(10) ='0',@ItemTypeId INT
		DECLARE @Version INT =2,@MaxId INT
		/*----------------------------------------------- 
		TAKING ITEMTYPEID FOR THE ITEM CODE.
		-----------------------------------------------*/
		SELECT	@ItemTypeId = Id 
		FROM	PromotionItemType 
		WHERE	ClientId = @ClientId
		AND		LOWER(Name) ='itemcode' 
		AND		Display =1
		/*--------------------------------------------------- 
		DELETING THE OLD RECORDS FOR THE PROMOTION/PROFILE ID
		----------------------------------------------------*/
		IF @Master = 'promotion'
		BEGIN
			--SELECT	@Version = MIN([Version])
			--FROM    PromotionItem
			--WHERE	PromotionId = @MasterId
			--AND		PromotionItemTypeId = @ItemTypeId

			SELECT	@MaxId = MAX(Id)
			FROM    PromotionItem
			WHERE	PromotionId = @MasterId
			AND		PromotionItemTypeId = @ItemTypeId

			DELETE	PromotionItem 
			WHERE	PromotionId = @MasterId
			AND		PromotionItemTypeId = @ItemTypeId and Mode='uploaded'
		END

		IF @Master = 'voucherprofile'
		BEGIN
			DELETE	VoucherProfileItem 
			WHERE	VoucherProfileId = @MasterId
			AND		VoucherProfileItemTypeId = @ItemTypeId and Mode='uploaded'
		END
		/*------------------------------------------------- 
		INSERTING RECORDS UPLOADED FOR THE PROMOTION/PROFILE ID
		FROM JSON FORMAT TO TABLE FORMAT.
		-------------------------------------------------*/
		IF @Master = 'promotion'
		BEGIN
			INSERT PromotionItem
			(
				Version,
				PromotionId,
				PromotionItemTypeId,
				Code,
				FilterType,
				Quantity,
				ItemIncludeExclude,
				PromotionItemGroupId,
				LogicalAnd,
				Mode
			)
  
			SELECT  DISTINCT   
					@Version,  
					@MasterId as PromotionId,  
					@ItemTypeId as PromotionItemTypeId,   
					[value],  
					Null, 
					1, 
					'IncludeItem',
					1,
					0,
					'uploaded'  
			FROM	OPENJSON(@ItemCode) 
		END

		IF @Master = 'voucherprofile'
		BEGIN
			INSERT VoucherProfileItem
			(
				Version,
				VoucherProfileId,
				VoucherProfileItemTypeId,
				Code,
				FilterType,
				Mode

			)
			SELECT	DISTINCT
					1 as Version,
					@MasterId as VoucherProfileId,
					@ItemTypeId as VoucherProfileItemTypeId,
					[value],  
					0,
					'uploaded'
			FROM	OPENJSON(@ItemCode) 
		END
		COMMIT
		SET @result ='1'
	END TRY
	BEGIN CATCH
		ROLLBACK
		SET @result ='0'
	END CATCH

		
		SELECT @result
END
