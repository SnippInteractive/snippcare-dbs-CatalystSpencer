
-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2022-10-24
-- Description:	Include / Exclude
-- Modified Date: 2022-10-24
-- =============================================
CREATE PROCEDURE [dbo].[GetPunchCardProgress](@MemberId INT,@AfterValue NVARCHAR(10) OUTPUT, @QualifyingProductQuantity NVARCHAR(10) OUTPUT, @PromotionId NVARCHAR(10) OUTPUT)
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements
SET NOCOUNT ON;
BEGIN TRY  
DECLARE @Method NVARCHAR(50) = 'Catalyst'  ,@DeviceId NVARCHAR(25) = '', @Message NVARCHAR(50) = '', @ClientId INT = 1;

DECLARE @Messages TABLE (ActualMessage NVARCHAR(MAX),PromotionName NVARCHAR(500),AfterValue DECIMAL(18,2),QualifyingProductQuantity float,PunchCardProgress NVARCHAR(10),IsDisplayInMessages bit,IsDisplayInPunchCards bit,PromotionId INT,VoucherProfileId INT,PunchCategory NVARCHAR(100));

Declare @TrxTypeId int = 17,@TrxStatusCompletedId INT = 2,@DeviceStatusIdActive INT = 2;

--SELECT @TrxTypeId = TrxTypeId FROM TrxType with(nolock) where ClientId =@ClientId AND Name = 'PosTransaction'
--SELECT @TrxStatusCompletedId = TrxStatusId From TrxStatus with(nolock) WHERE ClientId = @ClientId AND Name = 'Completed'
--SELECT @DeviceStatusIdActive = DeviceStatusId From DeviceStatus with(nolock) WHERE ClientId = @ClientId AND Name = 'Active'

IF ISNULL(@MemberId,0) = 0
BEGIN

	--INSERT INTO @Messages VALUES('IMPORTANT: The user has not registered yet. Please advise the customer to download the APP and register.','',0,0,0,1,0,0,0,'')
	DECLARE @DeviceIdentifier INT--,@ClientId INT = 1
	IF ISNULL(@DeviceId,'') != ''
	BEGIN		
		SELECT  @DeviceIdentifier = D.Id--,@ClientId = DS.ClientId 
		From Device D with(nolock) 
		--INNER JOIN DeviceStatus DS With(NOLOCK) ON D.DeviceStatusId = DS.DeviceStatusId 
		Where D.DeviceId = @DeviceId and D.DeviceStatusId=@DeviceStatusIdActive
	END

	IF ISNULL(@Method,'') = 'BeginTransaction' AND ISNULL(@DeviceIdentifier,0) >0
	BEGIN
		
		IF NOT EXISTS (SELECT 1 FROM TrxHeader with(nolock) Where DeviceId  = @DeviceId AND TrxStatusTypeId = @TrxStatusCompletedId AND TrxTypeId=@TrxTypeId)
		BEGIN
			SET @Message = 'NewUnregistered'
		END
		ELSE
		BEGIN
			SET @Message = 'Unregistered'
		END
	END


--replace “ (left) with "
--replace ” (right) with "
--replace ´ with ´

	IF ISNULL(@Message,'Unregistered') = 'Unregistered'
	BEGIN
		INSERT INTO @Messages VALUES('Remind GUEST "Don''t forget to download the Spencer''s Nation App so you don''t lose out on Free T-shirts and Jewelry".','',0,0,0,1,0,0,0,'')
	END
	ELSE IF ISNULL(@Message,'') = 'NewUnregistered'
	BEGIN
		INSERT INTO @Messages VALUES('Tell GUEST "You''ll get a TXT with a link to download the Spencer''s Nation App within a few minutes".','',0,0,0,1,0,0,0,'')
	END

	IF ISNULL(@DeviceIdentifier,0) >0
	BEGIN
		--DECLARE @DeviceIdentifier INT 
		--SELECT @DeviceIdentifier = Id From Device Where DeviceId = @DeviceId

		INSERT INTO @Messages
		SELECT P.Name +': '+ CONVERT(NVARCHAR(10),CONVERT(INT,ISNULL(AfterValue,0)) ) +' stamps earned , '+ CONVERT(NVARCHAR(10),QualifyingProductQuantity-AfterValue) +' stamps to go for reward' AS ActualMessage,
		P.Name AS PromotionName,ISNULL(AfterValue,0) AfterValue, ISNULL(QualifyingProductQuantity,0) QualifyingProductQuantity,CASE WHEN ISNULL(AfterValue,0) > 0 AND ISNULL(QualifyingProductQuantity,0) > 0 THEN CONVERT(NVARCHAR(10),CONVERT(INT,((ISNULL(AfterValue,0) / ISNULL(QualifyingProductQuantity,0)) *100))) + '%' ELSE '0 %' END AS PunchCardProgress
		,0 AS IsDisplayInMessages ,1 AS IsDisplayInPunchCards,P.Id ,P.VoucherProfileId,pc.Name PunchCategory
		FROM [PromotionStampCounter] ps with(nolock) 
		inner join Promotion P with(nolock) on ps.PromotionId = P.Id 
		inner join PromotionCategory pc with(nolock) on p.PromotionCategoryId = pc.Id
		WHERE DeviceIdentifier = @DeviceIdentifier  AND DeviceIdentifier IS NOT NULL
		--and p.PromotionCategoryId=(Select  Id from PromotionCategory where ClientId=@ClientId AND Name='StampCardQuantity') 
		AND pc.Name IN ('StampCardQuantity','StampCardValue')AND pc.ClientId = @ClientId
	END
END
ELSE
BEGIN
	DECLARE @FirstName NVARCHAR(100)

	SELECT TOP 1 @FirstName = Firstname,@ClientId = us.ClientId FROM [dbo].[User] u  
	INNER JOIN [dbo].[PersonalDetails] pd ON u.PersonalDetailsId = pd.PersonalDetailsId  
	INNER JOIN [UserStatus] us on u.UserStatusId = us.UserStatusId
	WHERE u.UserId = @MemberId

	IF ISNULL(@FirstName,'') <> ''
	BEGIN
		INSERT INTO @Messages VALUES('Welcome ' + @FirstName,'',0,0,0,1,0,0,0,'')
	END
	--2081 2083
	IF ISNULL(@Method,'') = 'Catalyst'
	BEGIN
		INSERT INTO @Messages
		SELECT P.Name +': '+ CONVERT(NVARCHAR(10),CONVERT(INT,ISNULL(AfterValue,0)) ) +' stamps earned , '+ CONVERT(NVARCHAR(10),QualifyingProductQuantity-AfterValue) +' stamps to go for reward' AS ActualMessage,
		P.Name AS PromotionName,ISNULL(AfterValue,0) AfterValue, ISNULL(QualifyingProductQuantity,0) QualifyingProductQuantity,CASE WHEN ISNULL(AfterValue,0) > 0 AND ISNULL(QualifyingProductQuantity,0) > 0 THEN CONVERT(NVARCHAR(10),CONVERT(INT,((ISNULL(AfterValue,0) / ISNULL(QualifyingProductQuantity,0)) *100))) + '%' ELSE '0 %' END AS PunchCardProgress
		,0 AS IsDisplayInMessages ,1 AS IsDisplayInPunchCards,P.Id ,P.VoucherProfileId,pc.Name PunchCategory
		FROM [PromotionStampCounter] ps with(nolock) 
		inner join Promotion P with(nolock) on ps.PromotionId = P.Id and p.EndDate >= Getdate() -- and p.Enabled=1 
		inner join PromotionCategory pc with(nolock) on p.PromotionCategoryId = pc.Id
		WHERE UserId = @MemberId  AND UserId IS NOT NULL
		--and  p.PromotionCategoryId IN (Select  Id from PromotionCategory where ClientId=@ClientId AND Name IN ('StampCardQuantity','StampCardValue')) 
		AND pc.Name IN ('StampCardQuantity','StampCardValue')AND pc.ClientId = @ClientId
	END
	ELSE
	BEGIN
		INSERT INTO @Messages
		SELECT P.Name +': '+ CONVERT(NVARCHAR(10),CONVERT(INT,ISNULL(AfterValue,0)) ) +' stamps earned , '+ CONVERT(NVARCHAR(10),QualifyingProductQuantity-AfterValue) +' stamps to go for reward' AS ActualMessage,
		P.Name AS PromotionName,ISNULL(AfterValue,0) AfterValue, ISNULL(QualifyingProductQuantity,0) QualifyingProductQuantity,CASE WHEN ISNULL(AfterValue,0) > 0 AND ISNULL(QualifyingProductQuantity,0) > 0 THEN CONVERT(NVARCHAR(10),CONVERT(INT,((ISNULL(AfterValue,0) / ISNULL(QualifyingProductQuantity,0)) *100))) + '%' ELSE '0 %' END AS PunchCardProgress
		,0 AS IsDisplayInMessages ,1 AS IsDisplayInPunchCards,P.Id ,P.VoucherProfileId,pc.Name PunchCategory
		FROM [PromotionStampCounter] ps with(nolock) 
		inner join Promotion P with(nolock) on ps.PromotionId = P.Id and p.Enabled=1 and p.EndDate >= Getdate()
		inner join PromotionCategory pc with(nolock) on p.PromotionCategoryId = pc.Id
		WHERE UserId = @MemberId  AND UserId IS NOT NULL
		--and  p.PromotionCategoryId=(Select  Id from PromotionCategory where ClientId=@ClientId AND Name='StampCardQuantity') 
		AND pc.Name IN ('StampCardQuantity','StampCardValue')AND pc.ClientId = @ClientId
	END
	--INSERT INTO @Messages
	--SELECT Name +': '+ CONVERT(NVARCHAR(10),CONVERT(INT,ISNULL(AfterValue,0)) ) +' stamps earned , '+ CONVERT(NVARCHAR(10),QualifyingProductQuantity-AfterValue) +' stamps to go for reward' AS ActualMessage,
	--Name AS PromotionName,ISNULL(AfterValue,0) AfterValue, ISNULL(QualifyingProductQuantity,0) QualifyingProductQuantity,CASE WHEN ISNULL(AfterValue,0) > 0 AND ISNULL(QualifyingProductQuantity,0) > 0 THEN CONVERT(NVARCHAR(10),CONVERT(INT,((ISNULL(AfterValue,0) / ISNULL(QualifyingProductQuantity,0)) *100))) + '%' ELSE '0 %' END AS PunchCardProgress
	--,0 AS IsDisplayInMessages ,1 AS IsDisplayInPunchCards,P.Id ,P.VoucherProfileId
	--FROM [PromotionStampCounter] ps with(nolock) inner join Promotion P with(nolock) on ps.PromotionId = P.Id WHERE UserId = @MemberId  AND UserId IS NOT NULL
	
	--SET Default 0 punches if registered user don't have any punch or punch exist only for one promo
	
	--IF ((SELECT COUNT(PromotionId) FROM  @Messages WHERE IsDisplayInPunchCards = 1)  < 2)
	--BEGIN
	
		INSERT INTO @Messages
		SELECT P.Name +': '+ CONVERT(NVARCHAR(10),0 ) +' stamps earned , '+ CONVERT(NVARCHAR(10),p.QualifyingProductQuantity) +' stamps to go for reward' AS ActualMessage,
		P.Name AS PromotionName,0 AfterValue, ISNULL(p.QualifyingProductQuantity,0) QualifyingProductQuantity,'0%' AS PunchCardProgress
		,0 AS IsDisplayInMessages ,1 AS IsDisplayInPunchCards,P.Id ,P.VoucherProfileId,pc.Name PunchCategory
		FROM  Promotion P 
		left join  @Messages m on m.PromotionId = p.Id
		inner join PromotionCategory pc with(nolock) on p.PromotionCategoryId = pc.Id
		WHERE p.Id <> ISNULL(m.PromotionId,0) and JSON_VALUE(p.Config,'$.IsParent') ='true' and p.Enabled=1 and p.EndDate >= Getdate()
		--and p.PromotionCategoryId=(Select  Id from PromotionCategory where ClientId=@ClientId AND Name='StampCardQuantity') 
		AND pc.Name IN ('StampCardQuantity','StampCardValue') AND pc.ClientId = @ClientId
	--END


	SELECT DISTINCT D.Deviceid, m.VoucherProfileId,dpt.Name AS DeviceProfileTemplateName
	INTO #AvilableVouchers
	from Device d with(nolock) 
	inner join DeviceProfile dp with(nolock) on d.id=dp.DeviceId 
	inner join DeviceProfileTemplate dpt with(nolock) on dp.DeviceProfileId = dpt.Id
	inner join DeviceStatus ds with(nolock) on d.DeviceStatusId = ds.DeviceStatusId
	inner JOIN @Messages m  on dpt.Id = m.VoucherProfileId
	where  D.Userid = @MemberId AND ds.Name = 'Active' AND ISNULL(m.VoucherProfileId,0) > 0   

	IF EXISTS( SELECT 1 FROM #AvilableVouchers  WHERE ISNULL(VoucherProfileId,0) > 0 )
	BEGIN
		INSERT INTO @Messages 
		SELECT 'Let the Guest know they have '+ CONVERT(NVARCHAR(5),count(DeviceId)) +' '+ MAX(DeviceProfileTemplateName) + '!!' ,'',0,0,0,1,0,0,0,''
		FROM #AvilableVouchers WHERE ISNULL(VoucherProfileId,0) > 0  GROUP BY VoucherProfileId
	END
	ELSE
	BEGIN
		INSERT INTO @Messages VALUES('Review their loyalty progress and recommend punches needed for free Jewelry or Tee','',0,0,0,1,0,0,0,'')
	END

	--CREATE TABLE #PromotionIds (PromotionId INT)
	--SELECT * FROM SegmentUsers
	--SELECT SegmentId INTO #SegmentUsers FROM SegmentUsers WHERE UserId = @MemberId

	--IF EXISTS (SELECT 1 FROM #SegmentUsers)
	--BEGIN
		
		CREATE TABLE #PromotionIds (PromotionId INT)

		INSERT INTO #PromotionIds
		SELECT P.PromotionId  
		FROM @Messages P 
		INNER JOIN PromotionSegments PS with(nolock) ON P.PromotionId = PS.PromotionId
		INNER JOIN SegmentUsers SU with(nolock) ON PS.SegmentId = SU.SegmentId AND SU.UserId = @MemberId
		WHERE ISNULL(P.PromotionId,0) <> 0

		INSERT INTO #PromotionIds
		SELECT P.PromotionId  
		FROM @Messages P 
		LEFT JOIN PromotionSegments PS with(nolock) ON P.PromotionId = PS.PromotionId
		WHERE PS.PromotionId IS NULL AND ISNULL(P.PromotionId,0) <> 0

		IF EXISTS (SELECT 1 FROM #PromotionIds WHERE PromotionId > 0 )
		BEGIN
			DELETE FROM @Messages Where ISNULL(PromotionId,0) <> 0 AND  ISNULL(PromotionId,0) NOT IN (SELECT PromotionId FROM #PromotionIds)
		END

	--END

END	   


SELECT Top 1 @AfterValue = AfterValue, @QualifyingProductQuantity = QualifyingProductQuantity , @PromotionId = PromotionId FROM @Messages where PunchCategory = 'StampCardValue'

END TRY                                                        
BEGIN CATCH       
	PRINT 'ERROR'      
	PRINT ERROR_NUMBER() 
	PRINT ERROR_SEVERITY()  
	PRINT ERROR_STATE()
	PRINT ERROR_PROCEDURE() 
	PRINT ERROR_LINE()  
	PRINT ERROR_MESSAGE()                                                                                               
END CATCH       
END
