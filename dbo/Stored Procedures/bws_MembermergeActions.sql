-- =============================================    
-- Author:  ANISH V SKARIA    
-- Create date: 17/04/2015    
-- Description: BackGround Actions To Merge member    
-- =============================================    
CREATE PROCEDURE [dbo].[bws_MembermergeActions]    
 -- Add the parameters for the stored procedure here    
 @MemberId1 INT,    
 @MemberId2 INT,    
 @MergeSource VARCHAR(50)='MemberRegisteration',    
 @ClientId INT=8,    
 @Result INT OUTPUT    
AS    
BEGIN     
BEGIN TRY    
BEGIN TRAN     
 UPDATE ContactHistory SET UserId=@MemberId1 WHERE UserId=@MemberId2    
     
 UPDATE MemberLink SET MemberId1=@MemberId1 WHERE MemberId1=@MemberId2    
     
 DECLARE @AccountId INT    
    
 IF EXISTS (SELECT 1 from Device d join DeviceProfile DP ON D.Id = DP.DeviceId join DeviceProfileTemplate Dpt on Dp.DeviceProfileId = Dpt.Id join DeviceProfileTemplateType DPTT on DPT.DeviceProfileTemplateTypeId = DPTT.Id join Account A on D.AccountId = A.AccountId join AccountStatus AtS on A.AccountStatusTypeId = AtS.AccountStatusId  Where DPTT.Name IN( 'Loyalty','EShopLoyalty') AND D.UserId = @MemberId1 AND AtS.Name = 'Enable')    
 BEGIN    
 SET @AccountId = (SELECT top 1 D.AccountId from Device d join DeviceProfile DP ON D.Id = DP.DeviceId join DeviceProfileTemplate Dpt on Dp.DeviceProfileId = Dpt.Id join DeviceProfileTemplateType DPTT on DPT.DeviceProfileTemplateTypeId = DPTT.Id join Account A on D.AccountId = A.AccountId join AccountStatus AtS on A.AccountStatusTypeId = AtS.AccountStatusId  Where DPTT.Name IN( 'Loyalty','EShopLoyalty') AND D.UserId = @MemberId1 AND AtS.Name = 'Enable')    
 END    
 ELSE    
 BEGIN    
 SET @AccountId = (SELECT top 1 D.AccountId from Device d join DeviceProfile DP ON D.Id = DP.DeviceId join DeviceProfileTemplate Dpt on Dp.DeviceProfileId = Dpt.Id join DeviceProfileTemplateType DPTT on DPT.DeviceProfileTemplateTypeId = DPTT.Id join Account A on D.AccountId = A.AccountId join AccountStatus AtS on A.AccountStatusTypeId = AtS.AccountStatusId  Where DPTT.Name IN( 'EShop') AND D.UserId = @MemberId1 AND AtS.Name = 'Enable')    
 END    
 if @AccountId > 0    
 begin    
 UPDATE Device SET AccountId = @AccountId Where Id IN(SELECT D.Id from Device d join DeviceProfile DP ON D.Id = DP.DeviceId join DeviceProfileTemplate Dpt on Dp.DeviceProfileId = Dpt.Id join DeviceProfileTemplateType DPTT on DPT.DeviceProfileTemplateTypeId = DPTT.Id join Account A on D.AccountId = A.AccountId join AccountStatus AtS on A.AccountStatusTypeId = AtS.AccountStatusId  Where DPTT.Name IN('Loyalty','EShopLoyalty') AND D.UserId = @MemberId1 AND AtS.Name <> 'Enable')    
 end    
     
 if @MergeSource = 'MemberLink'    
 BEGIN    
      -- Merge Delivery Address    
   IF Exists  (SELECT 1 FROM Address AS A INNER JOIN AddressType AS AT ON A.AddressTypeId = AT.AddressTypeId INNER JOIN UserAddresses AS UA ON A.AddressId = UA.AddressId WHERE AT.Name = 'Delivery'  AND AT.ClientId = @ClientId AND UA.UserId = @MemberId1)  
  
   BEGIN    
   --UPDATE Address SET IsDefault = 0 Where AddressId = (SELECT A.AddressId FROM Address AS A INNER JOIN AddressType AS AT ON A.AddressTypeId = AT.AddressTypeId INNER JOIN UserAddresses AS UA ON A.AddressId = UA.AddressId WHERE AT.Name = 'Delivery'  AND AT.ClientId = @ClientId AND UA.UserId = @MemberId2)    
   UPDATE UserAddresses SET UserId = @MemberId1 WHERE AddressId IN (SELECT A.AddressId FROM Address AS A INNER JOIN AddressType AS AT ON A.AddressTypeId = AT.AddressTypeId INNER JOIN UserAddresses AS UA ON A.AddressId = UA.AddressId WHERE AT.Name = 'Delivery' AND AT.ClientId = @ClientId AND UA.UserId = @MemberId2)    
   END    
   ELSE    
   BEGIN    
   UPDATE UserAddresses SET UserId = @MemberId1 WHERE AddressId IN (SELECT A.AddressId FROM Address AS A INNER JOIN AddressType AS AT ON A.AddressTypeId = AT.AddressTypeId INNER JOIN UserAddresses AS UA ON A.AddressId = UA.AddressId WHERE AT.Name = 'Delivery' AND AT.ClientId = @ClientId AND UA.UserId = @MemberId2)   
   END    
     --UPDATE KidsPassStampPoints SET UserId=@MemberId1 WHERE UserId = @MemberId2    
     UPDATE [CalculateLoyaltyInfo] SET MemberId = @MemberId1 WHERE MemberId = @MemberId2    
 END    
 Select 1 As Result    
    
 COMMIT TRAN    
END TRY    
BEGIN CATCH    
    ROLLBACK TRAN    
END CATCH    
END
