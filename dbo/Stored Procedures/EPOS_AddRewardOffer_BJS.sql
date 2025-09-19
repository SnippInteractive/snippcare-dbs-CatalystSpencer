
-- =============================================
-- Author:		Bibin
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2020-10-20
-- Description:	Include / Exclude
-- Modified Date: 2021-10-06
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_AddRewardOffer_BJS](@Trxid int,@ClientId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON;
	
	BEGIN TRY                                                        
	BEGIN TRAN 

	DECLARE @CriteriaIdQuantity INT,@CriteriaIdValue INT,@PromotionCategoryRebateId INT,@TrxtypeIdReward INT,@ApplicationNumber nvarchar(50),@ReceiptId int,@DeviceIdentifier INT,@AccountId INT,@IsStampClaim BIT = 0;
	SELECT @CriteriaIdQuantity = Id from PromotionCriteria WHERE clientid=@ClientId AND Name = 'Quantity';
	SELECT @CriteriaIdValue = Id from PromotionCriteria WHERE clientid=@ClientId AND Name = 'Value';
	SELECT @PromotionCategoryRebateId = ID from PromotionCategory WHERE Name  = 'Rebate' AND ClientId = @ClientId
	SELECT @TrxtypeIdReward = TrxTypeId from Trxtype WHERE Name  = 'Reward' AND ClientId = @ClientId


	DECLARE @DeviceStatusActive int,@DeviceStatusIdInactive INT,@ProfileStatusIdInactive INT,@LoyaltyDevice varchar(20),@MemberId int,@reference varchar(50),@SiteId int,@TrxdateTime DateTimeOffset(7),@Trxdate DateTime;
	SET @DeviceStatusActive=(SELECT devicestatusid from Devicestatus where name='Active' and clientid=@ClientId)
	
	SET @DeviceStatusIdInactive=(select DeviceStatusId from DeviceStatus With(nolock) where Name='Inactive' and ClientId=@ClientId)
	SET @ProfileStatusIdInactive=(select DeviceProfileStatusId from DeviceProfileStatus With(nolock) where Name='Inactive' and ClientId=@ClientId)
	-- Get the device id from trx header

	SELECT @LoyaltyDevice=deviceid,@SiteId=siteid,@reference=Reference,@TrxdateTime = TrxDate,@ApplicationNumber = ImportUniqueId ,@ReceiptId = ReceiptId,@Trxdate = Trxdate from trxheader where trxid=@TrxId
	-- Get the member id from device id
	SELECT @MemberId = ISNULL(userid,0) , @DeviceIdentifier = Id,@AccountId = AccountId from device where deviceid=@LoyaltyDevice

   -- store all item filters to #itemcode from current trx detail table
	SELECT  TrxDetailId,Anal1,anal2,anal3,anal4,anal5,anal6,anal7,anal8,anal9,anal10,anal11,anal12,anal13,Points,LineNumber,@SiteId as SiteId,anal14,anal15,anal16,ItemCode,value, Quantity into #itemcode from TrxDetail where trxid=@TrxId

	IF EXISTS (SELECT 1 FROM #itemcode Where ItemCode = 'StampClaim')
	BEGIN
		SET @IsStampClaim = 1;
		PRINT 'IsStampClaim'
	END

	-----------------------------------------------------------------------------------------
	print 'Start insert all promotion items at ' + convert(varchar(25), getdate(), 120)  
	-----------------------------------------------------------------------------------------
	-- store itemcode into #tempCode 

	SELECT * into #tempCode from
	(SELECT @Trxid Trxid, TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode1' and clientid=@ClientId) as TypeId,anal1 as Code,SiteId,Quantity   from #itemcode where anal1 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode2' and clientid=@ClientId) as TypeId,anal2 as Code,SiteId,Quantity   from #itemcode where anal2 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode3' and clientid=@ClientId) as TypeId,anal3 as Code,SiteId ,Quantity  from #itemcode where anal3 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode4' and clientid=@ClientId) as TypeId,anal4 as Code,SiteId ,Quantity  from #itemcode where anal4 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode5' and clientid=@ClientId) as TypeId,anal5 as Code,SiteId ,Quantity  from #itemcode where anal5 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode6' and clientid=@ClientId) as TypeId,anal6 as Code,SiteId ,Quantity  from #itemcode where anal6 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode7' and clientid=@ClientId) as TypeId,anal7 as Code,SiteId ,Quantity from #itemcode where anal7 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode8' and clientid=@ClientId) as TypeId,anal8 as Code,SiteId ,Quantity  from #itemcode where anal8 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode9' and clientid=@ClientId) as TypeId,anal9 as Code,SiteId ,Quantity  from #itemcode where anal9 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode10' and clientid=@ClientId) as TypeId,anal10 as Code,SiteId ,Quantity  from #itemcode where anal10 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode11' and clientid=@ClientId) as TypeId,anal11 as Code,SiteId ,Quantity  from #itemcode where anal11 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode12' and clientid=@ClientId) as TypeId,anal12 as Code,SiteId ,Quantity  from #itemcode where anal12 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode13' and clientid=@ClientId) as TypeId,anal13 as Code,SiteId ,Quantity  from #itemcode where anal13 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode14' and clientid=@ClientId) as TypeId,anal14 as Code,SiteId ,Quantity  from #itemcode where anal14 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode15' and clientid=@ClientId) as TypeId,anal15 as Code,SiteId ,Quantity from #itemcode where anal15 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode16' and clientid=@ClientId) as TypeId,anal16 as Code,SiteId ,Quantity  from #itemcode where anal16 is not null
	union
	SELECT @Trxid Trxid,TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='ItemCode' and clientid=@ClientId) as TypeId,itemcode as Code,SiteId ,Quantity from #itemcode where itemcode is not null

	) t
	--SELECT * FROM #itemcode
	DECLARE @RewardOffer TABLE (PromotionId VARCHAR(50),Name VARCHAR(250),LineNumber INT,TrxDetailID INT,Points float,BonusPoints INT,OfferType VARCHAR(50)
	,Offer VARCHAR(50),Code VARCHAR(50),CriteriaId INT,itemQuantity INT,trxQuantity float,Cumulation INT,RewardId INT,RewardName VARCHAR(250),ProductId VARCHAR(50),
	RewardValue decimal(18,2),NetValue money,QualifyingProductQuantity float,PromotionType VARCHAR(50),StampCardType VARCHAR(50),RewardQuantity INT,RewardLines VARCHAR(250),
	MaxPromoApplicationOnSameBasket INT,ItemIncludeExclude NVARCHAR(25),PromotionThreshold Float,PromotionCategoryId INT,PromotionUsageLimit INT,
	MaxUsagePerMember INT,MaxBasketLimit INT,ItemCode NVARCHAR(150),GroupItems bit,OnTheFlyQuantity INT,OnTheFlyUsedQuantity INT,MisCode NVARCHAR(50))

	
	DECLARE @RewardOfferSTAMP TABLE (PromotionId VARCHAR(50),Name VARCHAR(250),LineNumber INT,TrxDetailID INT,Points float,BonusPoints INT,OfferType VARCHAR(50)
	,Offer VARCHAR(50),Code VARCHAR(50),CriteriaId INT,itemQuantity INT,trxQuantity float,Cumulation INT,RewardId INT,RewardName VARCHAR(250),ProductId VARCHAR(50),
	RewardValue decimal(18,2),NetValue money,QualifyingProductQuantity float,PromotionType VARCHAR(50),StampCardType VARCHAR(50),RewardQuantity INT,RewardLines VARCHAR(250),
	MaxPromoApplicationOnSameBasket INT,ItemIncludeExclude NVARCHAR(25),PromotionThreshold Float,PromotionCategoryId INT,PromotionUsageLimit INT,
	MaxUsagePerMember INT,MaxBasketLimit INT,ItemCode NVARCHAR(150),GroupItems bit,OnTheFlyQuantity INT,OnTheFlyUsedQuantity INT,MisCode NVARCHAR(50))


	DECLARE @VoucherOffer TABLE	(LineNumber VARCHAR(250),PromotionId VARCHAR(50),PromotionName VARCHAR(250),VoucherIds NVARCHAR(500),VoucherName VARCHAR(250),Quantity INT)

	DECLARE @SplitMisCode TABLE	(splitdata VARCHAR(50))

	INSERT INTO @RewardOffer
	SELECT  distinct  CONVERT(varchar(50), p.Id ) as PromotionId, p.Name, tmp.LineNumber, tmp.TrxDetailID, tmp.Points,
	0 as BonusPoints ,pop.Name as OfferType,'Reward' as Offer, pt.Code,p.CriteriaId, 
	pt.Quantity as itemQuantity, tmp.Quantity as trxQuantity, Cumulation,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardId FROM OpenJson(Reward)WITH (RewardId INT '$.Id'))  end AS RewardId,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardName FROM OpenJson(Reward)WITH (RewardName NVARCHAR(150) '$.Name'))  end AS RewardName,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT ProductId FROM OpenJson(Reward)WITH (ProductId NVARCHAR(150) '$.RewardId'))  end AS ProductId,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardValue FROM OpenJson(Reward)WITH (RewardValue decimal(18,2) '$.Value'))  end AS RewardValue
	,tmp.value NetValue,p.QualifyingProductQuantity,'LineItem' AS PromotionType,'' AS StampCardType,0 AS RewardQuantity,'' AS RewardLines,MaxPromoApplicationOnSameBasket ,
	ItemIncludeExclude,PromotionThreshold,p.PromotionCategoryId,p.PromotionUsageLimit,p.MaxUsagePerMember,0 AS MaxBasketLimit,'SKU-NA' AS ItemCode,GroupItems,
	0 AS OnTheFlyQuantity,0 AS OnTheFlyUsedQuantity ,p.MisCode
	--into #RewardOffer 
	from Promotion p 
	inner join PromotionOfferType pop on p.PromotionOfferTypeId=pop.Id
	inner join PromotionItem pt on p.id=pt.PromotionId
	inner join PromotionSites ps on p.id=ps.PromotionId
	inner join #tempCode tmp on  pt.PromotionItemTypeId=tmp.TypeId
	inner join PromotionCategory pc on p.PromotionCategoryId=pc.Id
	where RTRIM(LTRIM(pt.Code))= RTRIM(LTRIM(tmp.Code))
	and p.Id not in(SELECT PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
	and p.StartDate<=@Trxdate and p.ENDDate>=@Trxdate and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('Reward') 
	and tmp.SiteId in( SELECT SiteId from GetChildSitesBySiteId(ps.siteid))
	and pc.Name not in ('StampCardQuantity','StampCardValue')
	and p.PromotionTypeId!=1 --and p.PromotionCategoryId=6--reward category
	and pt.ItemIncludeExclude = 'IncludeItem'

	select distinct convert(varchar(50), p.Id )as PromotionId				
	into #OfferInclude 
	from Promotion p 
	inner join PromotionOfferType pop on p.PromotionOfferTypeId=pop.Id
	inner join PromotionItem pt on p.id=pt.PromotionId
	inner join PromotionSites ps on p.id=ps.PromotionId
	inner join #tempCode tmp on  pt.PromotionItemTypeId=tmp.TypeId
	inner join PromotionCategory pc on p.PromotionCategoryId=pc.Id
	where  --RTRIM(LTRIM(pt.Code))= RTRIM(LTRIM(tmp.Code)) and
	p.Id not in(SELECT PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
	and p.StartDate<=@Trxdate and p.ENDDate>=@Trxdate and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('Reward') 
	and tmp.SiteId in( SELECT SiteId from GetChildSitesBySiteId(ps.siteid))
	and pc.Name not in ('StampCardQuantity','StampCardValue')
	--and p.PromotionTypeId!=1 
	--and p.PromotionCategoryId=6--reward category
	and pt.ItemIncludeExclude = 'IncludeItem'

	
	SELECT  distinct  CONVERT(varchar(50), p.Id ) as PromotionId, p.Name, tmp.LineNumber, tmp.TrxDetailID, tmp.Points,
	0 as BonusPoints ,pop.Name as OfferType,'Reward' as Offer, pt.Code,p.CriteriaId, 
	pt.Quantity as itemQuantity, tmp.Quantity as trxQuantity, Cumulation,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardId FROM OpenJson(Reward)WITH (RewardId INT '$.Id'))  end AS RewardId,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardName FROM OpenJson(Reward)WITH (RewardName NVARCHAR(150) '$.Name'))  end AS RewardName,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT ProductId FROM OpenJson(Reward)WITH (ProductId NVARCHAR(150) '$.RewardId'))  end AS ProductId,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardValue FROM OpenJson(Reward)WITH (RewardValue decimal(18,2) '$.Value'))  end AS RewardValue
	,tmp.value NetValue,p.QualifyingProductQuantity,'LineItem' AS PromotionType,'' AS StampCardType,0 AS RewardQuantity,'' AS RewardLines,MaxPromoApplicationOnSameBasket ,
	ItemIncludeExclude,PromotionThreshold,p.PromotionCategoryId,p.PromotionUsageLimit,p.MaxUsagePerMember,0 AS MaxBasketLimit,'SKU-NA' AS ItemCode,GroupItems,
	0 AS OnTheFlyQuantity,0 AS OnTheFlyUsedQuantity,p.MisCode
	into #RewardOfferRewardExclude
	from Promotion p 
	inner join PromotionOfferType pop on p.PromotionOfferTypeId=pop.Id
	inner join PromotionItem pt on p.id=pt.PromotionId
	inner join PromotionSites ps on p.id=ps.PromotionId
	inner join #tempCode tmp on  pt.PromotionItemTypeId=tmp.TypeId
	inner join PromotionCategory pc on p.PromotionCategoryId=pc.Id
	where  --RTRIM(LTRIM(pt.Code))= RTRIM(LTRIM(tmp.Code)) and
	p.Id not in(SELECT PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
	and p.StartDate<=@Trxdate and p.ENDDate>=@Trxdate and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('Reward') 
	and tmp.SiteId in( SELECT SiteId from GetChildSitesBySiteId(ps.siteid))
	and pc.Name not in ('StampCardQuantity','StampCardValue')
	and p.PromotionTypeId!=1 --and p.PromotionCategoryId=6--reward category
	and pt.ItemIncludeExclude = 'ExcludeItem'
	AND p.Id NOT IN (SELECT DISTINCT PromotionId FROM #OfferInclude)
	
	INSERT INTO @RewardOffer 
	SELECT * FROM #RewardOfferRewardExclude

	--BASKET VALUE
		SELECT  distinct  CONVERT(varchar(50), p.Id ) as PromotionId, p.Name, tmp.LineNumber, tmp.TrxDetailID, tmp.Points,
		0 as BonusPoints ,pop.Name as OfferType,'Reward' as Offer, pt.Code,p.CriteriaId, 
		pt.Quantity as itemQuantity, tmp.Quantity as trxQuantity, Cumulation,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardId FROM OpenJson(Reward)WITH (RewardId INT '$.Id'))  end AS RewardId,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardName FROM OpenJson(Reward)WITH (RewardName NVARCHAR(150) '$.Name'))  end AS RewardName,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT ProductId FROM OpenJson(Reward)WITH (ProductId NVARCHAR(150) '$.RewardId'))  end AS ProductId,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardValue FROM OpenJson(Reward)WITH (RewardValue decimal(18,2) '$.Value'))  end AS RewardValue
		,tmp.value NetValue,p.QualifyingProductQuantity,'Basket' AS PromotionType,'' AS StampCardType,0 AS RewardQuantity,'' AS RewardLines,MaxPromoApplicationOnSameBasket ,
		ItemIncludeExclude,PromotionThreshold,p.PromotionCategoryId,p.PromotionUsageLimit,p.MaxUsagePerMember,0 AS MaxBasketLimit,'SKU-NA' AS ItemCode,GroupItems,
		0 AS OnTheFlyQuantity,0 AS OnTheFlyUsedQuantity,p.MisCode
		into #RewardOfferRewardIncludeBasket 
		from Promotion p 
		inner join PromotionOfferType pop on p.PromotionOfferTypeId=pop.Id
		inner join PromotionItem pt on p.id=pt.PromotionId
		inner join PromotionSites ps on p.id=ps.PromotionId
		inner join #tempCode tmp on  pt.PromotionItemTypeId=tmp.TypeId
		inner join PromotionCategory pc on p.PromotionCategoryId=pc.Id
		where RTRIM(LTRIM(pt.Code))= RTRIM(LTRIM(tmp.Code))
		and p.Id not in(SELECT PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
		and p.StartDate<=@Trxdate and p.ENDDate>=@Trxdate and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('Reward') 
		and tmp.SiteId in( SELECT SiteId from GetChildSitesBySiteId(ps.siteid))
		and pc.Name not in ('StampCardQuantity','StampCardValue')
		and p.PromotionTypeId =1
		 --and p.PromotionCategoryId=6--reward category
		and pt.ItemIncludeExclude = 'IncludeItem'
		--SELECT * FROM #RewardOfferRewardIncludeBasket

		SELECT  distinct  CONVERT(varchar(50), p.Id ) as PromotionId, p.Name, tmp.LineNumber, tmp.TrxDetailID, tmp.Points,
		0 as BonusPoints ,pop.Name as OfferType,'Reward' as Offer, pt.Code,p.CriteriaId, 
		pt.Quantity as itemQuantity, tmp.Quantity as trxQuantity, Cumulation,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardId FROM OpenJson(Reward)WITH (RewardId INT '$.Id'))  end AS RewardId,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardName FROM OpenJson(Reward)WITH (RewardName NVARCHAR(150) '$.Name'))  end AS RewardName,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT ProductId FROM OpenJson(Reward)WITH (ProductId NVARCHAR(150) '$.RewardId'))  end AS ProductId,
	Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardValue FROM OpenJson(Reward)WITH (RewardValue decimal(18,2) '$.Value'))  end AS RewardValue
		,tmp.value NetValue,p.QualifyingProductQuantity,'Basket' AS PromotionType,'' AS StampCardType,0 AS RewardQuantity,'' AS RewardLines,MaxPromoApplicationOnSameBasket 
		,ItemIncludeExclude,PromotionThreshold,p.PromotionCategoryId,p.PromotionUsageLimit,p.MaxUsagePerMember,0 AS MaxBasketLimit,'SKU-NA' AS ItemCode,GroupItems,
		0 AS OnTheFlyQuantity,0 AS OnTheFlyUsedQuantity,p.MisCode
		into #RewardOfferRewardExcludeBasket
		from Promotion p 
		inner join PromotionOfferType pop on p.PromotionOfferTypeId=pop.Id
		inner join PromotionItem pt on p.id=pt.PromotionId
		inner join PromotionSites ps on p.id=ps.PromotionId
		inner join #tempCode tmp on  pt.PromotionItemTypeId=tmp.TypeId
		inner join PromotionCategory pc on p.PromotionCategoryId=pc.Id
		where  --RTRIM(LTRIM(pt.Code))= RTRIM(LTRIM(tmp.Code)) and
		p.Id not in(SELECT PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
		and p.StartDate<=@Trxdate and p.ENDDate>=@Trxdate and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('Reward') 
		and tmp.SiteId in( SELECT SiteId from GetChildSitesBySiteId(ps.siteid))
		and pc.Name not in ('StampCardQuantity','StampCardValue')
		and p.PromotionTypeId =1 --and p.PromotionCategoryId=6--reward category
		and pt.ItemIncludeExclude = 'ExcludeItem'
		AND p.Id NOT IN (SELECT DISTINCT PromotionId FROM #OfferInclude)

		--SELECT * FROM #RewardOfferRewardExcludeBasket

		INSERT INTO @RewardOffer 
		SELECT * FROM #RewardOfferRewardIncludeBasket
		INSERT INTO @RewardOffer 
		SELECT * FROM #RewardOfferRewardExcludeBasket

		--SELECT * FROM @RewardOffer
	--BASKET VALUE
	

	IF exists(SELECT 1 from @RewardOffer)
	BEGIN
		DECLARE @INEXTrxDetailID INT,@INEXPromotionId INT,@INEXOffer VARCHAR(50),@INEXLineNumber INT
		Declare @itemcountInclude INT
		Declare @trxCountInclude INT
		Declare @itemcountExclude INT
		Declare @trxCountExclude INT

		DECLARE db_cursorINEX CURSOR FOR  
		SELECT TrxDetailID, PromotionId,Offer,LineNumber
		FROM @RewardOffer
		OPEN db_cursorINEX  
		FETCH NEXT FROM db_cursorINEX INTO @INEXTrxDetailID,@INEXPromotionId,@INEXOffer  ,@INEXLineNumber

		WHILE @@FETCH_STATUS = 0  
		BEGIN 
			--PRINT @INEXTrxDetailID

			IF exists(SELECT * from promotion where id=CONVERT(int,@INEXPromotionId) )--and PromotionItemFlagAnd = 1)
				BEGIN
					--TOP-666
					 select PromotionItemTypeId,code,0 as processed,PromotionItemGroupId,Quantity 
					 into #filteritemsInclude from PromotionItem where promotionId=convert(int,@INEXPromotionId) And ItemIncludeExclude = 'IncludeItem'

					 select PromotionItemTypeId,code,0 as processed ,PromotionItemGroupId,Quantity
					 into #filteritemsExclude from PromotionItem where promotionId=convert(int,@INEXPromotionId) And ItemIncludeExclude = 'ExcludeItem'
	 
					 --IF Analysis Code is not passing for Exclude items need to remove promo from list
							DECLARE @ExcludeGroupId INT,@ExcludeGroupInValidCount INT = 0
							DECLARE db_GroupSursor CURSOR FOR  
							SELECT DISTINCT PromotionItemGroupId
							FROM #filteritemsExclude
							OPEN db_GroupSursor  
							FETCH NEXT FROM db_GroupSursor INTO @ExcludeGroupId  
							WHILE @@FETCH_STATUS = 0  
							BEGIN 
								IF NOT EXISTS (SELECT 1 FROM #filteritemsExclude fe INNER JOIN #tempCode tc on fe.PromotionItemTypeId = tc.TypeId WHERE fe.PromotionItemGroupId = @ExcludeGroupId AND tc.LineNumber = @INEXLineNumber)
								BEGIN
									SET @ExcludeGroupInValidCount += 1
								END
							FETCH NEXT FROM db_GroupSursor INTO @ExcludeGroupId 
							END  
							CLOSE db_GroupSursor  
							DEALLOCATE db_GroupSursor 


						 PRINT 'Exclude Group In-Valid Count= ' + CONVERT(VARCHAR(20), ISNULL( @ExcludeGroupInValidCount,0))

					 SET @itemcountInclude=(select  count(distinct PromotionItemGroupId) from #filteritemsInclude)
					 SET @itemcountExclude=(select  count(distinct PromotionItemGroupId) from #filteritemsExclude)

					 SET @trxCountInclude=(select count(distinct f.PromotionItemGroupId) from #tempCode t inner join #filteritemsInclude f on t.TypeId=f.PromotionItemTypeId where t.Quantity >= f.Quantity and t.Code=f.Code and t.TrxDetailID=@INEXTrxDetailID)
					 SET @trxCountExclude=(select count(distinct f.PromotionItemGroupId) from #tempCode t inner join #filteritemsExclude f on t.TypeId=f.PromotionItemTypeId where t.Quantity >= f.Quantity and t.Code=f.Code and t.TrxDetailID=@INEXTrxDetailID)

					 if ISNULL(@trxCountInclude,0)<>ISNULL(@itemcountInclude,0)
					 begin
						delete from @RewardOffer where TrxDetailID=@INEXTrxDetailID and PromotionId=@INEXPromotionId
						PRINT 'IN-Not applicable Include PromotionId = '+CONVERT(VARCHAR(20),@INEXPromotionId)
					 end
					 ELSE
					 BEGIN
						PRINT 'IN-Applicable Include PromotionId = '+CONVERT(VARCHAR(20),@INEXPromotionId)
					 END
					 if ISNULL(@trxCountExclude,0) > 0 OR @ExcludeGroupInValidCount > 0--= ISNULL(@itemcountExclude,0) AND ISNULL(@itemcountExclude,0) > 0
					 begin
						delete from @RewardOffer where TrxDetailID=@INEXTrxDetailID and PromotionId=@INEXPromotionId
						PRINT 'EX-Not applicable Exclude PromotionId = '+CONVERT(VARCHAR(20),@INEXPromotionId)
					 end
					 ELSE
					 BEGIN
						PRINT 'EX-Applicable Include PromotionId = '+CONVERT(VARCHAR(20),@INEXPromotionId)
					 END
					  drop table #filteritemsInclude
					  drop table #filteritemsExclude
					 end 	
					 
					IF(ISNULL(@MemberId,0) > 0)
					BEGIN
						-- Check if any segment filter exists and its valid date is greater than current date
						IF exists(SELECT 1 from PromotionSegments p with(nolock) join segmentadmin s with(nolock) on p.segmentid=s.segmentid where validto >= GETDATE() and PromotionId=CONVERT(int, @INEXPromotionId) )
							BEGIN
							--Check again if any segment filter exists and belong to that user
							IF not exists(SELECT 1 from PromotionSegments ps with(nolock) join SegmentUsers s with(nolock) on ps.SegmentId = s.SegmentId where ps.PromotionId = CONVERT(int, @INEXPromotionId) and s.UserId = @MemberId)
								BEGIN
								--we remove all promotions that is related to the passed in transaction detail id and promotion id which mapped in #offer 
								delete from @RewardOffer where TrxDetailID=@INEXTrxDetailID and PromotionId=@INEXPromotionId
								--delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
								END
							END
					END
				--promotion Loyalty profile filter
				if exists(select 1 from PromotionLoyaltyProfiles where  PromotionId=convert(int,@INEXPromotionId) ) AND ISNULL(@LoyaltyDevice,'') != ''
				begin

					DECLARE @DeviceProfileId INT

					SELECT top 1 @DeviceProfileId = dpt.Id 
					from Device d with(nolock) 
					inner join DeviceProfile dp with(nolock) on d.id=dp.DeviceId 
					inner join DeviceProfileTemplate dpt with(nolock) on dp.DeviceProfileId = dpt.Id
					where D.Deviceid = @LoyaltyDevice

					if not exists(select 1 from PromotionLoyaltyProfiles where PromotionId=convert(int,@INEXPromotionId) and LoyaltyProfileId = @DeviceProfileId)
					begin
						delete from @RewardOffer where TrxDetailID=@INEXTrxDetailID and PromotionId=@INEXPromotionId
					end
				end

				--------------------LIMIT

				DECLARE @MaxUsagePerMemberLimit INT,@INEXPromotionUsageLimit INT,@TrxPromotionUsage INT,@TrxMaxUsagePerMember INT,@LimitReached INT= 0
				SELECT @MaxUsagePerMemberLimit = isnull(MaxUsagePerMember,0), @INEXPromotionUsageLimit= isnull(PromotionUsageLimit,0) from Promotion with(nolock) where Id =@INEXPromotionId
				---- Max Trx Limit for Promotion
				IF(@INEXPromotionUsageLimit>0)
				BEGIN	
					SET @TrxPromotionUsage  = [dbo].[PromotionUsage](0,@INEXPromotionId,null)
					IF ISNULL(@TrxPromotionUsage,0) >= @INEXPromotionUsageLimit
					BEGIN
						-- remove the promotion for the trxdetail temptable,so it will not be considered in bestoffer rule
						delete from @RewardOffer where TrxDetailID=@INEXTrxDetailID and PromotionId=@INEXPromotionId
						SET @LimitReached = 1;
					END	
				END
				-- Promotion Usage Filter Per Member
				-- check if any user promotion limit filter is set
				IF(@MaxUsagePerMemberLimit > 0) AND ISNULL(@MemberId,0) > 0 AND ISNULL(@LimitReached,0) = 0
				BEGIN				 
					--DECLARE @UsedCount INT=0
					--SET @UsedCount=(SELECT count(promotionid) from [PromotionRedemptionCount] with(nolock) where [MemberId] = @MemberId and  PromotionId = @PromotionId)
					SET @TrxMaxUsagePerMember = [dbo].[PromotionUsage](@MemberId,@INEXPromotionId,null)
					-- check user total redeem count with the user promotion limit count set
					IF isnull(@TrxMaxUsagePerMember,0) >= @MaxUsagePerMemberLimit
					BEGIN
						-- if count reach the limit count then we remove the promotions
						delete from @RewardOffer where TrxDetailID=@INEXTrxDetailID and PromotionId=@INEXPromotionId
					END			 
				END	
				--------------------END LIMIT

		FETCH NEXT FROM db_cursorINEX INTO @INEXTrxDetailID,@INEXPromotionId,@INEXOffer  ,@INEXLineNumber
		END
		CLOSE db_cursorINEX  
		DEALLOCATE db_cursorINEX 
	END 

	--MINIMUM BASKET SPEND
	SELECT DISTINCT PromotionId,LineNumber,TrxDetailID,ISNULL(PromotionThreshold,0) PromotionThreshold INTO #MBS FROM @RewardOffer WHERE PromotionType = 'Basket' AND OfferType = 'Reward' AND ISNULL(PromotionThreshold,0) > 0
	SELECT DISTINCT TrxDetailId,value  INTO #MBSTrxDetail FROM #tempCode
	--SELECT * FROM #MBS
	--SELECT * FROM #MBSTrxDetail
	DECLARE @MBSPromotionId INT, @MBSPromotionThreshold Float,@MBSValue MONEY
	DECLARE MBSCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
	SELECT  DISTINCT PromotionId,PromotionThreshold FROM #MBS                            
	OPEN MBSCursor                                                  
		FETCH NEXT FROM MBSCursor           
		INTO @MBSPromotionId , @MBSPromotionThreshold                              
		WHILE @@FETCH_STATUS = 0 
		BEGIN 
			SELECT @MBSValue = SUM(ISNULL(Value,0)) FROM #MBSTrxDetail WHERE TrxDetailID IN(SELECT DISTINCT TrxDetailID FROM #MBS WHERE PromotionId = @MBSPromotionId)

			IF @MBSValue<@MBSPromotionThreshold 
			BEGIN
				PRINT 'MBS'
				--PRINT @MBSValue
				--PRINT @MBSPromotionId
				--PRINT @MBSPromotionThreshold
				delete from @RewardOffer where PromotionId=@MBSPromotionId
			END
			FETCH NEXT FROM MBSCursor     
			INTO @MBSPromotionId , @MBSPromotionThreshold   
		END     
	CLOSE MBSCursor;    
	DEALLOCATE MBSCursor; 
	--MINIMUM BASKET SPEND

--BEST OFFER -- % Reward is not handled 
	--SELECT * FROM @RewardOffer
	--BASKET BEST OFFER
		SELECT TOP 1 WITH TIES * INTO #BasketBestOffers FROM @RewardOffer WHERE  PromotionType = 'Basket' 
					ORDER BY ROW_NUMBER() OVER(PARTITION BY PromotionId  ORDER BY RewardValue desc,PromotionId)
		DECLARE @BestBasketPromotionId INT,@BestBasketPromotionValue DECIMAL(18,2) ,@BestLineSumPromotionValue DECIMAL(18,2)
		IF EXISTS (SELECT 1 FROM #BasketBestOffers)
		BEGIN
			SELECT TOP 1 @BestBasketPromotionId = PromotionId,@BestBasketPromotionValue = RewardValue FROM #BasketBestOffers ORDER BY RewardValue DESC
			DELETE FROM @RewardOffer WHERE  PromotionType = 'Basket' AND PromotionId != @BestBasketPromotionId 
			--PRINT 'BestBasketPromotionId ' + CONVERT(NVARCHAR(50), @BestBasketPromotionId)
		END
	--END BASKET BEST OFFER
	--LINE BEST OFFER
		--SELECT PromotionId,MAX(RewardValue) RewardValue FROm @RewardOffer WHERE PromotionType = 'LineItem'  GROUP BY LineNumber 
		SELECT TOP 1 WITH TIES * INTO #LineBestOffers FROM @RewardOffer WHERE  PromotionType = 'LineItem' 
					ORDER BY ROW_NUMBER() OVER(PARTITION BY LineNumber  ORDER BY RewardValue desc,PromotionId)
			
		IF EXISTS (SELECT 1 FROM #LineBestOffers)
		BEGIN
			DELETE FROM @RewardOffer WHERE  PromotionType = 'LineItem'
			INSERT INTO @RewardOffer SELECT * FROM #LineBestOffers
			--DELETE FROM @RewardOffer WHERE  PromotionType = 'LineItem' AND PromotionId NOT IN (SELECT DISTINCT PromotionId FROM #LineBestOffers) 
		END
	--END LINE BEST OFFER
	--BEST BASKET OVER LINE
	IF ISNULL(@BestBasketPromotionId,0) > 0 AND EXISTS (SELECT 1 FROM #LineBestOffers)
	BEGIN
		SELECT * INTO #BasketLineNumber FROM @RewardOffer WHERE  PromotionType = 'Basket'
		SELECT @BestLineSumPromotionValue = SUM(RewardValue) FROM @RewardOffer WHERE  PromotionType = 'LineItem' AND LineNumber IN (SELECT LineNumber FROM #BasketLineNumber )
		
		--PRINT 'BEST'
		--PRINT @BestBasketPromotionValue
		--PRINT @BestLineSumPromotionValue
		IF ISNULL(@BestBasketPromotionValue,0) > ISNULL(@BestLineSumPromotionValue,0)
		BEGIN
			DELETE FROM @RewardOffer WHERE  PromotionType = 'LineItem' AND LineNumber IN (SELECT LineNumber FROM #BasketLineNumber)
		END
		ELSE IF ISNULL(@BestLineSumPromotionValue,0) > 0
		BEGIN 
			--SELECT * INTO #LineLineNumber FROM @RewardOffer WHERE  PromotionType = 'LineItem'
			DELETE FROM @RewardOffer WHERE  PromotionType = 'Basket'
		END
	END
	--END 
	--SELECT * FROM @RewardOffer
--END BEST OFFER

	--StampCard
	SELECT * INTO #VirtualStampCard FROM VirtualStampCard WHERE TrxId = @TrxId AND PromotionOfferType IN('Reward','Voucher')
	--SELECT * FROM #tempCode
	--SELECT * FROM #VirtualStampCard

	IF ISNULL(@IsStampClaim,0) = 1
	BEGIN
		PRINT 'Stamp Claim'
		INSERT INTO @RewardOfferSTAMP
	
		SELECT  distinct  CONVERT(varchar(50), p.Id ) as PromotionId, p.Name, tmp.LineNumber, tmp.TrxDetailID, tmp.Points,
		0 as BonusPoints ,pop.Name as OfferType,Case pop.Name when 'Voucher' then 'Voucher' else'Reward' end as Offer, pt.Code,p.CriteriaId, 
		pt.Quantity as itemQuantity, tmp.Quantity as trxQuantity, Cumulation,
		Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardId FROM OpenJson(Reward)WITH (RewardId INT '$.Id'))  end AS RewardId,
		Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardName FROM OpenJson(Reward)WITH (RewardName NVARCHAR(150) '$.Name'))  end AS RewardName,
		Case pop.Name when 'Voucher' then vs.VoucherId  else
		Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT ProductId FROM OpenJson(Reward)WITH (ProductId NVARCHAR(150) '$.RewardId'))  end 
		end AS ProductId,
		Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardValue FROM OpenJson(Reward)WITH (RewardValue decimal(18,2) '$.Value'))  end AS RewardValue
		,tmp.value NetValue,p.QualifyingProductQuantity,vs.PromotionType, vs.StampCardType,0 AS RewardQuantity,'' AS RewardLines,MaxPromoApplicationOnSameBasket,ItemIncludeExclude,
		PromotionThreshold,p.PromotionCategoryId,p.PromotionUsageLimit,p.MaxUsagePerMember,0 AS MaxBasketLimit,'SKU-NA' AS ItemCode,GroupItems,0 AS OnTheFlyQuantity,0 AS OnTheFlyUsedQuantity,p.MisCode
		--into #RewardOffer2
		from Promotion p 
		inner join PromotionOfferType pop on p.PromotionOfferTypeId=pop.Id
		inner join PromotionItem pt on p.id=pt.PromotionId
		inner join PromotionSites ps on p.id=ps.PromotionId
		join #tempCode tmp on  tmp.TrxId = @TrxId
		inner join #VirtualStampCard vs on vs.LineNumber = tmp.LineNumber
		where  p.Id IN(SELECT DISTINCT PromotionId FROM #VirtualStampCard)
		and p.Id not in(SELECT PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
		and p.StartDate<=GETDATE() and p.ENDDate>=GETDATE() and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('Reward','Voucher') 
		and tmp.SiteId in( SELECT SiteId from GetChildSitesBySiteId(ps.siteid))

		--SELECT * FROM @RewardOfferSTAMP
	END
	ELSE
	BEGIN
		INSERT INTO @RewardOfferSTAMP
	
		SELECT  distinct  CONVERT(varchar(50), p.Id ) as PromotionId, p.Name, tmp.LineNumber, tmp.TrxDetailID, tmp.Points,
		0 as BonusPoints ,pop.Name as OfferType,Case pop.Name when 'Voucher' then 'Voucher' else'Reward' end as Offer, pt.Code,p.CriteriaId, 
		pt.Quantity as itemQuantity, tmp.Quantity as trxQuantity, Cumulation,
		Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardId FROM OpenJson(Reward)WITH (RewardId INT '$.Id'))  end AS RewardId,
		Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardName FROM OpenJson(Reward)WITH (RewardName NVARCHAR(150) '$.Name'))  end AS RewardName,
		Case pop.Name when 'Voucher' then vs.VoucherId  else
		Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT ProductId FROM OpenJson(Reward)WITH (ProductId NVARCHAR(150) '$.RewardId'))  end 
		end AS ProductId,
		Case ISJSON (ISNULL(Reward,'')) when 0 then null else (SELECT RewardValue FROM OpenJson(Reward)WITH (RewardValue decimal(18,2) '$.Value'))  end AS RewardValue
		,tmp.value NetValue,p.QualifyingProductQuantity,vs.PromotionType, vs.StampCardType,0 AS RewardQuantity,'' AS RewardLines,MaxPromoApplicationOnSameBasket,ItemIncludeExclude,
		PromotionThreshold,p.PromotionCategoryId,p.PromotionUsageLimit,p.MaxUsagePerMember,0 AS MaxBasketLimit,'SKU-NA' AS ItemCode,GroupItems,0 AS OnTheFlyQuantity,0 AS OnTheFlyUsedQuantity,p.MisCode
		--into #RewardOffer2
		from Promotion p 
		inner join PromotionOfferType pop on p.PromotionOfferTypeId=pop.Id
		inner join PromotionItem pt on p.id=pt.PromotionId
		inner join PromotionSites ps on p.id=ps.PromotionId
		inner join #tempCode tmp on  pt.PromotionItemTypeId=tmp.TypeId
		inner join #VirtualStampCard vs on vs.LineNumber = tmp.LineNumber
		where  RTRIM(LTRIM(pt.Code))= RTRIM(LTRIM(tmp.Code))
		and p.Id IN(SELECT DISTINCT PromotionId FROM #VirtualStampCard)
		and p.Id not in(SELECT PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
		and p.StartDate<=GETDATE() and p.ENDDate>=GETDATE() and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('Reward','Voucher') 
		and tmp.SiteId in( SELECT SiteId from GetChildSitesBySiteId(ps.siteid))
	END

	UPDATE @RewardOfferSTAMP SET RewardName = Name WHERE Offer = 'Voucher'
	--SELECT * FROM @RewardOfferSTAMP
	--BASKET VALUE
		INSERT into @RewardOfferSTAMP
		SELECT * FROM @RewardOffer WHERE PromotionType = 'Basket'
		DELETE @RewardOffer WHERE PromotionType = 'Basket'
	--BASKET VALUE

	SELECT MAX(PromotionId)PromotionId,MAX([Name]) [Name],MIN(LineNumber)LineNumber,
	MIN(TrxDetailID)TrxDetailID,MAX(Points)Points,MAX(BonusPoints)BonusPoints,MAX(OfferType)OfferType,
	MAX(Offer)Offer,MAX(Code)Code,MAX(CriteriaId)CriteriaId,MAX(itemQuantity)itemQuantity,MAX(trxQuantity)trxQuantity,
	MAX(ISNULL(Cumulation,0))Cumulation,MAX(ISNULL(RewardId,0))RewardId,MAX(ISNULL(RewardName,''))RewardName,MAX(ISNULL(ProductId,''))ProductId,MAX(ISNULL(RewardValue,0)) AS RewardValue,MAX(NetValue)NetValue,MAX(ISNULL(QualifyingProductQuantity,0))QualifyingProductQuantity,
	MAX(PromotionType)PromotionType,MAX(StampCardType)StampCardType,0 AS RewardQuantity, '' AS RewardLines,MAX(ISNULL(MaxPromoApplicationOnSameBasket,0)) MaxPromoApplicationOnSameBasket,null ItemIncludeExclude,MAX(ISNULL(PromotionThreshold,0)) PromotionThreshold,MAX(ISNULL(PromotionCategoryId,0))PromotionCategoryId,
	MAX(ISNULL(PromotionUsageLimit,0)) AS PromotionUsageLimit, MAX(ISNULL(MaxUsagePerMember,0)) AS MaxUsagePerMember,0 AS MaxBasketLimit,'SKU-NA' AS ItemCode, MAX(CONVERT(int,ISNULL(GroupItems,0))) GroupItems,0 AS OnTheFlyQuantity,0 AS OnTheFlyUsedQuantity,MAX(ISNULL(MisCode,'')) AS MisCode
	INTO #RewardOfferBasketDistinct
	FROM  @RewardOfferSTAMP GROUP BY PromotionId,LineNumber

	--SELECT * FROM #RewardOfferBasketDistinct
	DECLARE @PromotionId INT ,@rewardOfferStampCardType VARCHAR(25),@offerType VARCHAR(25)
	DECLARE RewardOffer2Cursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
	SELECT DISTINCT PromotionId,StampCardType,OfferType FROM #RewardOfferBasketDistinct  WHERE PromotionType = 'Basket'
	OPEN RewardOffer2Cursor                                                  
		FETCH NEXT FROM RewardOffer2Cursor           
		INTO @PromotionId,@rewardOfferStampCardType,@offerType                             
		WHILE @@FETCH_STATUS = 0 
		BEGIN 
			Declare @RewardLine NVARCHAR(250), @BeforeValue INT,@QualifyingProductQuantity DECIMAL(18,2),@RewardQuantityCal INT

			SELECT MAX(ISNULL(QualifyingProductQuantity,0))QualifyingProductQuantity, STUFF((SELECT ', ' + CAST(LineNumber AS VARCHAR(10)) [text()]
					 FROM #RewardOfferBasketDistinct 
					 WHERE PromotionId = t.PromotionId
					 FOR XML PATH(''), TYPE)
					.value('.','NVARCHAR(MAX)'),1,2,' ') RewardLine
					INTO #RewardLines
			FROM #RewardOfferBasketDistinct t
			WHERE PromotionId = @PromotionId
			GROUP BY PromotionId

			SELECT TOP 1 @RewardLine = RewardLine,@QualifyingProductQuantity = QualifyingProductQuantity FROM #RewardLines
			DROP TABLE #RewardLines

			SET @RewardLine = REPLACE(@RewardLine,' ','')

			IF ISNULL (@MemberId,0) > 0
			BEGIN
				SELECT @BeforeValue = ISNULL(BeforeValue,0) * -1 FROM [PromotionStampCounter] where UserId = @MemberId AND PromotionId = @PromotionId
			END
			ELSE IF ISNULL (@DeviceIdentifier,0) > 0
			BEGIN 
				SELECT @BeforeValue = ISNULL(BeforeValue,0) * -1 FROM [PromotionStampCounter] where ISNULL(UserId,0) = 0 AND ISNULL(DeviceIdentifier,0) = @DeviceIdentifier AND PromotionId = @PromotionId
			END
			

			PRINT 'LineNumbers ' + @RewardLine
			IF ISNULL(@rewardOfferStampCardType,'') = '' 
			BEGIN
				SET @RewardQuantityCal = 1
			END
			ELSE
				BEGIN
				IF @BeforeValue > 0 AND @QualifyingProductQuantity > 0
				BEGIN
					SET @RewardQuantityCal = FLOOR(@BeforeValue/@QualifyingProductQuantity)
				END
				ELSE
				BEGIN
					SET @RewardQuantityCal = 0
				END
			END

			SELECT MAX(PromotionId)PromotionId,MAX([Name]) [Name],MIN(LineNumber)LineNumber,
			MIN(TrxDetailID)TrxDetailID,SUM(Points)Points,SUM(BonusPoints)BonusPoints,MAX(OfferType)OfferType,
			MAX(Offer)Offer,MAX(Code)Code,MAX(CriteriaId)CriteriaId,MAX(itemQuantity)itemQuantity,SUM(trxQuantity)trxQuantity,
			MAX(ISNULL(Cumulation,0))Cumulation,MAX(ISNULL(RewardId,0))RewardId,MAX(ISNULL(RewardName,''))RewardName,MAX(ISNULL(ProductId,''))ProductId,MAX(ISNULL(RewardValue,0)) AS RewardValue,SUM(NetValue)NetValue,MAX(ISNULL(QualifyingProductQuantity,0))QualifyingProductQuantity,
			MAX(PromotionType)PromotionType,MAX(StampCardType)StampCardType,@RewardQuantityCal AS RewardQuantity, @RewardLine AS RewardLines,MAX(ISNULL(MaxPromoApplicationOnSameBasket,0)) MaxPromoApplicationOnSameBasket,null ItemIncludeExclude,MAX(ISNULL(PromotionThreshold,0)) PromotionThreshold,MAX(ISNULL(PromotionCategoryId,0))PromotionCategoryId,
			MAX(ISNULL(PromotionUsageLimit,0)) AS PromotionUsageLimit, MAX(ISNULL(MaxUsagePerMember,0)) AS MaxUsagePerMember,0 AS MaxBasketLimit,'SKU-NA' AS ItemCode, MAX(CONVERT(int,ISNULL(GroupItems,0))) GroupItems,0 AS OnTheFlyQuantity,0 AS OnTheFlyUsedQuantity,MAX(ISNULL(MisCode,'')) AS MisCode
			INTO #RewardOfferStamp
			FROM  #RewardOfferBasketDistinct WHERE PromotionId = @PromotionId GROUP BY PromotionId

			IF EXISTS (SELECT 1 FROM #RewardOfferStamp WHERE RewardQuantity > 0)
			BEGIN
				INSERT INTO @RewardOffer SELECT * FROM #RewardOfferStamp  WHERE RewardQuantity > 0
			END

			DROP TABLE #RewardOfferStamp
			FETCH NEXT FROM RewardOffer2Cursor     
			INTO @PromotionId,@rewardOfferStampCardType,@offerType
		END     
	CLOSE RewardOffer2Cursor;    
	DEALLOCATE RewardOffer2Cursor; 
	--END StampCard
	--SELECT * FROM @RewardOffer
	--UPDATE @RewardOffer SET MaxUsagePerMember = 0 ,MaxPromoApplicationOnSameBasket = 0

	UPDATE @RewardOffer
	SET ItemCode = TC.ItemCode
	FROM @RewardOffer RO
	INNER JOIN #itemcode TC
	ON RO.TrxDetailID = TC.TrxDetailID
	WHERE TC.ItemCode IS NOT NULL AND RO.GroupItems = 1 -- TODO SAVE GroupItems from Promo Screen

	---------------------REWARD PROMO TRX---------------
	Declare @newrewardtrxId int
	--SELECT * FROm @RewardOffer
	IF EXISTS (Select 1 from @RewardOffer)
		BEGIN
				--UPDATE MaxPromoApplicationOnSameBasket 
				DECLARE @rewardPromoIdR int,@rewardTrxDetailIDR int,@rewardItemCodeR NVARCHAR(150)
				DECLARE db_cursorR CURSOR FOR  
				SELECT PromotionId,TrxDetailID, ItemCode from @RewardOffer
				-----------------------------------------------------
				OPEN db_cursorR  
				FETCH NEXT FROM db_cursorR INTO @rewardPromoIdR,@rewardTrxDetailIDR,@rewardItemCodeR

				WHILE @@FETCH_STATUS = 0  
				BEGIN
					DECLARE @UsedCountR INT, @maxPromoApplicationOnSameBasketR INT,@MaxUsagePerMemberR INT,@RewardQuantityR INT,@StampCardTypeR NVARCHAR(25),@StampCardQualifyingProductQuantityR INT
					
					--SET @UsedCountR=(SELECT count(promotionid) from [PromotionRedemptionCount] WITH(NOLOCK) where [MemberId] = @MemberId and  PromotionId = @rewardPromoIdR AND ItemCode = @rewardItemCodeR)
					SET @UsedCountR= [dbo].[PromotionUsage](@MemberId,@rewardPromoIdR,@rewardItemCodeR)

					SELECT TOP 1 @MaxUsagePerMemberR = isnull(MaxUsagePerMember,0),
					@maxPromoApplicationOnSameBasketR =isnull(MaxPromoApplicationOnSameBasket,0),
					@StampCardTypeR= isnull(StampCardType,''),@StampCardQualifyingProductQuantityR = isnull(QualifyingProductQuantity,0),
					@RewardQuantityR = ISNULL(RewardQuantity,0)
					from @RewardOffer where PromotionId = @rewardPromoIdR AND ItemCode = @rewardItemCodeR

					--SET @maxPromoApplicationOnSameBasketR = (SELECT TOP 1 isnull(MaxPromoApplicationOnSameBasket,0) FROM @RewardOffer WHERE PromotionId = @rewardPromoIdR)
					
					IF ISNULL(@maxPromoApplicationOnSameBasketR,0) > 0 AND ISNULL(@maxPromoApplicationOnSameBasketR,0) > (ISNULL(@MaxUsagePerMemberR,0) - ISNULL(@UsedCountR,0)) AND ISNULL(@MaxUsagePerMemberR,0) > 0
					BEGIN
						SET @maxPromoApplicationOnSameBasketR =  (ISNULL(@MaxUsagePerMemberR,0) - ISNULL(@UsedCountR,0))
						UPDATE @RewardOffer SET MaxPromoApplicationOnSameBasket = @maxPromoApplicationOnSameBasketR WHERE PromotionId = @rewardPromoIdR AND ItemCode = @rewardItemCodeR
					END

					if(isnull(@StampCardTypeR,'') != '' AND @RewardQuantityR > 0)
					BEGIN
						--PRINT @StampCardTypeR
						--PRINT @StampCardQualifyingProductQuantityR
						--PRINT @RewardQuantityR
						--PRINT @RewardQuantityR - @maxPromoApplicationOnSameBasketR

						IF @RewardQuantityR > ISNULL(@maxPromoApplicationOnSameBasketR,0) AND ISNULL(@maxPromoApplicationOnSameBasketR,0) > 0
						BEGIN
							DECLARE @AfterValueRC INT
							SET @AfterValueRC  = (@RewardQuantityR - ISNULL(@maxPromoApplicationOnSameBasketR,0)) * ISNULL(@StampCardQualifyingProductQuantityR,0)
							--PRINT @AfterValueRC
							--IF ISNULL(@MemberId,0) > 0
							--BEGIN
								IF ISNULL (@MemberId,0) > 0
								BEGIN
									UPDATE [PromotionStampCounter] SET AfterValue = AfterValue + @AfterValueRC  Where Userid = @MemberId AND PromotionId = @rewardPromoIdR
								END
								ELSE IF ISNULL (@DeviceIdentifier,0) > 0
								BEGIN 
									UPDATE [PromotionStampCounter] SET AfterValue = AfterValue + @AfterValueRC  Where ISNULL(Userid,0) = 0 AND ISNULL(DeviceIdentifier,0) = @DeviceIdentifier AND PromotionId = @rewardPromoIdR
								END
								
							--END

							UPDATE @RewardOffer SET RewardQuantity = @maxPromoApplicationOnSameBasketR 
							WHERE PromotionId = @rewardPromoIdR --AND ItemCode = @rewardItemCodeR
						END

					END

					

				FETCH NEXT FROM db_cursorR INTO @rewardPromoIdR,@rewardTrxDetailIDR,@rewardItemCodeR
				END
				CLOSE db_cursorR;    
				DEALLOCATE db_cursorR; 
				--SELECT * FROm @RewardOffer
				--END MaxPromoApplicationOnSameBasket

				--StampcardDefaultVoucher START
				--Voucher Section
					DECLARE @DefaultVoucher NVARCHAR(25)
					SELECT * INTO #OTFVoucherOffer FROM @RewardOffer WHERE StampCardType = 'StampCardQuantity' AND Offer = 'Voucher' AND OfferType = 'Voucher' AND RewardQuantity > 0		
					IF EXISTS(SELECT 1 FROM #OTFVoucherOffer)
					BEGIN
						SELECT @DefaultVoucher = [Value] FROM ClientConfig Where [Key] = 'StampcardDefaultVoucher' AND ClientId = @ClientId
						IF ISNULL(@DefaultVoucher,'') != ''
						BEGIN
							DECLARE @OTFPromotionId INT,@OFTQuantity INT
							DECLARE @OTFStampVoucherOffer TABLE	(RewardQuantity INT,QualifyingProductQuantity float,PromotionId VARCHAR(50),OnTheFlyQuantity INT)

							IF ISNULL (@MemberId,0) > 0
							BEGIN
								INSERT INTO @OTFStampVoucherOffer
								SELECT vt.RewardQuantity,vt.QualifyingProductQuantity,vt.PromotionId,ps.OnTheFlyQuantity FROM #OTFVoucherOffer vt 
								INNER JOIN PromotionStampCounter ps with(nolock) on vt.PromotionId = ps.PromotionId and ps.UserId = @MemberId
							END
							ELSE IF ISNULL (@DeviceIdentifier,0) > 0
							BEGIN 
								INSERT INTO @OTFStampVoucherOffer
								SELECT vt.RewardQuantity,vt.QualifyingProductQuantity,vt.PromotionId,ps.OnTheFlyQuantity FROM #OTFVoucherOffer vt 
								INNER JOIN PromotionStampCounter ps with(nolock) on vt.PromotionId = ps.PromotionId and ISNULL(ps.UserId,0) = 0 AND ISNULL(ps.DeviceIdentifier,0) = @DeviceIdentifier
							END

							DECLARE VoucherOfferCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
							SELECT PromotionId,ISNULL(OnTheFlyQuantity,0) OnTheFlyQuantity FROM @OTFStampVoucherOffer WHERE ISNULL(OnTheFlyQuantity,0) > 0    
							OPEN VoucherOfferCursor                                                  
								FETCH NEXT FROM VoucherOfferCursor           
								INTO @OTFPromotionId,@OFTQuantity                           
								WHILE @@FETCH_STATUS = 0 
								BEGIN 
									PRINT '---------------------------'
									--SELECT * FROM #OTFStampVoucherOffer
									DECLARE @OFTUsedQty INT;

									select @OFTUsedQty = Count(td.linenumber)
									from trxvoucherdetail tv with(nolock) inner join trxdetail td with(nolock) on tv.trxdetailid = td.trxdetailid 
									where  trxid = @TrxId AND TrxVoucherId = @DefaultVoucher + convert(nvarchar(25),@OTFPromotionId)

									UPDATE @RewardOffer SET OnTheFlyQuantity =ISNULL(@OFTQuantity,0), OnTheFlyUsedQuantity = ISNULL(@OFTUsedQty,0) WHERE StampCardType = 'StampCardQuantity' AND Offer = 'Voucher' AND OfferType = 'Voucher' AND RewardQuantity > 0	AND PromotionId = @OTFPromotionId
									PRINT '--------------------------'
									FETCH NEXT FROM VoucherOfferCursor     
									INTO @OTFPromotionId,@OFTQuantity 
								END     
							CLOSE VoucherOfferCursor;    
							DEALLOCATE VoucherOfferCursor; 
						END
					END
					--SELECT * FROM @RewardOffer
					
				--StampcardDefaultVoucher END

			Declare @trxTypeReward int,@trxstatusStarted int,@trxstatusCancelled int,@rewarditemCode varchar(50),@promoCritera int,@rewardQuantity INT,@rewardLines NVARCHAR(250),@stampCardType NVARCHAR(25),@maxPromoApplicationOnSameBasket INT,@PromotionType VARCHAR(25),@NetValue DECIMAL(18,2),@PromotionThreshold float,@PromotionCategoryId INT,@PromotionUsageLimit INT,@MaxUsagePerMember INT,@OnTheFlyQuantity INT,@OnTheFlyUsedQuantity INT; 
			Declare @trxDetailId int,@rewardPromoId int,@rewardId int,@rewardpromoitemQty int,@trxitemQty int,@RewardProductId NVARCHAR(50),@rewardValue Decimal(18,2),@rewardOfferType NVARCHAR(25),@rewardName  VARCHAR(250),@ItemCode NVARCHAR(150),@CurQualifyingProductQuantity DECIMAL(18,2),@MisCode NVARCHAR(50);
			
			select @trxTypeReward= TrxTypeId from TrxType WITH(NOLOCK) where Name='Reward' and ClientId=@ClientId;
			SELECT @trxstatusStarted = TrxStatusId FROM TrxStatus WITH(NOLOCK) WHERE [Name]='Started' AND Clientid = @ClientId;
			
			--NEXT VOUCHER PARAM
			DECLARE @Result VARCHAR(500) = '', @ResultQty INT = 0,@VoucherProfile NVARCHAR(250)
			--insert new trxtype Reward for the original trx (@trxid) 
			--and link the new reward trx with original trx by adding trxid to OLD_TrxId field
				
				DECLARE @CheckNumber INT = NULL,@CurrentBalance Decimal(18,2);
				DECLARE @TrxDetailEntry INT = 0,@PromotionRedemptionCounter INT = 0,@PromotionRedemptionCounterLimit INT = 0

				SELECT @CurrentBalance = ISNULL(PointsBalance,0) FROM Account WHERE AccountId = @AccountId

				INSERT INTO TrxHeader
							(ClientId,DeviceId,TrxTypeId,TrxDate,CreateDate,SiteId,Reference,OpId,TrxStatusTypeId,EposTrxId,OLD_TrxId,ImportUniqueId,AccountPointsBalance)
				VALUES      (@ClientId,@LoyaltyDevice,@trxTypeReward,@TrxdateTime,GETDATE(),@SiteId, @reference,'0',@trxstatusStarted,null,@TrxId,@ApplicationNumber,ISNULL(@CurrentBalance,0));
				set @newrewardtrxId =SCOPE_IDENTITY();
				DECLARE @maxPromoApplicationOnSameBasketLimit INT = 0;

				-- loop through each trxdetail and add entry for the new reward trx

				DECLARE db_cursor CURSOR FOR  
				SELECT DISTINCT trxdetailid,PromotionId,RewardId,itemQuantity,trxQuantity,ISNULL(CriteriaId,@CriteriaIdValue) AS CriteriaId,RewardQuantity,RewardLines,StampCardType,MaxPromoApplicationOnSameBasket ,PromotionType,NetValue,PromotionThreshold,ProductId,PromotionCategoryId,RewardValue,ISNULL(PromotionUsageLimit,0) AS PromotionUsageLimit,ISNULL(MaxUsagePerMember,0) MaxUsagePerMember,Offer,RewardName,ItemCode,OnTheFlyQuantity ,OnTheFlyUsedQuantity,QualifyingProductQuantity,MisCode from @RewardOffer ORDER BY trxdetailid ASC
				-----------------------------------------------------
				OPEN db_cursor  
				FETCH NEXT FROM db_cursor INTO @trxDetailId ,@rewardPromoId ,@rewardId,@rewardpromoitemQty,@trxitemQty,@promoCritera,@rewardQuantity,@rewardLines,@stampCardType,@maxPromoApplicationOnSameBasket,@PromotionType,@NetValue,@PromotionThreshold,@RewardProductId,@PromotionCategoryId,@rewardValue,@PromotionUsageLimit,@MaxUsagePerMember,@rewardOfferType,@rewardName,@ItemCode,@OnTheFlyQuantity ,@OnTheFlyUsedQuantity ,@CurQualifyingProductQuantity,@MisCode

				WHILE @@FETCH_STATUS = 0  
				BEGIN

				SELECT TOP 1 @maxPromoApplicationOnSameBasketLimit = MaxBasketLimit FROm @RewardOffer WHERE PromotionId =@rewardPromoId AND ItemCode = @ItemCode
				--PRINT @maxPromoApplicationOnSameBasketLimit

				DECLARE @DESCRIPTION VARCHAR(250) = ''
				IF ISNULL(@PromotionCategoryId,0) = ISNULL(@PromotionCategoryRebateId,1)
				BEGIN
					SET @DESCRIPTION = 'Rebate ';
				END

				IF ISNULL(@PromotionCategoryId,0) = ISNULL(@PromotionCategoryRebateId,1) AND ISNULL(@CheckNumber,0) = 0
				BEGIN
					SELECT @CheckNumber = MAX(ISNULL(EposTrxId,0)) 
					FROM TrxDetail td WITH(NOLOCK) INNER JOIN TrxHeader th WITH(NOLOCK) ON td.TrxID = th.TrxId 
					WHERE th.ClientId = @ClientId AND EposTrxId IS NOT NULL AND th.TrxtypeId = @TrxtypeIdReward

					SET @CheckNumber = ISNULL(@CheckNumber,0) + 1;

					IF ISNULL(@CheckNumber,0) != 0
					BEGIN
						UPDATE TrxHeader SET EposTrxId = @CheckNumber  WHERE TrxId = @newrewardtrxId
					END
				END

				DECLARE @RewardIdAndProductId NVARCHAR(100)=''
				IF ISNULL(@rewardId,0) > 0 AND ISNULL(@RewardProductId,'')<>''
				BEGIN
					SET @RewardIdAndProductId = @RewardProductId + '/' +  CONVERT(NVARCHAR(10),@rewardId)
				END
				DECLARE @LimitExceeded INT = 0
				-- Promotion Usage Filter Per Member
				-- check if any user promotion limit filter is set
				DECLARE @UsedCount INT=0
				IF(@MaxUsagePerMember > 0)
				BEGIN				 
					--SET @UsedCount=(SELECT count(promotionid) from [PromotionRedemptionCount] WITH(NOLOCK) where [MemberId] = @MemberId and  PromotionId = @rewardPromoId AND ItemCode = @ItemCode)
					SET @UsedCount= [dbo].[PromotionUsage](@MemberId,@rewardPromoId,@ItemCode)
					-- check user total redeem count with the user promotion limit count set
					IF (isnull(@UsedCount,0)>= @MaxUsagePerMember)
					BEGIN
						-- if count reach the limit count then we remove the promotions
						delete from @RewardOffer where TrxDetailID=@TRXDETAILID and PromotionId=@rewardPromoId AND ItemCode = @ItemCode
						SET @LimitExceeded = 1
					END			 
				END	
				-- Max Trx Limit for Promotion
				DECLARE @maxTrxCountforPromtion INT--, @trxStatus int;

				IF(@PromotionUsageLimit>0)
				BEGIN				 
					--SELECT @trxStatus = TrxStatusId  from TrxStatus where Name='Completed' AND Clientid = @Clientid;
					---- SELECT total completed trx which hit the passed in promotion 
					--with cte as (
					--	SELECT th.TrxId  as TotalTrxCount from  TrxDetailPromotion tp
					--	inner join trxdetail td on td.TrxDetailID = tp.TrxDetailId 
					--	inner join trxheader th on th.trxid= td.TrxId		
					--		where tp.promotionid=@rewardPromoId and th.TrxStatusTypeId = @trxStatus
					--		group by th.trxid
					--)
					--SELECT @maxTrxCountforPromtion = count(TotalTrxCount) from cte 
					---- IF trx count > promotionusage limit remove the trxdetails with that particular promotion  

					--SET @maxTrxCountforPromtion=(SELECT count(promotionid) from [PromotionRedemptionCount] WITH(NOLOCK) where PromotionId = @rewardPromoId)
					SET @maxTrxCountforPromtion= [dbo].[PromotionUsage](0,@rewardPromoId,null)

					PRINT '@maxTrxCountforPromtion =' + CONVERT(NVARCHAR(10),@maxTrxCountforPromtion)

					IF (@maxTrxCountforPromtion>= @PromotionUsageLimit)
					BEGIN
						-- remove the promotion for the trxdetail temptable,so it will not be considered in bestoffer rule
						delete from @RewardOffer where TrxDetailID=@TRXDETAILID and PromotionId=@rewardPromoId --AND ItemCode = @ItemCode
						SET @LimitExceeded = 1
					END			 
				END
				
			IF(ISNULL(@PromotionType,'')='Basket')
			BEGIN
				DECLARE @PNetValue DECIMAL(18,2) = 0
				SELECT @PNetValue = SUM(ISNULL(NetValue,0)) FROM @RewardOffer WHERE PromotionId=@rewardPromoId AND NetValue > 0
				IF ISNULL(@PNetValue,0) < ISNULL(@PromotionThreshold,0) AND ISNULL(@PNetValue,0) > 0 AND ISNULL(@PromotionThreshold,0) > 0
				BEGIN
					SET @LimitExceeded = 1
				END
			END	
				
			IF ISNULL(@LimitExceeded,0) = 0
			BEGIN
				--VALUE PROMOTIONS
				IF @promoCritera =  @CriteriaIdValue
				BEGIN
					
					
					IF(ISNULL(@PromotionType,'')='Basket')
					BEGIN
						PRINT 'VALUE BASKET'
						SET @DESCRIPTION = @DESCRIPTION + 'Reward Offer LineNumbers : ' + ISNULL(@rewardLines,'')	
					END
					ELSE
					BEGIN
						PRINT 'VALUE LINEITEM'
						SET @DESCRIPTION = @DESCRIPTION + 'Reward Offer'
					END

					IF ISNULL(@stampCardType,'')='' --NORMAL VALUE PROMOTIONS
					BEGIN
							SET @TrxDetailEntry = 1
							PRINT 'NORMAL VALUE PROMOTIONS'
							INSERT INTO TrxDetail
									([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,LoyaltyDiscount,PromotionItemId,AuthorisationNr,Anal1,Anal2,Anal3,Anal4,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10)
							select '1', @newrewardtrxId,LineNumber,ItemCode,@DESCRIPTION,
							Case @promoCritera when @CriteriaIdQuantity  then (@trxitemQty/@rewardpromoitemQty)when @CriteriaIdValue then 1 else 1 end,--1 is value & 2 is quantity criteria
							@rewardValue,0,0, @rewardPromoId, 0,0,PromotionItemId,@RewardIdAndProductId,Anal1,Anal2,Anal3,Anal4,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10 from TrxDetail where TrxDetailID=@TRXDETAILID
							
							insert into TrxDetailPromotion values (0,@rewardPromoId,@TRXDETAILID,@rewardValue)

							IF ISNULL(@MemberId,0) != 0 --AND not exists(SELECT 1 from [PromotionRedemptionCount] where promotionid = @rewardPromoId and trxid=@Trxid)
							BEGIN
								IF @promoCritera = @CriteriaIdQuantity
								BEGIN
									SET @PromotionRedemptionCounterLimit = ISNULL((@trxitemQty/@rewardpromoitemQty),0)
									SET @PromotionRedemptionCounter=1
									WHILE ( @PromotionRedemptionCounter <= @PromotionRedemptionCounterLimit)
									BEGIN
										INSERT INTO [dbo].[PromotionRedemptionCount]
										([MemberId],[PromotionId],[LastRedemptionDate],[TrxId],ItemCode)
										VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
										SET @PromotionRedemptionCounter  = @PromotionRedemptionCounter  + 1

										----<<TODO>> AT-2020 SHIFF
										--IF ISNULL(@MisCode,'') != '' AND ISNUMERIC (REPLACE(ISNULL(@MisCode,''),',','')) = 1
										--BEGIN
										--		DELETE FROM @SplitMisCode

										--		INSERT INTO @SplitMisCode
										--		SELECT *  FROM [dbo].[fnSplitString] (@MisCode,',')
				
										--		INSERT INTO [dbo].[PromotionRedemptionCount]
										--		([MemberId]
										--		,[PromotionId]
										--		,[LastRedemptionDate]           
										--		,[TrxId],[ItemCode])
										--		SELECT @MemberId,Cast(p.splitdata as int),GETDATE(),@Trxid,@ItemCode from @SplitMisCode p  
										--		where not exists(SELECT 1 from [PromotionRedemptionCount] with(nolock) where promotionid=Cast(p.splitdata as int) and trxid=@Trxid)AND
										--		ISNUMERIC (ISNULL(p.splitdata,'')) = 1 AND ISNULL(p.splitdata,'') != ''
										--END

									END
								END
								ELSE
								BEGIN
									INSERT INTO [dbo].[PromotionRedemptionCount]
									([MemberId],[PromotionId],[LastRedemptionDate],[TrxId])
									VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid)

									----<<TODO>> AT-2020 SHIFF
									--IF ISNULL(@MisCode,'') != '' AND ISNUMERIC (REPLACE(ISNULL(@MisCode,''),',','')) = 1
									--BEGIN
									--		DELETE FROM @SplitMisCode

									--		INSERT INTO @SplitMisCode
									--		SELECT *  FROM [dbo].[fnSplitString] (@MisCode,',')
				
									--		INSERT INTO [dbo].[PromotionRedemptionCount]
									--		([MemberId]
									--		,[PromotionId]
									--		,[LastRedemptionDate]           
									--		,[TrxId],[ItemCode])
									--		SELECT @MemberId,Cast(p.splitdata as int),GETDATE(),@Trxid,@ItemCode from @SplitMisCode p  
									--		where not exists(SELECT 1 from [PromotionRedemptionCount] with(nolock) where promotionid=Cast(p.splitdata as int) and trxid=@Trxid)AND
									--		ISNUMERIC (ISNULL(p.splitdata,'')) = 1 AND ISNULL(p.splitdata,'') != ''
									--END

								END
							END
					END
					ELSE --STAMPCARD VALUE PROMOTIONS
					BEGIN
						SET @TrxDetailEntry = 1
						IF ISNULL(@rewardOfferType,'') != 'Voucher'
						BEGIN
						PRINT 'STAMPCARD VALUE PROMOTIONS'
						INSERT INTO TrxDetail
								([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,LoyaltyDiscount,PromotionItemId,AuthorisationNr,Anal1,Anal2,Anal3,Anal4,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10)
						select '1', @newrewardtrxId,LineNumber,ItemCode,@DESCRIPTION,@rewardQuantity,
						@rewardValue,0,0, @rewardPromoId, 0,0,PromotionItemId,@RewardIdAndProductId,Anal1,Anal2,Anal3,Anal4,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10 from TrxDetail where TrxDetailID=@TRXDETAILID --AND LineNumber = @lineNumber
						
						insert into TrxDetailPromotion values (0,@rewardPromoId,@TRXDETAILID,@rewardValue * ISNULL(@rewardQuantity,0))

						IF ISNULL(@MemberId,0) != 0 
						BEGIN
								--IF @promoCritera = @CriteriaIdQuantity
								--BEGIN
									SET @PromotionRedemptionCounterLimit = ISNULL(@rewardQuantity,0)
									SET @PromotionRedemptionCounter=1
									WHILE ( @PromotionRedemptionCounter <= @PromotionRedemptionCounterLimit)
									BEGIN
										INSERT INTO [dbo].[PromotionRedemptionCount]
										([MemberId],[PromotionId],[LastRedemptionDate],[TrxId],ItemCode)
										VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
										SET @PromotionRedemptionCounter  = @PromotionRedemptionCounter  + 1

										----<<TODO>> AT-2020 SHIFF
										--IF ISNULL(@MisCode,'') != '' AND ISNUMERIC (REPLACE(ISNULL(@MisCode,''),',','')) = 1
										--BEGIN
										--		DELETE FROM @SplitMisCode

										--		INSERT INTO @SplitMisCode
										--		SELECT *  FROM [dbo].[fnSplitString] (@MisCode,',')
				
										--		INSERT INTO [dbo].[PromotionRedemptionCount]
										--		([MemberId]
										--		,[PromotionId]
										--		,[LastRedemptionDate]           
										--		,[TrxId],[ItemCode])
										--		SELECT @MemberId,Cast(p.splitdata as int),GETDATE(),@Trxid,@ItemCode from @SplitMisCode p  
										--		where not exists(SELECT 1 from [PromotionRedemptionCount] with(nolock) where promotionid=Cast(p.splitdata as int) and trxid=@Trxid)AND
										--		ISNUMERIC (ISNULL(p.splitdata,'')) = 1 AND ISNULL(p.splitdata,'') != ''
										--END

									END
								--END
								--ELSE
								--BEGIN
								--	INSERT INTO [dbo].[PromotionRedemptionCount]
								--	([MemberId],[PromotionId],[LastRedemptionDate],[TrxId])
								--	VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid)
								--END
						END
					END
					ELSE
					BEGIN
						PRINT 'STAMPCARD VALUE VOUCHER PROMOTIONS'
						SET @Result = ''; SET @ResultQty = 0 ; SET @VoucherProfile = '';
						EXEC EPOS_AssignNextAvilableStampCardVoucher @ClientId, @RewardProductId,@rewardQuantity,@MemberId,@Result OUTPUT,@ResultQty OUTPUT,@VoucherProfile OUTPUT,@DeviceIdentifier,@Trxid,@rewardPromoId
						INSERT INTO @VoucherOffer VALUES(@rewardLines,@rewardPromoId,@rewardName, @Result,@VoucherProfile,@ResultQty)
						

						SET @PromotionRedemptionCounterLimit = ISNULL(@rewardQuantity,0)
						SET @PromotionRedemptionCounter=1
						WHILE ( @PromotionRedemptionCounter <= @PromotionRedemptionCounterLimit)
						BEGIN
							INSERT INTO [dbo].[PromotionRedemptionCount]
							([MemberId],[PromotionId],[LastRedemptionDate],[TrxId],ItemCode)
							VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
							SET @PromotionRedemptionCounter  = @PromotionRedemptionCounter  + 1

							----<<TODO>> AT-2020 SHIFF
							--			IF ISNULL(@MisCode,'') != '' AND ISNUMERIC (REPLACE(ISNULL(@MisCode,''),',','')) = 1
							--			BEGIN
							--					DELETE FROM @SplitMisCode

							--					INSERT INTO @SplitMisCode
							--					SELECT *  FROM [dbo].[fnSplitString] (@MisCode,',')
				
							--					INSERT INTO [dbo].[PromotionRedemptionCount]
							--					([MemberId]
							--					,[PromotionId]
							--					,[LastRedemptionDate]           
							--					,[TrxId],[ItemCode])
							--					SELECT @MemberId,Cast(p.splitdata as int),GETDATE(),@Trxid,@ItemCode from @SplitMisCode p  
							--					where not exists(SELECT 1 from [PromotionRedemptionCount] with(nolock) where promotionid=Cast(p.splitdata as int) and trxid=@Trxid)AND
							--					ISNUMERIC (ISNULL(p.splitdata,'')) = 1 AND ISNULL(p.splitdata,'') != ''
							--			END
						END

					END
					END
				END
				ELSE --QTY PROMOTIONS
				BEGIN
				--PRINT @rewardId
				--new reward trx qty is set based on the original trx qty / the qty set on promotion hit
				--so if the qty is two on the new reward trx that means rewards api need to be called twice for fulfilment
				DECLARE @maxPromoApplicationFlag INT= 0, @rewardQty INT = FLOOR(@trxitemQty/@rewardpromoitemQty)
				--PRINT '-------'
				--PRINT @UsedCount
				--PRINT @rewardQty;
				--PRINT @maxPromoApplicationOnSameBasket

				--PRINT '-------'
				IF ISNULL( @rewardQty,0) > 0
				BEGIN
					IF ISNULL(@stampCardType,'')='' --NORMAL QTY PROMOTIONS
					BEGIN
						SET @DESCRIPTION = @DESCRIPTION + 'Reward Offer'
						IF  ISNULL(@maxPromoApplicationOnSameBasket,0) = 0
						BEGIN
							SET @TrxDetailEntry = 1
							PRINT 'NORMAL QTY PROMOTIONS'
							--SET @maxPromoApplicationOnSameBasketLimit +=@rewardQty
							INSERT INTO TrxDetail
									([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,LoyaltyDiscount,PromotionItemId,AuthorisationNr,Anal1,Anal2,Anal3,Anal4,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10)
							select '1', @newrewardtrxId,LineNumber,ItemCode,@DESCRIPTION,
							Case @promoCritera when @CriteriaIdQuantity  then (@trxitemQty/@rewardpromoitemQty)when  @CriteriaIdValue then 1 else 1 end,--1 is value & 2 is quantity criteria
							@rewardValue,0,0, @rewardPromoId, 0,0,PromotionItemId,@RewardIdAndProductId,Anal1,Anal2,Anal3,Anal4,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10 from TrxDetail where TrxDetailID=@TRXDETAILID

							insert into TrxDetailPromotion values (0,@rewardPromoId,@TRXDETAILID,@rewardValue * ISNULL((@trxitemQty/@rewardpromoitemQty),0))

							IF ISNULL(@MemberId,0) != 0 --AND not exists(SELECT 1 from [PromotionRedemptionCount] where promotionid = @rewardPromoId and trxid=@Trxid)
							BEGIN
								IF @promoCritera = @CriteriaIdQuantity
								BEGIN
									SET @PromotionRedemptionCounterLimit = ISNULL(@trxitemQty/@rewardpromoitemQty,0)
									SET @PromotionRedemptionCounter=1
									WHILE ( @PromotionRedemptionCounter <= @PromotionRedemptionCounterLimit)
									BEGIN
										INSERT INTO [dbo].[PromotionRedemptionCount]
										([MemberId],[PromotionId],[LastRedemptionDate],[TrxId],ItemCode)
										VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
										SET @PromotionRedemptionCounter  = @PromotionRedemptionCounter  + 1

										----<<TODO>> AT-2020 SHIFF
										--IF ISNULL(@MisCode,'') != '' AND ISNUMERIC (REPLACE(ISNULL(@MisCode,''),',','')) = 1
										--BEGIN
										--		DELETE FROM @SplitMisCode

										--		INSERT INTO @SplitMisCode
										--		SELECT *  FROM [dbo].[fnSplitString] (@MisCode,',')
				
										--		INSERT INTO [dbo].[PromotionRedemptionCount]
										--		([MemberId]
										--		,[PromotionId]
										--		,[LastRedemptionDate]           
										--		,[TrxId],[ItemCode])
										--		SELECT @MemberId,Cast(p.splitdata as int),GETDATE(),@Trxid,@ItemCode from @SplitMisCode p  
										--		where not exists(SELECT 1 from [PromotionRedemptionCount] with(nolock) where promotionid=Cast(p.splitdata as int) and trxid=@Trxid)AND
										--		ISNUMERIC (ISNULL(p.splitdata,'')) = 1 AND ISNULL(p.splitdata,'') != ''
										--END
									END
								END
								--ELSE
								--BEGIN
								--	INSERT INTO [dbo].[PromotionRedemptionCount]
								--	([MemberId],[PromotionId],[LastRedemptionDate],[TrxId])
								--	VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
								--END
							END
						END
						ELSE
						BEGIN
								WHILE @rewardQty > 0 AND @maxPromoApplicationFlag = 0
								BEGIN
									IF (@maxPromoApplicationOnSameBasketLimit + @rewardQty <= @maxPromoApplicationOnSameBasket)
									BEGIN
										SET @TrxDetailEntry = 1
										PRINT 'NORMAL QTY PROMOTIONS WITH MAX PROMO LIMIT'
										INSERT INTO TrxDetail
													([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,LoyaltyDiscount,PromotionItemId,AuthorisationNr,Anal1,Anal2,Anal3,Anal4,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10)
													select '1', @newrewardtrxId,LineNumber,ItemCode,@DESCRIPTION,
													Case @promoCritera when @CriteriaIdQuantity  then @rewardQty when  @CriteriaIdValue then 1 else 1 end,--1 is value & 2 is quantity criteria
													@rewardValue,0,0, @rewardPromoId, 0,0,PromotionItemId,@RewardIdAndProductId,Anal1,Anal2,Anal3,Anal4,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10 from TrxDetail where TrxDetailID=@TRXDETAILID
													
													insert into TrxDetailPromotion values (0,@rewardPromoId,@TRXDETAILID,@rewardValue * ISNULL(@rewardQty,0))

													IF ISNULL(@MemberId,0) != 0 --AND not exists(SELECT 1 from [PromotionRedemptionCount] where promotionid = @rewardPromoId and trxid=@Trxid)
													BEGIN
														IF @promoCritera = @CriteriaIdQuantity
														BEGIN
															SET @PromotionRedemptionCounterLimit = ISNULL(@rewardQty,0)
															SET @PromotionRedemptionCounter=1
															WHILE ( @PromotionRedemptionCounter <= @PromotionRedemptionCounterLimit)
															BEGIN
																INSERT INTO [dbo].[PromotionRedemptionCount]
																([MemberId],[PromotionId],[LastRedemptionDate],[TrxId],ItemCode)
																VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
																SET @PromotionRedemptionCounter  = @PromotionRedemptionCounter  + 1

										----<<TODO>> AT-2020 SHIFF
										--IF ISNULL(@MisCode,'') != '' AND ISNUMERIC (REPLACE(ISNULL(@MisCode,''),',','')) = 1
										--BEGIN
										--		DELETE FROM @SplitMisCode

										--		INSERT INTO @SplitMisCode
										--		SELECT *  FROM [dbo].[fnSplitString] (@MisCode,',')
				
										--		INSERT INTO [dbo].[PromotionRedemptionCount]
										--		([MemberId]
										--		,[PromotionId]
										--		,[LastRedemptionDate]           
										--		,[TrxId],[ItemCode])
										--		SELECT @MemberId,Cast(p.splitdata as int),GETDATE(),@Trxid,@ItemCode from @SplitMisCode p  
										--		where not exists(SELECT 1 from [PromotionRedemptionCount] with(nolock) where promotionid=Cast(p.splitdata as int) and trxid=@Trxid)AND
										--		ISNUMERIC (ISNULL(p.splitdata,'')) = 1 AND ISNULL(p.splitdata,'') != ''
										--END
															END
														END
														--ELSE
														--BEGIN
														--	INSERT INTO [dbo].[PromotionRedemptionCount]
														--	([MemberId],[PromotionId],[LastRedemptionDate],[TrxId])
														--	VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
														--END
													END
										SET @maxPromoApplicationFlag = 1
										SET @maxPromoApplicationOnSameBasketLimit = @maxPromoApplicationOnSameBasketLimit + @rewardQty
										UPDATE @RewardOffer SET MaxBasketLimit = @maxPromoApplicationOnSameBasketLimit WHERE PromotionId = @rewardPromoId AND Itemcode = @ItemCode
									END
									SET @rewardQty=@rewardQty-1
								END
						END
					END
					ELSE --STAMPCARD QTY PROMOTIONS
					BEGIN
						--PRINT @rewardOfferType
						SET @DESCRIPTION = @DESCRIPTION +' ' + @rewardOfferType + ' Offer LineNumbers : ' + ISNULL(@rewardLines,'')	
						IF ISNULL(@rewardOfferType,'') != 'Voucher'
						BEGIN
						PRINT 'STAMPCARD QTY PROMOTIONS'
						SET @TrxDetailEntry = 1
						INSERT INTO TrxDetail
								([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,LoyaltyDiscount,PromotionItemId,AuthorisationNr,Anal1,Anal2,Anal3,Anal4,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10)
						select '1', @newrewardtrxId,LineNumber,ItemCode,@DESCRIPTION,@rewardQuantity,
						@rewardValue,0,0, @rewardPromoId, 0,0,PromotionItemId,@RewardIdAndProductId,Anal1,Anal2,Anal3,Anal4,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10 from TrxDetail where TrxDetailID=@TRXDETAILID --AND LineNumber = @lineNumber
					
						insert into TrxDetailPromotion values (0,@rewardPromoId,@TRXDETAILID,@rewardValue * ISNULL(@rewardQuantity,0))

						IF ISNULL(@MemberId,0) != 0 --AND not exists(SELECT 1 from [PromotionRedemptionCount] where promotionid = @rewardPromoId and trxid=@Trxid)
						BEGIN
								IF @promoCritera = @CriteriaIdQuantity
								BEGIN
									SET @PromotionRedemptionCounterLimit = ISNULL(@rewardQuantity,0)
									SET @PromotionRedemptionCounter=1
									WHILE ( @PromotionRedemptionCounter <= @PromotionRedemptionCounterLimit)
									BEGIN
										INSERT INTO [dbo].[PromotionRedemptionCount]
										([MemberId],[PromotionId],[LastRedemptionDate],[TrxId],ItemCode)
										VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
										SET @PromotionRedemptionCounter  = @PromotionRedemptionCounter  + 1

										----<<TODO>> AT-2020 SHIFF
										--IF ISNULL(@MisCode,'') != '' AND ISNUMERIC (REPLACE(ISNULL(@MisCode,''),',','')) = 1
										--BEGIN
										--		DELETE FROM @SplitMisCode

										--		INSERT INTO @SplitMisCode
										--		SELECT *  FROM [dbo].[fnSplitString] (@MisCode,',')
				
										--		INSERT INTO [dbo].[PromotionRedemptionCount]
										--		([MemberId]
										--		,[PromotionId]
										--		,[LastRedemptionDate]           
										--		,[TrxId],[ItemCode])
										--		SELECT @MemberId,Cast(p.splitdata as int),GETDATE(),@Trxid,@ItemCode from @SplitMisCode p  
										--		where not exists(SELECT 1 from [PromotionRedemptionCount] with(nolock) where promotionid=Cast(p.splitdata as int) and trxid=@Trxid)AND
										--		ISNUMERIC (ISNULL(p.splitdata,'')) = 1 AND ISNULL(p.splitdata,'') != ''
										--END
									END
								END
								--ELSE
								--BEGIN
								--	INSERT INTO [dbo].[PromotionRedemptionCount]
								--	([MemberId],[PromotionId],[LastRedemptionDate],[TrxId])
								--	VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
								--END
						END
						--PRINT SCOPE_IDENTITY()
						END
						ELSE --'StampCardQuantity Voucher'
						BEGIN
							--PRINT '-----------'
							--PRINT @rewardQuantity
							--PRINT '-----------'
							IF (ISNULL(@MemberId,0) != 0 OR ISNULL(@DeviceIdentifier,0) > 0) AND ISNULL(@rewardQuantity,0) > 0
							BEGIN
								PRINT 'STAMPCARD QTY Voucher PROMOTIONS'
								SET @TrxDetailEntry = 1
														
								SET @Result = ''; SET @ResultQty = 0 ; SET @VoucherProfile = '';

								--StampcardDefaultVoucher START
								IF ISNULL(@OnTheFlyUsedQuantity,0) > 0 AND ISNULL(@OnTheFlyQuantity,0) > 0 -- On The Fly Voucher Redemtion
								BEGIN
									PRINT'***************************'
									PRINT @rewardQuantity
									PRINT @OnTheFlyQuantity 
									PRINT @OnTheFlyUsedQuantity 
									PRINT @DefaultVoucher
									PRINT @rewardPromoId
									PRINT @trxitemQty
									PRINT @CurQualifyingProductQuantity
									--PRINT'***************************'

									--IF ISNULL(@OnTheFlyUsedQuantity,0) != ISNULL(@OnTheFlyQuantity,0)
									--BEGIN
										
										DECLARE @OFTUnUsedtrxQty INT, @OFTBalanceVoucherQty INT,@NOFTBalanceVoucherQty INT

										IF ISNULL (@MemberId,0) > 0
										BEGIN
											SELECT TOP 1 @OFTUnUsedtrxQty = AfterValue + ABS(BeforeValue) FROM [PromotionStampCounter] WHERE PromotionId = @rewardPromoId and UserId = @MemberId
										END
										ELSE IF ISNULL (@DeviceIdentifier,0) > 0
										BEGIN 
											SELECT TOP 1 @OFTUnUsedtrxQty = AfterValue + ABS(BeforeValue) FROM [PromotionStampCounter] WHERE PromotionId = @rewardPromoId and isnull(UserId,0) = 0 AND ISNULL(DeviceIdentifier,0) = @DeviceIdentifier
										END
										
										SET @OFTUnUsedtrxQty = @OFTUnUsedtrxQty - ((@OnTheFlyUsedQuantity * @CurQualifyingProductQuantity ) + @OnTheFlyUsedQuantity)
										PRINT @OFTUnUsedtrxQty

										SET @OFTBalanceVoucherQty = ISNULL(@OnTheFlyUsedQuantity,0)
										IF ISNULL(@OFTUnUsedtrxQty,0) > 0 AND @OFTUnUsedtrxQty >= @CurQualifyingProductQuantity
										BEGIN											
											SET @NOFTBalanceVoucherQty =  CONVERT(INT, (@OFTUnUsedtrxQty/@CurQualifyingProductQuantity))
											SET @OFTBalanceVoucherQty = @OFTBalanceVoucherQty + @NOFTBalanceVoucherQty
											SET @OFTUnUsedtrxQty = @OFTUnUsedtrxQty - (@NOFTBalanceVoucherQty * @CurQualifyingProductQuantity )
										END

										IF ISNULL(@OFTUnUsedtrxQty,0) < 0
										BEGIN
											SET @OFTUnUsedtrxQty = 0
										END

										PRINT @OFTUnUsedtrxQty
										PRINT @OFTBalanceVoucherQty
										PRINT'***************************'
										
										IF ISNULL (@MemberId,0) > 0
										BEGIN
											UPDATE [PromotionStampCounter] SET AfterValue = @OFTUnUsedtrxQty + @OnTheFlyUsedQuantity WHERE PromotionId = @rewardPromoId and UserId = @MemberId
										END
										ELSE IF ISNULL (@DeviceIdentifier,0) > 0
										BEGIN 
											UPDATE [PromotionStampCounter] SET AfterValue = @OFTUnUsedtrxQty + @OnTheFlyUsedQuantity WHERE PromotionId = @rewardPromoId and ISNULL(UserId,0) = 0 AND ISNULL(DeviceIdentifier,0) = @DeviceIdentifier
										END
										
										
										EXEC EPOS_AssignNextAvilableStampCardVoucher @ClientId, @RewardProductId,@OFTBalanceVoucherQty,@MemberId,@Result OUTPUT,@ResultQty OUTPUT,@VoucherProfile OUTPUT,@DeviceIdentifier,@Trxid,@rewardPromoId
									--END
									--ELSE
									--BEGIN
									--	EXEC EPOS_AssignNextAvilableStampCardVoucher @ClientId, @RewardProductId,@OnTheFlyQuantity,@MemberId,@Result OUTPUT,@ResultQty OUTPUT,@VoucherProfile OUTPUT,@DeviceIdentifier,@Trxid,@rewardPromoId
									--END

									IF ISNULL(@ResultQty,0) > 0
									BEGIN
										
										DROP TABLE IF EXISTS #VoucherList
										SELECT * INTO #VoucherList FROm SplitString(@Result,',')

										DROP TABLE IF EXISTS #UpdateVoucherdetail
										select ROW_NUMBER() OVER(ORDER BY tv.Id ASC) - 1 AS ItemIndex, tv.* INTO #UpdateVoucherdetail
										from trxvoucherdetail tv with(nolock) inner join trxdetail td with(nolock) on tv.trxdetailid = td.trxdetailid 
										where  trxid = @TrxId AND TrxVoucherId = @DefaultVoucher + convert(nvarchar(25),@rewardPromoId)

										DECLARE @OTFVoucherId NVARCHAR(25) = '',@OTFtrxVoucherDetailId INT;

										IF EXISTS (SELECT 1 FROM #UpdateVoucherdetail)
										BEGIN
											DECLARE @UpdateCounter INT= ISNULL(@ResultQty,0),@VoucherDeviceId INT;
											WHILE (@UpdateCounter > 0)
											BEGIN
												SET @UpdateCounter = @UpdateCounter - 1;
												SELECT @OTFVoucherId = token FROM #VoucherList WHERE ItemIndex = @UpdateCounter
												SELECT @OTFtrxVoucherDetailId = Id FROM #UpdateVoucherdetail WHERE ItemIndex = @UpdateCounter
												IF ISNULL(@OTFVoucherId,'') != '' AND ISNULL(@OTFtrxVoucherDetailId,0) >0
												BEGIN
													PRINT'***************************'
													PRINT @OTFVoucherId
													UPDATE TrxVoucherDetail SET TrxVoucherId = @OTFVoucherId Where Id = @OTFtrxVoucherDetailId
													UPDATE Device set @VoucherDeviceId = Id, DeviceStatusId =@DeviceStatusIdInactive  where DeviceId=@OTFVoucherId --AND UserId = @MemberId
													UPDATE DeviceProfile SET StatusId = @ProfileStatusIdInactive WHERE DeviceId = @VoucherDeviceId
													
													IF ISNULL (@MemberId,0) > 0
													BEGIN
														UPDATE [PromotionStampCounter] SET AfterValue = CASE WHEN ISNULL(AfterValue,0) > 0 THEN  AfterValue - 1 ELSE 0 END WHERE PromotionId = @rewardPromoId and UserId = @MemberId
													END
													ELSE IF ISNULL (@DeviceIdentifier,0) > 0
													BEGIN 
														UPDATE [PromotionStampCounter] SET AfterValue = CASE WHEN ISNULL(AfterValue,0) > 0 THEN  AfterValue - 1 ELSE 0 END WHERE PromotionId = @rewardPromoId and ISNULL(UserId,0) = 0 AND ISNULL(@DeviceIdentifier,0) = @DeviceIdentifier
													END
													
													PRINT @VoucherDeviceId
													PRINT'***************************'
												END
											END
										END
									
										INSERT INTO @VoucherOffer VALUES(@rewardLines,@rewardPromoId,@rewardName, @Result,@VoucherProfile,@ResultQty)
										IF @promoCritera = @CriteriaIdQuantity
										BEGIN
											SET @PromotionRedemptionCounterLimit = ISNULL(@OnTheFlyQuantity,0)
											SET @PromotionRedemptionCounter=1
											WHILE ( @PromotionRedemptionCounter <= @PromotionRedemptionCounterLimit)
											BEGIN
												INSERT INTO [dbo].[PromotionRedemptionCount]
												([MemberId],[PromotionId],[LastRedemptionDate],[TrxId],ItemCode)
												VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
												SET @PromotionRedemptionCounter  = @PromotionRedemptionCounter  + 1

										----<<TODO>> AT-2020 SHIFF
										--IF ISNULL(@MisCode,'') != '' AND ISNUMERIC (REPLACE(ISNULL(@MisCode,''),',','')) = 1
										--BEGIN
										--		DELETE FROM @SplitMisCode

										--		INSERT INTO @SplitMisCode
										--		SELECT *  FROM [dbo].[fnSplitString] (@MisCode,',')
				
										--		INSERT INTO [dbo].[PromotionRedemptionCount]
										--		([MemberId]
										--		,[PromotionId]
										--		,[LastRedemptionDate]           
										--		,[TrxId],[ItemCode])
										--		SELECT @MemberId,Cast(p.splitdata as int),GETDATE(),@Trxid,@ItemCode from @SplitMisCode p  
										--		where not exists(SELECT 1 from [PromotionRedemptionCount] with(nolock) where promotionid=Cast(p.splitdata as int) and trxid=@Trxid)AND
										--		ISNUMERIC (ISNULL(p.splitdata,'')) = 1 AND ISNULL(p.splitdata,'') != ''
										--END
											END
										END
									END
								END
								ELSE--StampcardDefaultVoucher END
								BEGIN
									EXEC EPOS_AssignNextAvilableStampCardVoucher @ClientId, @RewardProductId,@rewardQuantity,@MemberId,@Result OUTPUT,@ResultQty OUTPUT,@VoucherProfile OUTPUT,@DeviceIdentifier,@Trxid,@rewardPromoId

									INSERT INTO @VoucherOffer VALUES(@rewardLines,@rewardPromoId,@rewardName, @Result,@VoucherProfile,@ResultQty)
									IF @promoCritera = @CriteriaIdQuantity
									BEGIN
										SET @PromotionRedemptionCounterLimit = ISNULL(@rewardQuantity,0)
										SET @PromotionRedemptionCounter=1
										WHILE ( @PromotionRedemptionCounter <= @PromotionRedemptionCounterLimit)
										BEGIN
											INSERT INTO [dbo].[PromotionRedemptionCount]
											([MemberId],[PromotionId],[LastRedemptionDate],[TrxId],ItemCode)
											VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
											SET @PromotionRedemptionCounter  = @PromotionRedemptionCounter  + 1

										----<<TODO>> AT-2020 SHIFF
										--IF ISNULL(@MisCode,'') != '' AND ISNUMERIC (REPLACE(ISNULL(@MisCode,''),',','')) = 1
										--BEGIN
										--		DELETE FROM @SplitMisCode

										--		INSERT INTO @SplitMisCode
										--		SELECT *  FROM [dbo].[fnSplitString] (@MisCode,',')
				
										--		INSERT INTO [dbo].[PromotionRedemptionCount]
										--		([MemberId]
										--		,[PromotionId]
										--		,[LastRedemptionDate]           
										--		,[TrxId],[ItemCode])
										--		SELECT @MemberId,Cast(p.splitdata as int),GETDATE(),@Trxid,@ItemCode from @SplitMisCode p  
										--		where not exists(SELECT 1 from [PromotionRedemptionCount] with(nolock) where promotionid=Cast(p.splitdata as int) and trxid=@Trxid)AND
										--		ISNUMERIC (ISNULL(p.splitdata,'')) = 1 AND ISNULL(p.splitdata,'') != ''
										--END
										END
									END
								END
								--ELSE
								--BEGIN
								--	INSERT INTO [dbo].[PromotionRedemptionCount]
								--	([MemberId],[PromotionId],[LastRedemptionDate],[TrxId])
								--	VALUES( @MemberId,@rewardPromoId,GETDATE(),@Trxid,@ItemCode)
								--END
							END
						END
					END
				END

				END
			END
				FETCH NEXT FROM db_cursor INTO @trxDetailId ,@rewardPromoId ,@rewardId,@rewardpromoitemQty,@trxitemQty,@promoCritera,@rewardQuantity,@rewardLines,@stampCardType,@maxPromoApplicationOnSameBasket,@PromotionType,@NetValue,@PromotionThreshold,@RewardProductId,@PromotionCategoryId,@rewardValue,@PromotionUsageLimit,@MaxUsagePerMember,@rewardOfferType,@rewardName,@ItemCode,@OnTheFlyQuantity ,@OnTheFlyUsedQuantity ,@CurQualifyingProductQuantity,@MisCode
				END
				CLOSE db_cursor;    
				DEALLOCATE db_cursor; 
				--If Reward / Rebate is not applicable then update the TrxHeader -> TrxStatus Cancelled
				IF ISNULL(@TrxDetailEntry,0) = 0 AND ISNULL(@newrewardtrxId,0) > 0
				BEGIN
					PRINT 'TRX Cancelled'
					SELECT @trxstatusCancelled = TrxStatusId FROM TrxStatus WHERE [Name]='Cancelled' AND Clientid = @ClientId;
					UPDATE TrxHeader SET TrxStatusTypeId = @trxstatusCancelled WHERE TrxId = @newrewardtrxId
				END
					
		END
	---------------------END REWARD PROMO TRX------------
			SELECT distinct td.LineNumber ,CONVERT(varchar(50),r.PromotionId) collate database_default as PromotionId ,
			r.Name as PromotionName,CONVERT(varchar(250),r.RewardId) AS RewardId,r.RewardName as RewardName,td.Quantity,r.RewardLines
			into #Result
			from @RewardOffer r inner join TrxDetail td on td.PromotionID=r.PromotionId
			inner join TrxHeader th on th.TrxId=td.TrxID
			--inner join Rewards rw on rw.RewardId=td.PromotionItemId		
			 where   th.TrxId=@newrewardtrxId
			 
			 --SELECT * FROM @RewardOffer

			 SELECT Case ISNULL(RewardLines,'') when '' then CONVERT(varchar(50),LineNumber) else RewardLines end AS 
			 LineNumber,	PromotionId,	PromotionName,	RewardId,	RewardName,	Quantity,'' AS VoucherIds,'' AS VoucherName 
			 FROM #Result
		     UNION
			 SELECT LineNumber ,PromotionId ,PromotionName,'' RewardId,'' RewardName,Quantity, VoucherIds ,VoucherName FROM @VoucherOffer
			 
				IF ISNULL (@MemberId,0) > 0
				BEGIN
					UPDATE [PromotionStampCounter] SET BeforeValue = 0  where UserId = @MemberId AND PromotionId IN (SELECT DISTINCT PromotionId FROM #Result)
				END
				ELSE IF ISNULL (@DeviceIdentifier,0) > 0
				BEGIN 
					UPDATE [PromotionStampCounter] SET BeforeValue = 0  where ISNULL(UserId,0) = 0 AND ISNULL(DeviceIdentifier,0) = @DeviceIdentifier AND PromotionId IN (SELECT DISTINCT PromotionId FROM #Result)
				END
			 
			 IF ISNULL (@MemberId,0)>0
			 BEGIN
				delete from [VirtualStampCard] where trxid=@TrxId AND PromotionOfferType IN('Reward','Voucher')
			 END
			 PRINT '-------------------------------'
			 PRINT 'New Reward TrxId' + CONVERT(varchar(50),@newrewardtrxId)
			 PRINT '-------------------------------'
	--COMMIT TRAN
	ROLLBACK TRAN     
	                                                      
END TRY                                                        
BEGIN CATCH       
	PRINT 'ERROR'      
	PRINT ERROR_NUMBER() 
	PRINT ERROR_SEVERITY()  
	PRINT ERROR_STATE()
	PRINT ERROR_PROCEDURE() 
	PRINT ERROR_LINE()  
	PRINT ERROR_MESSAGE()                                           
    --ROLLBACK TRAN                                                        
END CATCH       
END
