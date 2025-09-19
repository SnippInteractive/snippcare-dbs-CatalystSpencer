CREATE PROCEDURE [dbo].[GetAllPromotions]    
(    
 @ClientId INT,    
 @SearchCriteria NVARCHAR(MAX)= '',    
 @TotalCount INT OUTPUT,    
 @Result NVARCHAR(MAX) Output    
)    
AS    
BEGIN    
    
SET TRANSACTION ISOLATION LEVEL READ UNcommitTED     
    
 ---------------TEST-------------------    
/* declare @Result nvarchar(max)    
 declare @TotalCount int     
 EXEC GetAllPromotions 2,    
 '{"PromotionType":"Challenge","PromotionOfferType":"","SiteRef":"","StartDate":"","EndDate":"",    
 "IsLoyaltyPromotion":"True","UserId":1453040,"SegmentFilter":"True","ActivityCategoryName":"",    
 "ActivityCategoryTypeName":"","ProductFamilyType":"Brand,pettype",    
 "ProductFamilySubType":"Catit|Cat Love,Cat","PageSize":100,"Page":1}',@TotalCount output, @Result output    
 SELECT @Result    
 */    
     
 -- Checking whether the string is JSON or not.If not, return.    
 --IF ISJSON(@SearchCriteria) <= 0    
 --BEGIN    
 -- PRINT 'Invalid Search Critieria'    
 -- RETURN    
 --END    
    
 -- Checking whether the ClientId is null or 0 or valid, If then, return.    
 IF @ClientId IS NULL OR @ClientId <= 0 OR NOT EXISTS(SELECT 1 FROM Client WHERE ClientId = @ClientId)    
 BEGIN    
  PRINT 'Invalid ClientId'    
  RETURN    
 END    
    
     
 DECLARE @Offset INT    
 DECLARE @TCount TABLE (TotalCount INT)    
 DECLARE @SQL NVARCHAR(MAX)= '',    
   @DROPIFEXISTS NVARCHAR(MAX) = ''    
 DECLARE @DECLARETEMPTABLES NVARCHAR(MAX)= '',    
   @SELECT NVARCHAR(MAX) = '',    
   @FROM NVARCHAR(MAX)='',    
   @SELECTCOUNT NVARCHAR(MAX) = ''    
 DECLARE @UserId INT = CAST(JSON_VALUE(@SearchCriteria,'$.UserId') AS INT)    
 DECLARE @SegmentFilter BIT = CAST(JSON_VALUE(@SearchCriteria,'$.SegmentFilter') AS BIT)    
    
    
 DECLARE @StartDate DATETIME    
    DECLARE @EndDate DATETIME    
    
 SET @DROPIFEXISTS = ' DROP TABLE IF EXISTS #Promotions '    
 SET @DECLARETEMPTABLES = '    
    
 DECLARE @ClientId INT = '+CAST(ISNULL(@ClientId,0)AS VARCHAR(10))    
 IF @UserId > 0    
 BEGIN    
  SET @DECLARETEMPTABLES = @DECLARETEMPTABLES + '    
  DECLARE @UserPromotions TABLE    
  (    
   PromotionId INT,    
   MaxUsagePerMember INT,    
   TrxCount INT    
  )    
  INSERT @UserPromotions(PromotionId,MaxUsagePerMember,TrxCount)    
  SELECT P.Id,ISNULL(P.MaxUsagePerMember,-1),COUNT(*)     
  FROM Promotion P LEFT JOIN ActivityCategory AC ON AC.Id = P.ActivityCategoryId LEFT JOIN PromotionRedemptionCount PRC ON PRC.PromotionId = P.Id      
  WHERE PRC.MemberId = CAST('+CAST(@UserId AS VARCHAR(10))+' AS INT) GROUP BY P.Id,P.ActivityCategoryId,P.MaxUsagePerMember     
    
 DECLARE @UserSiteRelatedPromotion TABLE (Id INT)    
  INSERT @UserSiteRelatedPromotion(Id)    
  SELECT DISTINCT P.Id FROM Promotion P INNER JOIN PromotionSites PS ON P.Id = PS.PromotionId    
  INNER JOIN [dbo].[GetParentSitesByUserId]('+CAST(@UserId AS VARCHAR(100))+','+CAST(@ClientId AS VARCHAR(100))+') US ON PS.SiteId = US.SiteId     
 DECLARE @LoyaltyProfilePromotion TABLE (Id INT)    
  INSERT @LoyaltyProfilePromotion(Id)    
  SELECT P.Id FROM Promotion P INNER JOIN PromotionLoyaltyProfiles PLP ON PLP.PromotionId = P.Id    
  INNER JOIN DeviceProfile DP ON PLP.LoyaltyProfileId = DP.DeviceProfileId INNER JOIN Device D (nolock) ON DP.DeviceId = D.Id WHERE D.UserId = '+CAST(@UserId AS VARCHAR(100))+' '    
    
 IF @SegmentFilter = 1    
 BEGIN    
  SET @DECLARETEMPTABLES = @DECLARETEMPTABLES + '    
  DECLARE @UserSegmentIds TABLE(PromotionId INT,UserId INT)    
  INSERT @UserSegmentIds(PromotionId,UserId)    
  SELECT P.Id,ISNULL(SU.UserId,0) FROM Promotion P INNER JOIN PromotionSegments PS ON P.Id = PS.PromotionId    
  LEFT JOIN (SELECT * FROM SegmentUsers WHERE UserId = '+CAST(@UserId AS VARCHAR(100))+' ) SU ON PS.SegmentId = SU.SegmentId '    
 END    
END    
    
 SET @SELECT =  ' SELECT P.*, PH.HtmlContent AS PromotionHtmlContent, NULL AS RemainingUsagePerMember,    
 ISNULL(PC.Name,'''') AS PromotionCategory, AC.Name AS ActivityCategoryName,    
 ISNULL(ACT.Name,'''') AS ActivityCategoryTypeName,POT.[Name] AS PromotionOfferType   
 INTO #Promotions '    
    
 SET @SELECTCOUNT =' SELECT COUNT(P.Id) '    
    
 SET @FROM = ' FROM Promotion P INNER JOIN [Site] S ON P.SiteId = S.SiteId    
  INNER JOIN  PromotionCategory PC ON P.PromotionCategoryId = PC.Id    
  INNER JOIN  PromotionOfferType POT ON P.PromotionOfferTypeId = POT.Id    
  LEFT JOIN PromotionHtml PH ON PH.PromotionId = P.Id LEFT JOIN ActivityCategory AC     
  ON P.ActivityCategoryId = AC.Id    
 LEFT JOIN ActivityCategoryType ACT ON P.ActivityCategoryTypeId = ACT.Id 
  WHERE S.ClientId = @ClientId    
  AND CAST(P.StartDate AS DATE) <= ''' + CONVERT(char(10), GetDate(),126) + ''' AND CAST(P.EndDate AS DATE) >= ''' + CONVERT(char(10), GetDate(),126) + '''     
  AND PC.ClientId = @ClientId AND P.Enabled = 1 '    
    
 IF @UserId > 0    
 BEGIN    
  SET @FROM = @FROM + '    
  AND P.Id IN (SELECT Id FROM @UserSiteRelatedPromotion) AND P.Id IN (SELECT Id FROM @LoyaltyProfilePromotion)    
  AND P.Id NOT IN (SELECT PromotionId FROM @UserPromotions     
  WHERE ISNULL(MaxUsagePerMember,0) <> 0 AND MaxUsagePerMember <= TrxCount ) '    
    
  IF @SegmentFilter = 1    
  BEGIN    
    
   SELECT  P.Id,ISNULL(SU.UserId,0) UserId into #UserSegmentIds FROM Promotion P INNER JOIN PromotionSegments PS     
   ON P.Id = PS.PromotionId LEFT JOIN (SELECT * FROM SegmentUsers WHERE UserId = @UserId) SU    
   ON PS.SegmentId = SU.SegmentId    
   IF NOT EXISTS(select 1 from #UserSegmentIds where UserId>0)    
   begin    
    SET @FROM = @FROM + 'AND P.Id NOT IN (SELECT PromotionId FROM @UserSegmentIds) '    
   end    
  END    
 END    
    
 -- Filtering with start Date    
 IF  JSON_VALUE(@SearchCriteria,'$.StartDate') IS NOT NULL and JSON_VALUE(@SearchCriteria,'$.StartDate')!=''    
 BEGIN    
      
  SET @StartDate = CASE WHEN ISDATE(JSON_VALUE(@SearchCriteria,'$.StartDate')) > 0     
       THEN CONVERT(DATE, JSON_VALUE(@SearchCriteria,'$.StartDate'))    
       ELSE CONVERT(DATE,JSON_VALUE(@SearchCriteria,'$.StartDate'),103)    
      END    
 END    
    
 IF @StartDate IS NOT NULL    
  BEGIN    
   SET @FROM = @FROM + '    
   AND cast(P.StartDate as date) >=  cast('''+CAST(@StartDate AS VARCHAR(100))+''' as date) '    
  END    
  --else    
  --BEGIN    
  -- SET @FROM = @FROM + '    
  -- AND cast(P.StartDate as date) =  cast(GetDate() as date) '    
  --END    
 -- End Filtering with start Date    
    
    
 -- Filtering with end Date    
 IF JSON_VALUE(@SearchCriteria,'$.EndDate') IS NOT NULL and JSON_VALUE(@SearchCriteria,'$.EndDate')!=''    
 BEGIN    
      
  SET @EndDate = CASE WHEN ISDATE(JSON_VALUE(@SearchCriteria,'$.EndDate')) > 0     
        THEN CONVERT(DATE, JSON_VALUE(@SearchCriteria,'$.EndDate'))    
        ELSE CONVERT(DATE,JSON_VALUE(@SearchCriteria,'$.EndDate'),103)    
       END    
 END    
     
 IF @EndDate IS NOT NULL     
 BEGIN    
  SET @FROM = @FROM + '    
  AND cast(P.EndDate as date) <= cast('''+CAST(@EndDate AS VARCHAR(100))+''' as date) '    
 END    
 --else    
 --BEGIN    
 -- SET @FROM = @FROM + '    
 -- AND cast(P.EndDate as date) = cast(GetDate() as date) '    
 --END    
 -- End Filtering with end Date    
    
 --Filtering whether the promotions are LoyaltyPromotions.    
 IF  JSON_VALUE(@SearchCriteria,'$.IsLoyaltyPromotion') IS NOT NULL     
 BEGIN    
  DECLARE @IsLoyaltyPromotion BIT = CASE LOWER(JSON_VALUE(@SearchCriteria,'$.IsLoyaltyPromotion'))    
            WHEN 'true' THEN 1 ELSE 0 END    
print @IsLoyaltyPromotion    
    
  IF @IsLoyaltyPromotion = 1    
  BEGIN    
   SET @FROM = @FROM + '    
   AND P.Id IN (SELECT PromotionId FROM PromotionLoyaltyProfiles) '    
  END    
 END    
    
 -- Filtering on PromotionType    
 IF ISNULL(JSON_VALUE(@SearchCriteria,'$.PromotionType'),'') <>''     
 BEGIN    
  DECLARE @PromotionCategory VARCHAR(100) = LOWER(JSON_VALUE(@SearchCriteria,'$.PromotionType'))    
  SET @FROM = @FROM + ' AND PC.Name = '''+@PromotionCategory+''' '    
 END    
    
 -- Fitlering on PromotionOfferType    
 IF ISNULL(JSON_VALUE(@SearchCriteria,'$.PromotionOfferType'),'') <>''    
 BEGIN    
  DECLARE @PromotionOfferType VARCHAR(100) = LOWER(JSON_VALUE(@SearchCriteria,'$.PromotionOfferType'))    
  SET @FROM = @FROM + ' AND POT.Name = '''+@PromotionOfferType+''' '    
 END    
    
 -- Filtering on SiteRef    
 IF ISNULL(JSON_VALUE(@SearchCriteria,'$.SiteRef'),'')<>''    
 BEGIN    
  DECLARE @SiteRef VARCHAR(100) = LOWER(LTRIM(RTRIM(JSON_VALUE(@SearchCriteria,'$.SiteRef'))))    
  SET @FROM = @FROM + ' AND LOWER(LTRIM(RTRIM(S.SiteRef))) = '''+@SiteRef+''' '    
 END    
    
 -- Filtering on ActivityCategoryName    
 IF ISNULL(JSON_VALUE(@SearchCriteria,'$.ActivityCategoryName'),'')<>''    
 BEGIN    
  DECLARE @ActivityCategory VARCHAR(100) = LOWER(LTRIM(RTRIM(JSON_VALUE(@SearchCriteria,'$.ActivityCategoryName'))))    
  SET @FROM = @FROM + ' AND LOWER(LTRIM(RTRIM(AC.Name))) = '''+@ActivityCategory+''' '    
 END    
    
 -- Filtering on ActivityCategoryTypeName    
 IF ISNULL(JSON_VALUE(@SearchCriteria,'$.ActivityCategoryTypeName'),'')<>''    
 BEGIN    
  DECLARE @ActivityCategoryType VARCHAR(100) = LOWER(LTRIM(RTRIM(JSON_VALUE(@SearchCriteria,'$.ActivityCategoryTypeName'))))    
  SET @FROM = @FROM + ' AND LOWER(LTRIM(RTRIM(ACT.Name))) = '''+@ActivityCategoryType+''' '    
 END    
    
 ---- Filtering on ProductFamilyType    
 --IF ISNULL(JSON_VALUE(@SearchCriteria,'$.ProductFamilyType'),'')<>''    
 --BEGIN    
 -- DECLARE @ProductFamilyType VARCHAR(100) = LOWER(LTRIM(RTRIM(JSON_VALUE(@SearchCriteria,'$.ProductFamilyType'))))    
 -- SET @FROM = @FROM + ' AND LOWER(LTRIM(RTRIM(PFT.Name))) = '''+LOWER(LTRIM(RTRIM(@ProductFamilyType)))+''' '    
 --END    
    
 ---- Filtering on ProductFamilySubType    
 --IF ISNULL(JSON_VALUE(@SearchCriteria,'$.ProductFamilySubType'),'')<>''    
 --BEGIN    
 -- DECLARE @ProductFamilySubType VARCHAR(100) = LOWER(LTRIM(RTRIM(JSON_VALUE(@SearchCriteria,'$.ProductFamilySubType'))))    
 -- SET @FROM = @FROM + ' AND LOWER(LTRIM(RTRIM(PFS.Name))) = '''+LOWER(LTRIM(RTRIM(@ProductFamilySubType)))+''' '    
 --END    
  
IF (ISNULL(JSON_VALUE(@SearchCriteria,'$.ProductFamilyType'),'')<>'' and ISNULL(JSON_VALUE(@SearchCriteria,'$.ProductFamilySubType'),'')<>'')  
begin  
 DECLARE @ProductFamilyType VARCHAR(100) = LOWER(LTRIM(RTRIM(JSON_VALUE(@SearchCriteria,'$.ProductFamilyType'))))  
 DECLARE @ProductFamilySubType VARCHAR(100) = LOWER(LTRIM(RTRIM(JSON_VALUE(@SearchCriteria,'$.ProductFamilySubType'))))    
 SET @FROM = @FROM + ' AND P.Id IN (SELECT PromotionId FROM dbo.GetProductFamilyTypes('+cast(@ClientId as varchar)+','''+@ProductFamilyType+''','''+@ProductFamilySubType+''')) '    
End  
  
  
    
 -- Fetching RecordsCount - Replacing the Projection with Count ( same query is being used to fetch the count).    
 SET @SQL = @DECLARETEMPTABLES + @SELECTCOUNT + @FROM    
    
 INSERT @TCount(TotalCount)    
 EXEC(@SQL)    
    
 -- Replacing the count with the Projection as fetching the count is achieved.    
 SET @SQL = @DECLARETEMPTABLES + @SELECT + @FROM    
    
 -- Applying Sort(Challenge:the table for the given field has to be found out to implement the sorting.)    
 IF JSON_VALUE(@SearchCriteria,'$.SortProperty') IS NOT NULL AND JSON_VALUE(@SearchCriteria,'$.SortDirection') IS NOT NULL    
 BEGIN    
  DECLARE @SortProperty VARCHAR(100) = CAST(JSON_VALUE(@SearchCriteria,'$.SortProperty') AS VARCHAR(100))    
  DECLARE @SortDirection VARCHAR(100) = CAST(JSON_VALUE(@SearchCriteria,'$.SortDirection') AS VARCHAR(100))    
  SET @FROM = @FROM + ' ORDER BY '+@SortProperty+'  '+ @SortDirection +' '    
 END    
 ELSE    
 BEGIN    
  SET @FROM = @FROM + ' ORDER BY P.Id DESC '    
 END    
    
 -- Applying Pagination    
 IF JSON_VALUE(@SearchCriteria,'$.PageSize') IS NOT NULL AND JSON_VALUE(@SearchCriteria,'$.Page') IS NOT NULL    
 BEGIN    
  DECLARE @Page INT = CAST(JSON_VALUE(@SearchCriteria,'$.Page') AS INT)    
  DECLARE @PageSize INT = CAST(JSON_VALUE(@SearchCriteria,'$.PageSize') AS INT)    
    
  --SET @Page = @Page + 1    
  SET @Offset = (CASE WHEN @Page = 0 THEN 0 ELSE  @Page-1 END)*@PageSize    
  SET @FROM = @FROM + ' OFFSET '+CAST(@offset AS VARCHAR(10))+' ROWS FETCH NEXT '+CAST(@PageSize AS VARCHAR(10))+' ROWS ONLY '    
 END      
    
 -- Updating the RemainingUsagePerMember    
 IF @UserId > 0    
 BEGIN    
  SET @SQL = @SQL + ' UPDATE P SET P.RemainingUsagePerMember = CASE WHEN ISNULL(P.MaxUsagePerMember,0) = 0     
  THEN -1 ELSE P.MaxUsagePerMember - ISNULL(UP.TrxCount,0) END FROM #Promotions P LEFT JOIN @UserPromotions UP     
  ON UP.PromotionId = P.Id '    
 END    
 ELSE    
 BEGIN    
  SET @SQL = @SQL + ' UPDATE #Promotions SET RemainingUsagePerMember =     
  CASE WHEN ISNULL(MaxUsagePerMember,0) = 0 THEN -1 ELSE MaxUsagePerMember END '    
 END    
     
 SET @SQL = @DropIfExists +' '+  @SQL + ' SET @GetTotalCount = '+CAST((SELECT TOP 1 ISNULL(TotalCount,0) FROM @TCount) AS VARCHAR(100))+'    
    
 SET @GetResult =(SELECT *, ISNULL((SELECT PItem.*,PItemType.Name as PromotionItemType, PC.Name AS PromotionCategory, PItemGrp.Name as PromotionItemGroup     
 FROM PromotionItem PItem INNER JOIN PromotionItemType PItemType ON PItem.PromotionItemTypeId = PItemType.Id    
 INNER JOIN PromotionItemGroup PItemGrp ON PItem.PromotionItemGroupId = PItemGrp.Id    
 INNER JOIN PromotionCategory PC oN PC.Id = P.PromotionCategoryId
 WHERE PItem.PromotionId = P.Id ORDER BY PItem.Id FOR JSON PATH),N''[]'') AS PromotionItem    
 FROM #Promotions P     
 WHERE CAST(P.StartDate AS DATE) <= ''' + CONVERT(char(10), GetDate(),126) + ''' AND CAST(P.EndDate AS DATE) >= ''' + CONVERT(char(10), GetDate(),126) + '''      
 ORDER BY P.Id ASC OFFSET ' + CAST(@PageSize * (@Page - 1) as varchar(max)) + '     
 rows fetch next '+ CAST(@PageSize as varchar(max)) +' rows only FOR JSON PATH) '    
    
    
 PRINT @SQL    
 EXECUTE sp_executesql @SQL, N'@GetResult NVARCHAR(MAX) OUTPUT, @GetTotalCount INT OUTPUT', @GetResult = @Result OUTPUT, @GetTotalCount = @TotalCount OUTPUT     
END