CREATE   PROCEDURE [dbo].[ApplyPoints]   
(  
  
 @ClientName NVARCHAR(100),   
 @UserId INT,  
 @ItemCode NVARCHAR(30),  
 @PromoProfileItems NVARCHAR(300), --comma separated value  
 @Success BIT OUTPUT  
)  
AS  
BEGIN  
 SET TRANSACTION ISOLATION LEVEL READ UNcommitTED    
 SET NOCOUNT ON;  
    --modified by bibin on 12/05/2020  
 --1.PromotionCategoryId introduced in where clause and removed join with PromotionCategory in select to get promotionvalue  
 --2.OfferType 'Points' filter applied in select to get PromotionValue.This Sp deals only with Points Promotion currently.  
 --3. @RegisterationPointValue replaced with @PromotionPointValue to make it more generic variable  
 --4.Startdate filter introduced in select to get promotion value  
 --5.@ITemCode = 'Transaction' if and else if statement implemented for First purchase ,second purchase & purchase within period  
 --6.LoyaltyProfile Restriction implemented . check @validProfile variable  
 --7.Promotion Segment Restriction implemented. check @validSegment variable  
 --8.New TrxType 'Transactions' introduced for FirstPurchase,SecondPurchase&PurcahsewithinPeriod  
 --9.Accepted Site Restriction applied on promotion value selection  
 --10. Return Message set based on Valid variables(@Valid,@validProfile,@validSegment)  
 DECLARE @PosId NVARCHAR(20) = NULL,   
   @OpId NVARCHAR(50) = NULL,   
   @PosTxnId NVARCHAR(20) = LOWER(NEWID()),  
   @ClientId INT = (SELECT ClientId FROM Client WHERE [Name]=@ClientName),  
   @Description NVARCHAR(200),   
   @PromotionName NVARCHAR(200),	  
   @PromotionPointValue DECIMAL(8, 2),  
   @PromotionCategoryId int,  
   @Message NVARCHAR(200),  
   @TrxDetailId INT,  
   @CurrentPoint DECIMAL(8, 2),    
   @ProfileField NVARCHAR(1000),  
   @Valid INT = 0,  
   @ValidField NVARCHAR(500),  
   @UserSiteId int, 
   @CurrentPointBalance FLOAT,
 --------TrxHeader----------------------------  
   @SiteId INT,  
   @PosDescription NVARCHAR(100) = null,  
   @DeviceId NVARCHAR(25),  
   @TrxdateTime DATETIME = GETDATE(),  
   @NewTrxId INT,  
   @AccountId INT,  
 --------TrxDetail----------------------------   
   @LineNumber SMALLINT,  
   @Anal1 NVARCHAR(50)= NULL,  
   @Anal2 NVARCHAR(50) = NULL,  
   @Anal3 NVARCHAR(50) = NULL,  
   @Anal4 NVARCHAR(50) = NULL,  
   @Quantity FLOAT,  
   @LineValue MONEY,  
   @EposDiscount MONEY,  
   @PromotionId INT = 0,  
   @PromotionValue MONEY = 0.00,  
   @OfferTypeId int,  
   @RewardOfferTypeId int,  
   @LoyaltyDiscount MONEY,  
 --------------------------------------------  
   @AddressStatusIdCurrent INT,   
   @UserStatusIdActive INT,   
   @UserStatusIdPotential INT,   
   @addressvalidstatusid INT,  
   @AddressTypeIdMain INT,  
   @DeviceExist INT,  
   @TrxTypeId INT,  
   @TrxStatusId INT,  
   @DevicestatusId INT,  
   @RewardId INT,  
   @Reward   NVARCHAR(MAX),  
   @PromotionTypeItemValue INT,  
  @OfferTypeName nvarchar(30),
  @PromotionConfig nvarchar(1000), 
 ----------------Audit------------------------  
   @Version INT = 1,  
   @ReferenceType NVARCHAR(150) = 'Account',  
   @ChangeBy INT = 1400006,  
   @ProfileTemplateType INT  
  
 --------------------------------------------  

 CREATE TABLE #PromoProfileItem (token nvarchar(50));

 DECLARE @punchPromotionId NVARCHAR(10)='',@punchTrxId Int,@isPunch smallint=0,@registerationpunchqty int;

 --devicestatusid=2=active  
 select @ChangeBy= UserId from [User] where Username='superuser'  
 SET @devicestatusId=(SELECT devicestatusid FROM devicestatus WHERE [name]='Active' AND clientid=@ClientId)  
 select @ProfileTemplateType= Id from DeviceProfileTemplateType where Name='Loyalty' and ClientId=@ClientId  
 select @PromotionCategoryId = Id from PromotionCategory where Name=@ItemCode and ClientId=@ClientId  
  
 SELECT TOP 1 @DeviceId = d.DeviceId,@AccountId=d.AccountId, @CurrentPointBalance = a.PointsBalance FROM Device d   
   inner join Account a on a.AccountId=d.AccountId and a.UserId=@UserId   
   inner join DeviceProfile dp on d.Id=dp.DeviceId   
   inner join DeviceProfileTemplate dpt on dpt.Id=dp.DeviceProfileId   
   and dpt.DeviceProfileTemplateTypeId =@ProfileTemplateType  
   WHERE d.UserId = @UserId AND d.DeviceStatusId=@devicestatusId    
  ORDER BY StartDate DESC   
  

 SELECT @UserSiteId = SiteId from [User] where UserId=@UserId  
    
  --store all the profile item in a table  
  insert into #PromoProfileItem SELECT token FROM [SplitString](@PromoProfileItems,',')    
 
  --storing in temp table to avoid multiple calls  
  SELECT p.Id, p.PromotionOfferValue, p.SiteId, pmpi.ItemName, p.Reward,pmpi.ItemValue,p.Name,ISNULL(p.MaxUsagePerMember,0) MaxUsagePerMember,ISNULL(PromotionUsageLimit,0) PromotionUsageLimit,pot.Name as OfferType,p.Config INTO #Promotion  
  FROM   Promotion AS p INNER JOIN  
     PromotionSites AS ps ON ps.PromotionId = p.Id INNER JOIN  
     PromotionLoyaltyProfiles AS plp ON plp.PromotionId = p.Id INNER JOIN  
	 PromotionOfferType pot on pot.Id=p.PromotionOfferTypeId INNER JOIN
     DeviceProfile AS dp ON plp.LoyaltyProfileId = dp.DeviceProfileId INNER JOIN  
     Device AS d ON d.Id = dp.DeviceId LEFT OUTER JOIN  
     PromotionMemberProfileItem AS pmpi ON pmpi.PromotionId = p.Id AND pmpi.ItemName COLLATE DATABASE_DEFAULT IN (SELECT * FROM #PromoProfileItem)  
  WHERE  p.[Enabled] = 1  AND  p.StartDate <= GETDATE() AND p.EndDate >= GETDATE()   
 -- Category is MemberProfileData and OfferType is Points  
  AND p.PromotionCategoryId = @PromotionCategoryId AND p.PromotionOfferTypeId in ( SELECT  Id from PromotionOfferType where ClientId = @clientId and pot.[Name] in('Points','Reward','Punches','Voucher') ) 
 -- select eligible promo for user.If users site is a child of any of Promotions Accepted sites  
  AND ps.SiteId in( SELECT SiteId from GetParentSitesBySiteId(@UserSiteId))  
  AND d.UserId=@UserId and d.DeviceId=@DeviceId   
  
  SELECT @LineNumber = 1,  
     @Quantity = 1,  
     @LineValue = 0,  
     @EposDiscount = 0,  
     @LoyaltyDiscount = 0;  
     
IF @ItemCode in( 'Registration')
	BEGIN
	
		-- personlaise stampcard of unregistered purchases done by user
		exec [dbo].[PersonalizeStampCard] @UserId,@ClientId,0
		--Spencer have a requirement to run puches and voucher promos for registeration ,so we have to loop through registeration offer type 
		SET @PromoProfileItems = (SELECT STRING_AGG(OfferType, ',') AS Result from #Promotion)
		truncate table  #PromoProfileItem
		insert into #PromoProfileItem SELECT token FROM [SplitString](@PromoProfileItems,',') 
	END
 --SELECT @UserStatusIdActive = UserStatusId  FROM [UserStatus] WHERE ClientId = @clientId and [Name] = 'Active'                
 SET @TrxTypeId=(SELECT TrxTypeId FROM trxtype WHERE [name]='Activity' AND clientid = @ClientId)  
   
 DECLARE @profileItem varchar(50);  
 --if comma seperated profileitem passed from API for MemberProfileData then we loop through each and apply points  
 DECLARE db_cursor CURSOR FOR    
 SELECT token FROM #PromoProfileItem    
 -----------------------------------------------------  
 OPEN db_cursor    
 FETCH NEXT FROM db_cursor INTO @profileItem  
  
 WHILE @@FETCH_STATUS = 0    
 BEGIN  
 IF @ItemCode = 'MemberProfileData' -- when profile completes  
 BEGIN    
  SELECT TOP 1 @promotionId = Id,@PromotionName = Name, @PromotionPointValue = PromotionOfferValue, @SiteId = SiteId, @ProfileField = ItemName ,@Reward=Reward  
  FROM #Promotion WHERE ItemName=@profileItem  
  ORDER BY PromotionOfferValue DESC  
  
  IF ISNULL(@promotionId,0) > 0   
	BEGIN
		SET @Description=@PromotionName --@profileItem	-- (VOY-474- Changing Description as PromotionName)		
		SET @Valid = 1;
	END	  
 END  
 ELSE IF @ItemCode in( 'Registration','NewDevice') --when a new user registers or add new loyalty device  
 BEGIN  
    -- select promotion based on offertype - Voucher,Points,Punches
  SELECT TOP 1 @promotionId = Id,@PromotionName = Name, @PromotionPointValue = ISNULL(PromotionOfferValue,0), @SiteId = SiteId,@Reward=Reward,@OfferTypeName = OfferType,@PromotionConfig = Config FROM #Promotion  
  Where OfferType = @profileItem
  ORDER BY PromotionOfferValue DESC  
  SET @Description=@PromotionName 
    --If offer type is punches set the qty  = PromotionOfferValue eg- 2 punches for registeration
	set @Quantity = 1 ;
	if @OfferTypeName = 'Punches'
	begin
	set @Quantity = @PromotionPointValue ;
	-- @Quantity variable above get overwrittten by registertion voucher promotion,so set it in another varibale which will be passed to [StampCardManualClaim] SP
	set @registerationpunchqty = @PromotionPointValue;
	set @PromotionPointValue = 0;
	end
	
  SET @Valid = CASE WHEN @promotionId > 0 THEN 1 ELSE 2 END  
 END  
 ELSE IF @ItemCode in ('MembershipAnniversary')  
 BEGIN   
  SET @Description=@profileItem;--FirstAnniversary,SecondAnniversary  
    
  SELECT TOP 1 @promotionId = Id,@PromotionName = Name, @PromotionPointValue = PromotionOfferValue, @SiteId = SiteId, @ProfileField = ItemName ,@Reward=Reward  
  FROM #Promotion WHERE ItemName=@profileItem  
  ORDER BY PromotionOfferValue DESC  
   
  IF @profileItem in ('MemberBirthday','PetBirthday')  
  BEGIN  
  --setting like this as if exist check for trxdetail should fail in birthday case,as its should be allowed to apply bithday points yearly  
  SET @Description = @profileItem+'-'+Convert(varchar, Getdate(),103)  
  SET @ItemCode = 'Birthday';  
  END  
   
  SET @Valid = CASE WHEN ISNULL(@promotionId,0) > 0 THEN 1 ELSE 0 END  
    
 END  
 ELSE IF @ItemCode in ('Login')  
 BEGIN  
   
  SET @Description=@profileItem+'-'+Convert(varchar, Getdate(),103);--FirstEver,FirstTimeEveryMonth,FirstTimeEveryNMonths  
  SET @promotionId = 0  
  SET @PromotionPointValue = 0  
  IF @profileItem in ('FirstTimeEveryMonth','FirstTimeEveryNMonths')  
  BEGIN  
   Declare @LastPromoHitDate datetime,@MemberFirstLoginDate datetime,@DiffInMonths int  
   --Select @MemberFirstLoginDate=FirstLoginDate From [User] Where UserId = @UserId  
     
   -- Difference between last promo hit date and currentdate in months calculated(eg: if last promo hit date is Jan25th(or any date in Jan) and current date is Feb1(or any date in Feb), then @DiffInMonths will be 1)  
   SELECT TOP 1 @LastPromoHitDate = th.TrxDate  
   FROM TrxHeader th INNER JOIN TrxDetail td ON th.TrxId = td.TrxId  
   WHERE th.DeviceId = @DeviceId AND ItemCode = @ItemCode AND td.description like @profileItem+'%'   
   ORDER BY th.TrxDate DESC  
  
   SELECT @DiffInMonths = DATEDIFF(month, DATEFROMPARTS(YEAR(ISNULL(@LastPromoHitDate,getdate())),MONTH(ISNULL(@LastPromoHitDate,getdate())),1), getdate())  
     
   IF @profileItem = 'FirstTimeEveryMonth'  
   BEGIN  
  
    IF @LastPromoHitDate is null -- should hit promotion for first time when first login while promotion is active  
    BEGIN  
     SET @DiffInMonths = 1  
    END  
  
    IF @DiffInMonths >= 1  
    BEGIN  
     SELECT TOP 1 @promotionId = Id,@PromotionName = Name, @PromotionPointValue = PromotionOfferValue, @SiteId = SiteId, @ProfileField = ItemName ,@Reward=Reward,@PromotionTypeItemValue=ItemValue  
     FROM #Promotion WHERE ItemName=@profileItem   
     ORDER BY PromotionOfferValue DESC  
    END  
  
   END  
   ELSE -- FirstTimeEvery N Months  
   BEGIN  
  
    IF @LastPromoHitDate is null -- should hit promotion for first time when first login while promotion is active  
    BEGIN  
     SELECT TOP 1 @promotionId = Id,@PromotionName = Name, @PromotionPointValue = PromotionOfferValue, @SiteId = SiteId, @ProfileField = ItemName ,@Reward=Reward,@PromotionTypeItemValue=ItemValue  
     FROM #Promotion WHERE ItemName=@profileItem   
     ORDER BY PromotionOfferValue DESC  
    END  
    ELSE  
    BEGIN  
     SELECT TOP 1 @promotionId = Id,@PromotionName = Name, @PromotionPointValue = PromotionOfferValue, @SiteId = SiteId, @ProfileField = ItemName ,@Reward=Reward,@PromotionTypeItemValue=ItemValue  
     FROM #Promotion WHERE ItemName=@profileItem   
     AND ItemValue <= @DiffInMonths -- Here promotion selected based on the ItemValue(which is the 'N' value of 'FirstTimeEveryNMonths' type promotion)  
     ORDER BY PromotionOfferValue DESC  
    END  
      
   END  
  END  
  ELSE --FirstEver(will only passed here if FirstLoginDate field is null)  
  BEGIN  
   SELECT TOP 1 @promotionId = Id,@PromotionName = Name, @PromotionPointValue = PromotionOfferValue, @SiteId = SiteId, @ProfileField = ItemName ,@Reward=Reward  
   FROM #Promotion WHERE ItemName=@profileItem  
   ORDER BY PromotionOfferValue DESC  
  END    
  
  SET @Valid = CASE WHEN ISNULL(@promotionId,0) > 0 THEN 1 ELSE 0 END  
  
 END  
  
 
 ---------------------------------------------  
   DECLARE @validSegment smallint = 1;--@validProfile smallint = 0 ,  
    
    
     
   --Check Segment Restriction  
 If EXISTS( select 1 from PromotionSegments where PromotionId=@PromotionId)  
 BEGIN  
  -- Check if the user exist in the  promotion segment   
  IF EXISTS( Select 1 from SegmentUsers su inner join PromotionSegments ps   
  on ps.SegmentId= su.SegmentId where su.UserId=@UserId and ps.PromotionId=@PromotionId )  
  BEGIN  
  -- if promotion segment restrictions exist and user part of that  segment then promotion should be applied  
  SET @validSegment = 1  
  END  
  ELSE  
  BEGIN  
  -- if promotion segment restrictions exist and user not part of  segment then promotion should not be applied  
  SET @validSegment = 0  
  END  
 END  
 BEGIN TRY  
    BEGIN TRANSACTION  

/*------------------------------------------------------
		Checking whether the user had used the activity and
		points are applied already.If yes, return error.
------------------------------------------------------*/
  IF ISNULL(@PromotionId,0) > 0  
  BEGIN
	DECLARE @maxusagelimit INT,@TrxMaxusagelimit INT,@PromotionUsageLimit INT, @TrxPromotionUsageLimit INT;


	select @maxusagelimit = IsNULL(MaxUsagePerMember,0),@PromotionUsageLimit = PromotionUsageLimit from #Promotion where Id = @PromotionId

	IF IsNULL(@PromotionUsageLimit,0) > 0 
	BEGIN
		SET @TrxPromotionUsageLimit = [dbo].[PromotionUsage](0,@PromotionId,null)

		IF @PromotionUsageLimit <= ISNULL(@TrxPromotionUsageLimit,0)
		BEGIN
			SET @PromotionId = 0;
		END
	END

	IF IsNULL(@maxusagelimit,0) > 0  AND ISNULL(@UserId,0) > 0 AND ISNULL(@PromotionId,0) > 0  
	BEGIN
		SET @TrxMaxusagelimit = [dbo].[PromotionUsage](@UserId,@PromotionId,null)

		IF @maxusagelimit <= ISNULL(@TrxMaxusagelimit,0)
		BEGIN
			SET @PromotionId = 0;
		END
	END
  END
  --Need to create trx only if user have a active loyalty device and if a valid promotion is hit  
  IF @DeviceId IS NOT NULL and @Valid = 1   and @validSegment = 1 and ISNULL(@PromotionId,0) > 0  
  BEGIN             
  -- First check if offer type is a Reward  
   IF ISNULL(@Reward,'') <> '' AND   
    ISNULL(ISJSON(@Reward),'')<> '' AND   
    ISJSON(@Reward)= 1  
     
   BEGIN  
   DECLARE @rewId NVARCHAR(10)=JSON_VALUE(@Reward,'$.RewardId')  
   DECLARE @ProductId NVARCHAR(10)=JSON_VALUE(@Reward,'$.Id')  
   DECLARE @RewardIdAndProductId NVARCHAR(100)=''  
  
   IF ISNULL(@rewId,'')<>'' AND ISNULL(@ProductId,'')<>''  
   BEGIN  
    SET @RewardIdAndProductId = @rewId + '/' + @ProductId  
   END  
  
   SELECT @RewardId = JSON_VALUE(@Reward,'$.Id')  
    
   Declare @trxTypeReward int,@trxstatusStarted int;  
   select @trxTypeReward= TrxTypeId from TrxType where Name='Reward' and ClientId=@ClientId  
   SET @trxstatusStarted=(SELECT TrxStatusId FROM TrxStatus WHERE [name]='Started' AND clientid = @ClientId)  
   INSERT INTO TrxHeader  
       (ClientId,DeviceId,TrxTypeId,TrxDate,SiteId,TerminalId,TerminalDescription,Reference,OpId,TrxStatusTypeId,TrxCommitDate, AccountPointsBalance)  
    VALUES      (@ClientId,@DeviceId,@trxTypeReward,@TrxdateTime,@UserSiteId,@PosId,@PosDescription, @PosTxnId,@OpId,@trxstatusStarted,GETDATE(), @CurrentPointBalance);  
  
    SELECT @NewTrxId = Scope_identity();    
      
   END  
  -- Check if points already applied to user for registeration,add new device,member profile  
   ELSE   
   BEGIN  
   print 'not a reward'  
    SET @TrxStatusId=(SELECT TrxStatusId FROM TrxStatus WHERE [name]='Completed' AND clientid = @ClientId)  
    IF NOT EXISTS(SELECT 1  
     FROM   TrxHeader th inner join TrxDetail td on th.TrxId=td.TrxID  
     where th.TrxTypeId=@TrxTypeId and th.TrxStatusTypeId=@TrxStatusId and th.DeviceId=@DeviceId  
     and td.ItemCode=@ItemCode AND td.PromotionId = @promotionId)  
     BEGIN  
      
      INSERT INTO TrxHeader  
         (ClientId,DeviceId,TrxTypeId,TrxDate,SiteId,TerminalId,TerminalDescription,Reference,OpId,TrxStatusTypeId,TrxCommitDate, AccountPointsBalance)  
      VALUES      (@ClientId,@DeviceId,@TrxTypeId,@TrxdateTime,@UserSiteId,@PosId,@PosDescription, @PosTxnId,@OpId,@TrxStatusId,GETDATE(), @CurrentPointBalance);  
  
      SELECT @NewTrxId = Scope_identity();   
           
     END  
    ELSE  
     BEGIN  
      SELECT @NewTrxId = 0;  
      SET @Message = 'Transaction already exist for '+@ItemCode + ' '+ @PromoProfileItems  
     END  
   END  
  END  
  ELSE  
  BEGIN  
   SELECT @NewTrxId = 0;  
     
   IF @Valid = 0 or @Valid = 2 or ISNULL(@PromotionId,0)= 0 -- 2 set in Registertion,AddNewDEvice, Transaction for First,Second,WithinPeriod  
   BEGIN  
   SET @Message= 'No Valid Promotion hit for '+@ItemCode+'-'+@PromoProfileItems+',Valid Status='+CAST(@Valid as varchar(2));  
   END  
   ELSE   
   BEGIN  
    SET @Message= CASE  WHEN @validSegment =0 THEN   
        'USER NOT IN SEGMENT FOR PROMOTION-'+ CAST(@PromotionId as varchar(10))   
         ELSE 'Failed, No Device Found.'  END  
   END  
  END  
      
 ------------------------------------------------  
 IF @NewTrxId != 0  
 BEGIN  
  set @RewardId = ISNULL(@RewardId,NULL);  
    -- (VOY-474 - Insert @ProfileItem in Anal1 field instead of @Anal1)
  INSERT INTO TrxDetail  
     ([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Anal1,Anal2,Anal3,Anal4,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,LoyaltyDiscount,PromotionItemId,AuthorisationNr)--,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10,Anal11,Anal12,Anal13,Anal14,Anal15)  
  VALUES ('1', @NewTrxId,@LineNumber,@ItemCode,@Description,@profileItem,@Anal2,@Anal3,@Anal4,@Quantity,@LineValue,@EposDiscount,@PromotionPointValue, @PromotionId, @PromotionValue,@LoyaltyDiscount,NULL,@RewardIdAndProductId);--, @Anal5, @Anal6, @Anal7, @Anal8,@Anal9, @Anal10, @Anal11, @Anal12, @Anal13, @Anal14,@Anal15 );  
    
  SELECT @TrxDetailId = TrxDetailID FROM TrxDetail WHERE TrxID = @NewTrxId and PromotionID = @PromotionId;   
    
  INSERT INTO TrxDetailPromotion ([Version], PromotionId, TrxDetailId , ValueUsed) VALUES (1, @promotionId, @TrxDetailId, @PromotionPointValue);  
		
	IF ISNULL(@Userid,0) > 0 AND NOT EXISTS (SELECT 1 from [PromotionRedemptionCount] with(nolock) where promotionid=@PromotionId and trxid=@NewTrxId)
	BEGIN
		INSERT INTO [dbo].[PromotionRedemptionCount]
		([MemberId]
		,[PromotionId]
		,[LastRedemptionDate]           
		,[TrxId],[ItemCode])
		VALUES (@Userid,@PromotionId,GETDATE(),@NewTrxId,ISNULL(@ItemCode,'SKU-NA') )

		--exec [EPOS_ApplyTask] @Userid,0,@ClientId,@PromotionId
	END
	IF @OfferTypeName = 'Punches'
	begin
	--exec [dbo].[PersonalizeStampCard] 0,@ClientId,@NewTrxId
	SET @punchPromotionId=JSON_VALUE(@PromotionConfig,'$.PromotionId');
	SET @punchTrxId = @NewTrxId;
	SET @isPunch = 1;
	--exec [StampCardManualClaim] @NewTrxId,@punchPromotionId,@Quantity,@Quantity,@ClientId,@ChangeBy
	end
	IF @OfferTypeName = 'Voucher'
	begin
	--Assign a voucher device to user
	Declare @voucheProfileId int,@devicereference nvarchar(100);
	Select @voucheProfileId = VoucherProfileId from Promotion where ID=@PromotionId;
	SET @devicereference = @ItemCode+'-TrxId-'+cast(@NewTrxId as nvarchar(10));
	EXEC AssignDeviceToUser @UserId,'Voucher',@SiteId,@ClientId,@voucheProfileId,@devicereference,0
	
	end

  -- for reward no need to update account point balance  
  IF ISNULL(@Reward,'') = '' OR   
   ISNULL(ISJSON(@Reward),'')= '' OR   
   ISJSON(@Reward)= 0  
  BEGIN  
   SELECT @CurrentPoint = PointsBalance FROM Account WHERE AccountId= @AccountId AND  UserId = @UserId --and ExtRef = @DeviceId       

   UPDATE Account SET PointsBalance = (@CurrentPoint + @PromotionPointValue) WHERE  AccountId= @AccountId AND UserId = @UserId --and ExtRef = @DeviceId   
	
  END  

  EXEC TriggerActionsBasedOnTransactionHit @ClientId, @UserId, @NewTrxId

  SET @Success = 1   
  set @Message = 'Success, Point Applied for '+@ItemCode + '-'+@PromoProfileItems+',PromotionId-'+ CAST(@PromotionId as varchar(10))  
  INSERT INTO AUDIT ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType,OperatorId,SiteId)  
  VALUES (@Version,@UserId,@ItemCode, @CurrentPoint + @PromotionPointValue, @CurrentPoint, GETDATE(), @ChangeBy,@Message,@ReferenceType,null,@SiteId)  
 END  
 ELSE              
 BEGIN   
 IF @DeviceId IS NULL  
 BEGIN  
 SET @Success = 0  
  set @Message='Failed, No Device Found.'  
 END   
 ELSE  
 BEGIN   
 -- All other cases if no promo hit we will still return success so that api won't return false   
  SET @Success = 1  
 END  
 --  
  IF @PromoProfileItems <> 'TransactionWithinPeriod'  
  BEGIN  
  INSERT INTO [Audit] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType,OperatorId,SiteId)  
  VALUES (@Version,@UserId,@ItemCode,'Success='+ CAST(@Success as varchar(5)), @CurrentPoint, GETDATE(), @ChangeBy,@Message,@ReferenceType,null,@SiteId)  
  END  
 END  
   
 COMMIT  
 END TRY  
 BEGIN CATCH  
  IF @@TRANCOUNT > 0  
   ROLLBACK TRANSACTION  
  SET @Success = 0  
  SET @Message = 'Failed, Can not create a transaction.'  
  INSERT INTO [Audit] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType,OperatorId,SiteId)  
   Values (@Version,@UserId,@ItemCode, @Message, @CurrentPoint, GETDATE(), @ChangeBy,@Message+cast(@Valid as varchar(2)),@ReferenceType,null,@UserSiteId)  
 END CATCH  
  
 FETCH NEXT FROM db_cursor INTO @profileItem  

 SET @Description=''  
 SET @Valid=0  
  SET @PromotionPointValue = 0  
 SET @PromotionId = 0  
 END  

 IF @isPunch = 1 and @ItemCode in( 'Registration')
 BEGIN
 exec [StampCardManualClaim] @punchTrxId,@punchPromotionId,@registerationpunchqty,@registerationpunchqty,@ClientId,@ChangeBy,@UserId
 INSERT INTO [Audit] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType,OperatorId,SiteId)  
   Values (1,1400015,@ItemCode, cast(@punchTrxId as varchar(9)), cast(@UserId as varchar(9)), GETDATE(), @ChangeBy,'[StampCardManualClaim] call','StampCardManualClaim',null,ISNULL (@UserSiteId,2)) 
 END
  --drop table  #PromoProfileItem
	
END
