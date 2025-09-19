
CREATE PROCEDURE [dbo].[bws_GetNextAvailableVoucher] 
( 
	@ProfileId INT,
	@ClientId INT,
	@Result VARCHAR(55) OUTPUT
)
                                              
                                              
AS
  BEGIN
  SET NOCOUNT ON;
	DECLARE @DeviceStatusId INT
	DECLARE @T TIME(7) = '23:59:59.9999999'
	SET @DeviceStatusId=(select DeviceStatusId from DeviceStatus where Name='Active' and ClientId=@ClientId)
	DECLARE @DaysToExpire INT
	DECLARE @VoucherExpiryDate DATE
	select @DaysToExpire = dp.NumberDaysUntilExpire from DeviceProfileTemplate dt inner join DeviceExpirationPolicy dp on dt.ExpirationPolicyId=dp.Id where dt.Id=@ProfileId;
	select @VoucherExpiryDate=DATEADD(DAY,@DaysToExpire,GETDATE())
	IF EXISTS(select 1 from VoucherDeviceProfileTemplate where ClassicalVoucher=1 and id=@ProfileId)
	BEGIN		
		IF((select COUNT(*) from Device d join DeviceProfile dp on d.id=dp.DeviceId and dp.DeviceProfileId=@ProfileId and d.DeviceStatusId=@DeviceStatusId and d.ExpirationDate>=GETDATE())>1)
		BEGIN
			DECLARE @DeviceId VARCHAR(50)
			SET @DeviceId=(select top 1 d.DeviceId from Device d join DeviceProfile dp on d.id=dp.DeviceId and dp.DeviceProfileId=@ProfileId and d.Owner is null and d.UserId is null and d.DeviceStatusId=@DeviceStatusId and d.ExpirationDate>=GETDATE())
			UPDATE Device SET Owner='-1',StartDate=GETDATE(), ExpirationDate=CAST(@VoucherExpiryDate AS DATETIME)  WHERE DeviceId=@DeviceId		
			SELECT @Result = @DeviceId
		END
		ELSE IF((select COUNT(*) from Device d join DeviceProfile dp on d.id=dp.DeviceId and dp.DeviceProfileId=@ProfileId and d.DeviceStatusId=@DeviceStatusId and d.ExpirationDate>=GETDATE())=1)
		BEGIN
			select top 1 @Result= d.DeviceId from Device d join DeviceProfile dp on d.id=dp.DeviceId and dp.DeviceProfileId=@ProfileId		
		END		
		ELSE
		BEGIN
			Select @Result = '0'
		END		
	END 
  END


