/*         
-- =========================================================================================================        
-- Author:  Abdul Wahab        
-- Create date: 21 May 2020        
-- Description: This procedure is to redeem the voucher        
-- Changed by: Niall         
-- Reason:  to take vouchers from the VoucherCode Table instead of a device        
-- This means that the vouchers will be on ONE table instead of the usual Device, Account and DeviceProfile        
-- the Voucher has no balance, just the points that can be used        
        
-- 1. Check the voucher exists using the CODE (DeviceID) and Clientid        
-- 2. Check the user is a Loyalty User and has an Active Device (If Not Reject - OR do we create a device?)        
-- 3. Date, Status and SIte where the voucher can be used and if not classical, has it been used before?)        
-- 4. Changed the Activity trxtype to PackagingCode type if the ClassicalVoucher = 1
        
Two other types of codes are needed.        
        
1. Email Code        
2. Shelter code (Secrets)        
        
The email code is a classical code.         
The same code goes to Many people, but can only be used ONCE per person.        
The Shelter Secret is a classical code and can only be used once per person BUT does not give points to the member that uses it         
(although it does write a transaction), it give points to the Shelter.         
The Voucher code table has a UserID. We will also have the expiration date.        
*/        
-- =========================================================================================================        
        
--ErrorCodes        
--------        
--901 = AlreadyRedeemed        
--902 = InvalidVoucher,        
--903 = InvalidUser,  --not a loyalty type user        
--904 = InvalidVoucherType,  (Refer in the VoucherSubTypeTable)        
--905 = VoucherExpired        
--906 = VoucherUsedByUserID        
--907 = VoucherNotActive        
--908 = ShelterNotFound        
--909 --ShelterNotActive        
--910 --LimitReachedDaily
--911 --LimitReachedWeekly
--912 --LimitReachedMonthly
--913 --LimitReachedYearly
--914 --LimitReachedDailyPerItem
--915 --LimitReachedWeeklyPerItem
--916 --LimitReachedMonthlyPerItem


--999 = InternalServerError        
        
----#Readme----------------        
--ClassicalVoucher = 1 > means this voucher can be used multiple times by multiple users        
--ClassicalVoucher = 0 > means this voucher can be redeemed by one user        
----------------------------------------        

/*
declare @err as int
exec [RedeemVoucher] 1,3023903,'343474FJ9C','ItemDesc',0,0,@err,'','' ,'',NULL
select @err
  */      
CREATE PROCEDURE [dbo].[RedeemVoucher]        
@ClientId INT,        
@UserId INT,         
@VoucherNumber NVARCHAR(100),         
@ItemDescription NVARCHAR(200),  
@Reference NVARCHAR(50) = NULL,  
@UniqueId NVARCHAR(50)= NULL,  
@ErrorCode INT OUTPUT,        
@NewPointsBalance FLOAT OUTPUT,        
@PointsValue FLOAT OUTPUT,        
@CodeType NVARCHAR(20) OUTPUT,        
@ShelterName NVARCHAR(250) OUTPUT        
        
AS        
BEGIN        
         
 SET NOCOUNT ON;        
 IF ISNULL(@Reference,'')=''  
 BEGIN  
 SET @Reference = NEWID()  
 END  
 DECLARE @UsersDeviceId NVARCHAR(50),@UsersAccountId INT,        
 @TransactionTypeId INT,@TransactionStatusId INT,@VoucherName nvarchar(50),        
 @SiteId INT,@TerminalId NVARCHAR(20) = NULL, @OpId NVARCHAR(50) = NULL, @CountPrevious int,        
 @TransactionId INT, @Points FLOAT, /*actual points calculation*/@PointsBalance FLOAT,@VoucherValue INT, @VoucherUser INT,@Classical int,        
 @VoucherType NVARCHAR(50),@DeviceStatusID_Active int,@VoucherDeviceStatus INT,@AccountStatusID_Active int,@UserToBeUsedOnID int,        
 @VoucherExpirartionDate DATETIME,@VoucherDateUsed DATETIME,
 @ProductItemCode nvarchar(50),@ProductDescription nvarchar(200), @DeviceLotID int
        
 SELECT @DeviceStatusID_Active = DeviceStatusId FROM DeviceStatus WHERE [Name] IN ('Active') and clientid = @ClientId        
 SELECT @AccountStatusID_Active = AccountStatusId FROM AccountStatus WHERE [Name] IN ('Enable') and clientid = @ClientId        
        
 DECLARE @TrxIdTable TABLE (TrxId INT)        
        
 select @VoucherName=DeviceID,@VoucherUser=[UserID],@SiteId=[SiteID],@VoucherDeviceStatus=[DeviceStatusID],        
   @VoucherExpirartionDate=[ExpirationDate],@CodeType=[ExtReference],@VoucherValue=[Value],@VoucherType=[ValueType],        
   @Classical=[Classical],@VoucherDateUsed=[DateUsed], @ProductItemCode = pin.AnalysisCode11, 
   @ProductDescription = pin.ProductDescription,@DeviceLotID = VC.Devicelotid
 from [VoucherCodes]  VC left join ProductInfo pin on VC.ExtReference=pin.AnalysisCode11 collate DATABASE_default      
 WHERE DeviceId=@VoucherNumber and VC.ClientID = @ClientID        
/* 2022-10-04
--Changed to add the Description below. If there is no product associated with the Code,
--Check if there is a Description on the DeviceProfileTemplate to Use Instead
--This is the scenario where we are using codes to give points but they are NOT Packaging codes
*/
 if @ProductDescription  is null
 Begin 
 select @ProductDescription  = dpt.[description] from devicelot dl 
 join DeviceLotDeviceProfile dldp on dl.id=dldp.devicelotid
 join DeviceProfileTemplate dpt on dpt.id=dldp.deviceprofileid
 where dl.id = @DeviceLotid
 End

 -- first we will verify if the voucher is valid for this client        
 IF @VoucherName IS NULL        
 BEGIN        
  SET @ErrorCode = 902 --InvalidVoucher        
  RETURN        
 END        
        
 IF isnull (@VoucherExpirartionDate,'2099-12-31') < GetDate()        
 BEGIN        
  SET @ErrorCode = 902 --VoucherExpired        
  RETURN        
 END        
        
 IF @VoucherDeviceStatus !=@DeviceStatusID_Active        
 BEGIN        
  SET @ErrorCode = 902 --VoucherNotActive        
  RETURN        
 END        
 ----For NON classical, the voucher can be used only once.        
 IF @Classical = 0 and @VoucherDateUsed is not null  --Can be used ONCE        
 BEGIN        
  SET @ErrorCode = 901 --AlreadyRedeemed        
  RETURN        
 END        
 --------------------------------------------------     
 


 declare @DeviceAccounts table (DeviceID Nvarchar(25), DeviceStatusID int, AccountID int, AccountStatusID int, PointsBalance Int);        
 --Get all the users devices with accounts        
 insert into @DeviceAccounts (DeviceID , DeviceStatusID , AccountID , AccountStatusID , PointsBalance)        
 Select dv.Deviceid, DeviceStatusid, ac.Accountid,AccountStatusTypeId, PointsBalance        
 from device dv join account ac on ac.accountid=dv.accountid         
 join deviceprofile dp on dp.deviceid=dv.Id join DeviceProfileTemplate dpt         
 join DeviceProfileTemplateType dptt on dptt.Id = dpt.DeviceProfileTemplateTypeId      
 on dpt.Id=dp.DeviceProfileId        
 where dv.Userid = @UserId and dptt.[name] = 'Loyalty'      
           
 IF NOT EXISTS (select 1 from @DeviceAccounts where  DeviceStatusId= @DeviceStatusID_Active )        
 BEGIN        
  SET @ErrorCode = 903 --InvalidUser        
  RETURN        
 END        
        
 ----For Classical check if @userID passed has Redeemed it before        
/*
{     "LimitPerDayPerMember": 0,          "LimitPerWeekPerMember": 0,         "LimitPerMonthPerMember": 0, 
      "LimitPerDayPerMemberPerItem": 5,   "LimitPerWeekPerMemberPerItem": 10, "LimitPerMonthPerMemberPerItem": 20, }
*/      
      
      Declare @LimitPerDayPerMember int,@LimitPerWeekPerMember int, @LimitPerMonthPerMember int, @LimitPerYearPerMember int,
      @LimitPerDayPerMemberPerItem int,@LimitPerWeekPerMemberPerItem int, @LimitPerMonthPerMemberPerItem int
      /*Get Limits into variables*/
      SELECT @LimitPerDayPerMember = [Value] FROM openjson ((SELECT [Value] FROM ClientCOnfig WHERE [key]='VoucherCodeConfiguration')) where [KEY]='LimitPerDayPerMember'
      SELECT @LimitPerWeekPerMember = [Value] FROM openjson ((SELECT [Value] FROM ClientCOnfig WHERE [key]='VoucherCodeConfiguration')) where [KEY]='LimitPerWeekPerMember'
      SELECT @LimitPerMonthPerMember = [Value] FROM openjson ((SELECT [Value] FROM ClientCOnfig WHERE [key]='VoucherCodeConfiguration')) where [KEY]='LimitPerMonthPerMember'
      SELECT @LimitPerYearPerMember = [Value] FROM openjson ((SELECT [Value] FROM ClientCOnfig WHERE [key]='VoucherCodeConfiguration')) where [KEY]='LimitPerYearPerMember'
      SELECT @LimitPerDayPerMemberPerItem = [Value] FROM openjson ((SELECT [Value] FROM ClientCOnfig WHERE [key]='VoucherCodeConfiguration')) where [KEY]='LimitPerDayPerMemberPerItem'
      SELECT @LimitPerWeekPerMemberPerItem = [Value] FROM openjson ((SELECT [Value] FROM ClientCOnfig WHERE [key]='VoucherCodeConfiguration')) where [KEY]='LimitPerWeekPerMemberPerItem'
      SELECT @LimitPerMonthPerMemberPerItem = [Value] FROM openjson ((SELECT [Value] FROM ClientCOnfig WHERE [key]='VoucherCodeConfiguration')) where [KEY]='LimitPerMonthPerMemberPerItem'
      
      Declare @DateCompare nvarchar(10) = left (CAST( GETDATE() AS Date ),10)
      
      if ISNULL(@LimitPerDayPerMemberPerItem,0) !=0 or ISNULL(@LimitPerDayPerMemberPerItem,0) !=0 or ISNULL(@LimitPerDayPerMemberPerItem,0) !=0             
      Begin
            drop table if exists #UserVouchersPerItem
            select DeviceID, dateused, VC.ExtReference into #UserVouchersPerItem from VoucherCodes VC
            --join ProductInfo pin on VC.ExtReference=pin.AnalysisCode11
            where UserID = @userid and VC.ExtReference=@ProductItemCode
            Delete from #UserVouchersPerItem where  left(CAST( [DateUsed] AS Date ),4) != left(CAST( GETDATE() AS Date ),4)
      
            if ISNULL(@LimitPerDayPerMemberPerItem,0) !=0
            begin
                  if @LimitPerDayPerMemberPerItem <= (select count(deviceid) from #UserVouchersPerItem where CAST( GETDATE() AS Date ) = CAST( [DateUsed] AS Date ))
                              
                  BEGIN        
                    SET @ErrorCode = 914 --LimitReachedDaily        
                        RETURN        
                  END        
            end
            
            if ISNULL(@LimitPerWeekPerMemberPerItem,0) !=0
            begin
                  if @LimitPerWeekPerMemberPerItem <= (select count(deviceid) from #UserVouchersPerItem where datepart(wk,GETDATE()) = datepart(wk,[DateUsed]))
                  BEGIN        
                    SET @ErrorCode = 915 --LimitReachedWeekly        
                        RETURN        
                  END        
            end 
            if ISNULL(@LimitPerMonthPerMemberPerItem,0) !=0
            begin
                  if @LimitPerMonthPerMemberPerItem <= (select count(deviceid) from #UserVouchersPerItem where datepart(month,GETDATE()) = datepart(month,[DateUsed]))
                  BEGIN        
                    SET @ErrorCode = 916 --LimitReachedMonthly        
                        RETURN        
                  END        
            end 
      
      
      End



      if ISNULL(@LimitPerDayPerMember,0) !=0 or ISNULL(@LimitPerDayPerMember,0) !=0 or ISNULL(@LimitPerDayPerMember,0) !=0 or ISNULL(@LimitPerYearPerMember,0) !=0 
      Begin 
            drop table if exists #UserVouchers
            /*Get All the Vouchers every used by that user - not based on time for index reasons!!!*/
            
            select DeviceID, dateused into #UserVouchers from VoucherCodes where UserID = @userid
      
            /*Remove the ones that are not in the current year*/
            Delete from #UserVouchers where  left(CAST( [DateUsed] AS Date ),4) != left(CAST( GETDATE() AS Date ),4)
            /*Check for Limits
            --910 --LimitReachedDaily
            --911 --LimitReachedWeekly
            --912 --LimitReachedMonthly
            --913 --LimitReachedYearly
            */
            --select * from #UserVouchers
            --select count(deviceid) from #UserVouchers where CAST( GETDATE() AS Date ) = CAST( [DateUsed] AS Date )
            --select @LimitPerDayPerMember
            if ISNULL(@LimitPerDayPerMember,0) !=0
            begin
                  if @LimitPerDayPerMember <= (select count(deviceid) from #UserVouchers where CAST( GETDATE() AS Date ) = CAST( [DateUsed] AS Date ))
                              
                  BEGIN        
                    SET @ErrorCode = 910 --LimitReachedDaily        
                        RETURN        
                  END        
            end
            
            if ISNULL(@LimitPerWeekPerMember,0) !=0
            begin
                  if @LimitPerWeekPerMember <= (select count(deviceid) from #UserVouchers where datepart(wk,GETDATE()) = datepart(wk,[DateUsed]))
                  BEGIN        
                    SET @ErrorCode = 911 --LimitReachedWeekly        
                        RETURN        
                  END        
            end 
            if ISNULL(@LimitPerMonthPerMember,0) !=0
            begin
                  if @LimitPerMonthPerMember <= (select count(deviceid) from #UserVouchers where datepart(month,GETDATE()) = datepart(month,[DateUsed]))
                  BEGIN        
                    SET @ErrorCode = 912 --LimitReachedMonthly        
                        RETURN        
                  END        
            end 
            if ISNULL(@LimitPerYearPerMember,0) !=0
            begin
                  if @LimitPerYearPerMember <= (select count(deviceid) from #UserVouchers)
                  BEGIN        
                    SET @ErrorCode = 913 --LimitReachedYearly        
                        RETURN        
                  END        
            end 
      
      /*CleanUp*/
      drop table if exists #UserVouchers
      END
      
IF @Classical = 1         
 BEGIN   
  
  --check if THIS user has used it before        
  select @CountPrevious =count(TrxDetailid) from trxdetail td join trxheader th on th.trxid=td.trxid where deviceid in (        
  select deviceid from device where userid = @UserId) and ItemCode=@VoucherNumber        
  IF @CountPrevious>0        
   BEGIN        
   SET @ErrorCode = 901 --VoucherUsedByUserID        
   RETURN        
   END        
  IF @CodeType = 'ShelterCode'        
  BEGIN        
   --Find out which Shelter if is for and return that to @ShelterName        
   select @ShelterName=uled.PropertyValue from [user] u join UserLoyaltyExtensionData uled on u.UserLoyaltyDataId=uled.UserLoyaltyDataId and propertyname = 'name' where userid = @VoucherUser        
   if isnull(@ShelterName,'')=''        
   BEGIN        
   SET @ErrorCode = 908 --ShelterNotFound        
   RETURN        
   END        
   ELSE        
   BEGIN        
    Declare @ShelterDeviceID nvarchar(25), @ShelterAccountID int        
    select top 1 @ShelterDeviceID = dv.Deviceid, @ShelterAccountID= ac.Accountid from Device dv join Account ac on dv.accountid=ac.accountid         
    where dv.userid=@VoucherUser and dv.DeviceStatusId = @DeviceStatusID_Active and ac.AccountStatusTypeId = @AccountStatusID_Active        
    IF ISNULL(@ShelterAccountID,'') = ''        
    BEGIN        
     SET @ErrorCode = 909 --ShelterNotActive        
     RETURN        
    END        
   END        
  END        
  END        
 --The Voucher is VALID and a record can be written.        
 --Get the Device for the Transaction and the account for the balance to update;         
 --if its a Shelter Code, then the userids account does NOT get updated and the Shelter does        
 --Get all the users devices, to write the record and also to check if they had this voucher before for classical ones.        
          
 select @UsersAccountId =max(accountid) from @DeviceAccounts        
 where DeviceStatusId = @DeviceStatusID_Active and AccountStatusID = @AccountStatusID_Active        
 select @PointsBalance= PointsBalance from @DeviceAccounts where AccountID =@UsersAccountId        
 select @UsersDeviceId = max(DeviceID) from @DeviceAccounts where AccountID =@UsersAccountId        
        
     
           
 BEGIN TRY        
   BEGIN TRAN        
    IF @CodeType != 'ShelterCode'        
     BEGIN        
      set @points = @VoucherValue        
     END        
     ELSE        
     BEGIN        
      set @points = 0        
     END         
      
 SET @TransactionStatusId=(SELECT TrxStatusId FROM TrxStatus WHERE [name]='Completed' AND ClientId = @ClientId)            
             
 IF @VoucherType = 'Value'      
 BEGIN      
     --Set trx type as Reward      
  SET @TransactionTypeId=(SELECT TrxTypeId FROM trxtype WHERE [name]='Reward' AND ClientId = @ClientId)          
  
  INSERT INTO TrxHeader (ClientId, DeviceId, TrxTypeId, TrxDate, SiteId, TerminalId, TerminalDescription, Reference,ImportUniqueId, OpId, TrxStatusTypeId)        
  OUTPUT INSERTED.[TrxId] INTO @TrxIdTable              
  VALUES (@ClientId, @UsersDeviceId, @TransactionTypeId, GETDATE(), @SiteId, @TerminalId, NULL, @Reference,@UniqueId, @OpId, @TransactionStatusId)       
  SET @TransactionId = (SELECT TrxId FROM @TrxIdTable)       
  --Set Value field as voucher value      
  INSERT INTO TrxDetail ([Version], TrxID, LineNumber, ItemCode, [Description], Quantity, [Value], EposDiscount, Points, PromotionId, PromotionalValue, LoyaltyDiscount, Anal1)        
  VALUES ('1', @TransactionId, 1, @VoucherNumber, @ItemDescription + ' for '+ @ProductDescription, 1, @VoucherValue, 0, 0, NULL, NULL, 0,  @ProductItemCode)
 END      
 ELSE      
 BEGIN      
  
  --Set trx type as Activity 
  if @Classical = 1
      Begin 
            SET @TransactionTypeId=(SELECT TrxTypeId FROM trxtype WHERE [name]='Activity' AND ClientId = @ClientId)        
      end
      else
      Begin
            SET @TransactionTypeId=(SELECT TrxTypeId FROM trxtype WHERE [name]='PackagingCode' AND ClientId = @ClientId)        
      End
  /* APPLY ENTER CODE PROMOTION  - START*/
      --1.Find number of completed pos and receipt transactions for the user
            Declare @codetrxCount int,@completeStatus int,@TrxCountName nvarchar(25);
            
            Select @codetrxCount= Count(TrxId) from TrxHeader th  inner join Device d on d.DeviceId=th.DeviceId 
                              where  d.UserId=@UserId and th.TrxTypeId =  @TransactionTypeId and th.TrxStatusTypeId = @TransactionStatusId --and th.DeviceId=@UsersDeviceId 

            --2.Set Promotion Profile Item based on transaction count , 0 means user is doing first entercode trx 
             SET @TrxCountName = CASE  @codetrxCount WHEN 0 THEN 'First' WHEN 1 THEN 'Second' WHEN 2 THEN 'Third' ELSE 'NA' END

      DECLARE @offerValue float,@offerType nvarchar(30),@maxpromousage int,@promoId int,@vouchercodetrxcount int,@newtrxdetailId int,@applyPromotion Bit=0;
      --SELECT ENTERCODE Promotion OfferType & Value
      SELECT   p.Id, pot.Name as OfferType ,p.PromotionOfferValue, p.MaxUsagePerMember into #entercodePromotion FROM Promotion p
      INNER JOIN PromotionOfferType pot on pot.Id=p.PromotionOfferTypeId      
      WHERE PromotionCategoryId=(select Id from PromotionCategory WHERE Name='EnterCode' and ClientId=@ClientId) 
      and Enabled=1 and p.StartDate <=GETDATE() and p.EndDate >= GETDATE() 
      IF EXISTS (SELECT 1 FROM #entercodePromotion)
      BEGIN
            Declare @UserSiteId int;
            SELECT @UserSiteId = SiteId from [User] where Userid=@UserId
            Select d.Id,d.Deviceid,dp.DeviceProfileId into #userDevices from device d inner join DeviceProfile dp on dp.DeviceId=d.Id where userid=@UserId
            SELECT top 1 @promoId = p.Id,@offerType= OfferType,@offerValue=p.PromotionOfferValue,@maxpromousage = p.MaxUsagePerMember FROM #entercodePromotion p
            INNER JOIN PromotionSites AS ps ON ps.PromotionId = p.Id 
            INNER JOIN (SELECT SiteId from GetParentSitesBySiteId(@UserSiteId))as ParentSite on ParentSite.SiteId=ps.SiteId
            INNER JOIN PromotionLoyaltyProfiles AS plp ON plp.PromotionId = p.Id 
            INNER JOIN PromotionItem pri on pri.PromotionId = p.Id and (pri.Code = @ProductItemCode or pri.PromotionItemTypeId in (select Id from PromotionItemType where Name in (@TrxCountName,'All') and ClientId=@ClientId) )
            INNER JOIN #userDevices d on d.DeviceProfileId=plp.LoyaltyProfileId
            WHERE  d.DeviceId = @UsersDeviceId order by p.PromotionOfferValue desc
            --CHECK max usage per member  for enter code promo,against packaging code trx count for the user
            SELECT @vouchercodetrxcount = count(th.TrxID) from TrxHeader th inner join TrxDetail td on th.TrxId=td.TrxID 
                                    where DeviceId in (select deviceid from #userDevices)  and th.TrxTypeId =@TransactionTypeId 
                                    and th.TrxStatusTypeid=@TransactionStatusId and td.PromotionID =@promoId
            -- If active enter code promo exists and no maxusagepermember set  then promotion should hit each time this sp is called
            -- If maxusagepermember exist on enter code promotion ,promotion should hit only as per  MaxUsagePerMember on promotion
            if((ISNULL(@maxpromousage,0) = 0 or   @maxpromousage > @vouchercodetrxcount) and (@offerValue > 0) and (ISNULL(@promoId,0) > 0 ))
            BEGIN
             SET @Points = CASE WHEN @offerType = 'PointsMultiplier' THEN @Points * @offerValue ELSE @Points + @offerValue  END
             SET @applyPromotion = 1;
            END
      END
      
      /* APPLY ENTER CODE PROMOTION  - END*/
  INSERT INTO TrxHeader (ClientId, DeviceId, TrxTypeId, TrxDate, SiteId, TerminalId, TerminalDescription, Reference, OpId, TrxStatusTypeId)        
  OUTPUT INSERTED.[TrxId] INTO @TrxIdTable              
  VALUES (@ClientId, @UsersDeviceId, @TransactionTypeId, GETDATE(), @SiteId, @TerminalId, NULL, @Reference, @OpId, @TransactionStatusId)       
  SET @TransactionId = (SELECT TrxId FROM @TrxIdTable)       
  --Set Points field as voucher value      
  INSERT INTO TrxDetail ([Version], TrxID, LineNumber, ItemCode, [Description], Quantity, [Value], EposDiscount, Points, PromotionId, PromotionalValue, LoyaltyDiscount, Anal1)
  VALUES ('1', @TransactionId, 1, @VoucherNumber, @ItemDescription + ' for '+ @ProductDescription, 1, 0, 0, @Points, 
      CASE WHEN @applyPromotion = 1 THEN @promoId ELSE NULL END ,CASE WHEN @applyPromotion =1 THEN @Points-ISNULL(@VoucherValue,0) ELSE NULL END, 0,  @ProductItemCode)
       SET @newtrxdetailId = SCOPE_IDENTITY();
       IF ISNULL(@promoId,0) > 0 AND @applyPromotion = 1
       BEGIN
       INSERT INTO TrxDetailPromotion(Version,PromotionId,TrxDetailId,ValueUsed) values(1,@promoId,@newtrxdetailId,@Points-ISNULL(@VoucherValue,0))
       END         
       
 END      
        
    IF @CodeType != 'ShelterCode' AND  @VoucherType != 'Value'      
    BEGIN        
    -- update the user's account with latest points balance        
     UPDATE Account SET @PointsBalance = ISNULL(PointsBalance,0),         
     PointsBalance = (ISNULL(PointsBalance,0) + @Points),        
     @NewPointsBalance = (ISNULL(PointsBalance,0) + @Points)        
     WHERE  AccountId= @UsersAccountId AND UserId = @UserId        
      --Place them in the appropriate tier
     exec [dbo].[Tier_GetSQLForTierMemberSelection_SingleUser] @UserID
       -- audit the account table        
     EXEC Insert_Audit 'U', @UserId, @SiteId, 'Account', 'PointsBalance',@NewPointsBalance,@PointsBalance        
    END        
    ELSE IF @CodeType = 'ShelterCode' AND @VoucherType != 'Value'      
    BEGIN        
     Delete FROM @TrxIdTable        
      
     set @points = @VoucherValue        
      
     INSERT INTO TrxHeader (ClientId, DeviceId, TrxTypeId, TrxDate, SiteId, TerminalId, TerminalDescription, Reference, OpId, TrxStatusTypeId,InitialTransaction)        
     OUTPUT INSERTED.[TrxId] INTO @TrxIdTable              
     VALUES (@ClientId, @ShelterDeviceID, @TransactionTypeId, GETDATE(), @SiteId, @TerminalId, NULL, @Reference, @OpId, @TransactionStatusId,@TransactionId)        
             
     SET @TransactionId = (SELECT TrxId FROM @TrxIdTable)        
             
     INSERT INTO TrxDetail ([Version], TrxID, LineNumber, ItemCode, [Description], Quantity, [Value], EposDiscount, Points, PromotionId, PromotionalValue, LoyaltyDiscount)        
     VALUES ('1', @TransactionId, 1, @VoucherNumber, @ItemDescription, 1, 0, 0, @Points, NULL, NULL, 0)        
            
     -- update the Shelters's account with latest points balance        
     UPDATE Account SET @PointsBalance = ISNULL(PointsBalance,0),         
     PointsBalance = (ISNULL(PointsBalance,0) + @Points),        
     @NewPointsBalance = (ISNULL(PointsBalance,0) + @Points)        
     WHERE  AccountId= @ShelterAccountID   
       --Place them in the appropriate tier
     exec [dbo].[Tier_GetSQLForTierMemberSelection_SingleUser] @UserID
        -- audit the account table        
     EXEC Insert_Audit 'U', @VoucherUser, @SiteId, 'Account', 'PointsBalance',@NewPointsBalance,@PointsBalance        
    END        
 ELSE IF @VoucherType = 'Value'      
 BEGIN      
  set @points = @VoucherValue        
  EXEC Insert_Audit 'U', @UserId, @SiteId, 'Reward', @VoucherName, @VoucherValue, @VoucherValue        
 END      
      
    set @PointsValue=@Points            
    IF @Classical = 0        
    BEGIN        
     --mark the voucher as redeemed by updating the userId        
     UPDATE [VoucherCodes]         
     SET UserId=@UserId , [DateUsed] = GetDate()        
     WHERE DeviceId=@VoucherNumber        
    END        
 print @Userid      
    --audit the device table        
    EXEC Insert_Audit 'U',@UserId, @SiteId, 'Device', 'UserId',@UserId        
    EXEC TriggerActionsBasedOnTransactionHit @ClientId, @UserId, @TransactionId   
       
   COMMIT TRAN        
  END TRY        
  BEGIN CATCH        
   IF @@TRANCOUNT > 0        
   BEGIN        
    ROLLBACK TRANSACTION        
   END        
   SET @ErrorCode = 999  --InternalServerError        
  END CATCH        
 END
