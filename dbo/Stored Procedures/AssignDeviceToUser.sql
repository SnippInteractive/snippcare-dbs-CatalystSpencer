-- =============================================
-- Author:		Bibin
-- Create date: 21/02/2023
-- Description:	Assign loyalty/voucher/financial device to a user based on profileid. This Sp can be called in API_AssignDeviceToUser
-- =============================================
CREATE PROCEDURE [dbo].[AssignDeviceToUser](@UserId int,@ProfileTemplateType nvarchar(30)='Loyalty',@UserSiteId int,@ClientId int,@ProfileId int=0,@Reference nvarchar(100),@Result nvarchar(25) output)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @DeviceStatusId int,@ActivateStatus int,@ProfileStatusId int,@startDate datetime =Getdate(),@voucherdelay int;
	SELECT @DeviceStatusId = DeviceStatusId FROM DeviceStatus where Name='Active' and ClientId=@ClientId
	SET @ActivateStatus = @DeviceStatusId;
	IF @ProfileTemplateType = 'Voucher'
	BEGIN
	SELECT @DeviceStatusId = DeviceStatusId FROM DeviceStatus where Name='Ready' and ClientId=@ClientId
	-- set startdate to tomorrow as spencer want the user to use the voucher day after registeration
	Select @voucherdelay = Value from ClientConfig where Clientid=@ClientId and [Key]='VoucherDelayInDays'
			IF  ISNULL(@voucherdelay,0) > 0
			BEGIN
			SET @startDate = DATEADD(day,@voucherdelay, DATEADD(day, DATEDIFF(day, 0, GETDATE()), '00:00:30')) ; 
			--set device status to ActivationPending so it will not be returned in begin transaction on the same day of registeration.Next day job will chnage the status to Active
			--SELECT @ActivateStatus = DeviceStatusId FROM DeviceStatus where Name='ActivationPending' and ClientId=@ClientId
			 END
	END

	select @ProfileStatusId = DeviceProfileStatusId from DeviceProfileStatus where Name='Active' and ClientId=@ClientId;

	Declare @expirypolicyId int,@expiryDate datetime=DATEADD(day,365, DATEADD(day, DATEDIFF(day, 0, @startDate), '23:59:00')),@nodaystoExpire int;
	  select TOP 1 @expirypolicyId =ExpirationPolicyId from DeviceProfileTemplate where  ID = @ProfileId
	   IF @expirypolicyId > 0
	  BEGIN
	  select @nodaystoExpire = NumberDaysUntilExpire from DeviceExpirationPolicy where Id=@expirypolicyId
	  SET @expiryDate = DATEADD(day,@nodaystoExpire, DATEADD(day, DATEDIFF(day, 0, @startDate), '23:59:00')) ; 
	  END
	 Declare @outputDevice table (DeviceId varchar(20), AccountId int, UserId int, SiteId int,IdofDevice int) 
	
	 ---Assign a random device from the lot
 UPDATE top (1) d set UserId = @UserId, StartDate = @startDate,ExpirationDate=@expiryDate, HomeSiteId = @UserSiteId ,EmbossLine1= @Reference ,DeviceStatusId=@ActivateStatus
 OUTPUT inserted.DeviceId, inserted.AccountId, inserted.UserId, inserted.HomeSiteId,inserted.Id into @outputDevice       
 from [Device] d             
 inner join DeviceProfile dp on d.id = dp.DeviceId             
 where d.UserId is null             
 and d.ExtraInfo is null            
 and d.DeviceStatusId = @DeviceStatusId            
 and dp.DeviceProfileId= @ProfileId            
 and (ABS(CAST(            
 (BINARY_CHECKSUM            
   (d.Id, NEWID())) as int))  % 100) < 10       
 ----------------------------------  
 --Activate Voucher
   UPDATE DeviceProfile set StatusId=@ProfileStatusId FROM
   DeviceProfile DP  INNER JOIN @outputDevice OD 
   on DP.DeviceId=OD.IdofDevice
 

   UPDATE Account             
   SET UserId=@UserId             
   FROM Account A INNER JOIN @outputDevice OD             
   ON A.AccountId = OD.AccountId   
   
              
END
