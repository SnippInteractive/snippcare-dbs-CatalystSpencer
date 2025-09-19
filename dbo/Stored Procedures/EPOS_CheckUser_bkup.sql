-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2022-10-11
-- Description:	Include / Exclude
-- Modified Date: 2022-10-11
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_CheckUser_bkup](@ClientId int,@SourceAddress nvarchar(50))
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements
SET NOCOUNT ON;
	
BEGIN TRY                              
	DECLARE @UserId INT = 0,@DeviceId NVARCHAR(25),@profileType NVARCHAR(25) = 'Loyalty', @IsVirtual INT = 1,@message NVARCHAR(50)
IF ISNULL(@SourceAddress,'') != ''
BEGIN
	Declare @userstatusid int, @UserTypeId INT,@DeviceStatusIdActive INT,@ProfileTypeId INT,@TrxTypeId int;
	--SPENCER Loyalty DeviceProfileId
	SET @ProfileTypeId = 1;
	SET @TrxTypeId =17;
	 SET @DeviceStatusIdActive = 2;
	--SPENCER Loyalty DeviceProfileId
   -- SELECT @userstatusid =UserStatusId FROM UserStatus with(nolock) WHERE [Name]='Active' and clientid = @clientid  
	--SELECT @UserTypeId = [UserTypeId] FROM UserType with(nolock) WHERE [Name]='LoyaltyMember' and clientid = @clientid 
	--select @DeviceStatusIdActive = DeviceStatusId from [DeviceStatus] with(nolock) WHERE [Name]='Active' and clientid = @clientid 
	SET @userstatusid = 2;
	SET @UserTypeId =3;
	declare @abc int = 'abc';
	if ISNULL(@UserId,0) = 0 AND isnumeric(@SourceAddress) = 1 AND LEFT(@SourceAddress,1) ='+' -- Mobile with MobilePrefix
	BEGIN
	
		SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u  with(nolock) 
		INNER JOIN [dbo].[UserContactDetails] ucd with(nolock)  ON u.UserId = ucd.UserId 
		INNER JOIN [dbo].[ContactDetails] cd with(nolock)  ON ucd.ContactDetailsId = cd.ContactDetailsId  
		INNER JOIN [dbo].[PersonalDetails] pd with(nolock)  ON u.PersonalDetailsId = pd.PersonalDetailsId  
		INNER JOIN [dbo].UserAddresses ua with(nolock)  ON u.UserId = ua.UserId
		INNER JOIN [dbo].[Address] a with(nolock)  on ua.AddressId = a.AddressId
		INNER JOIN [dbo].[Country] c with(nolock)  on a.CountryId = c.CountryId AND C.MobilePrefix IS NOT NULL
		WHERE U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId 
		AND (ISNULL(c.MobilePrefix,'') + ISNULL(cd.MobilePhone,''))  = @SourceAddress COLLATE database_default 
		
			

	END
	ELSE IF ISNULL(@UserId,0) = 0 AND isnumeric(@SourceAddress) = 1-- Mobile with out MobilePrefix
	BEGIN
		
		SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u  
			 WHERE u.Username = @SourceAddress  
			AND U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId
/*
		IF ISNULL(@UserId,0) = 0 
		BEGIN
		SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u with(nolock)  
		INNER JOIN [dbo].[UserContactDetails] ucd with(nolock)  ON u.UserId = ucd.UserId 
		INNER JOIN [dbo].[ContactDetails] cd with(nolock) ON ucd.ContactDetailsId = cd.ContactDetailsId  
		--INNER JOIN [dbo].[PersonalDetails] pd with(nolock) ON u.PersonalDetailsId = pd.PersonalDetailsId  
		--INNER JOIN [dbo].UserAddresses ua with(nolock) ON u.UserId = ua.UserId
		--INNER JOIN [dbo].[Address] a with(nolock) on ua.AddressId = a.AddressId
		--INNER JOIN [dbo].[Country] c with(nolock) on a.CountryId = c.CountryId
		WHERE U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId 
		AND cd.MobilePhone = @SourceAddress 
		END */
	END
	
	
	IF ISNULL(@UserId,0) = 0
	BEGIN

	   SELECT TOP 1 @DeviceId = DeviceId FROM Device with(nolock) WHERE ExtraInfo = @SourceAddress AND DeviceStatusId = @DeviceStatusIdActive
	   SET @message = 'Unregistered'

		IF ISNULL(@DeviceId,'') <> ''
		BEGIN
			DECLARE @TrxStatusCompletedId INT
			--SELECT @TrxStatusCompletedId = TrxStatusId From TrxStatus with(nolock) WHERE ClientId = @ClientId AND Name = 'Completed'
			SET @TrxStatusCompletedId = 2;
			IF NOT EXISTS (SELECT 1 FROM TrxHeader with(nolock) Where DeviceId  = @DeviceId AND TrxStatusTypeId = @TrxStatusCompletedId AND TrxTypeId=@TrxTypeId)
			BEGIN
				SET @Message = 'NewUnregistered'
			END
		END

	   IF ISNULL(@DeviceId,'') =''
	   BEGIN
		 --DECLARE  @MyTable TABLE (DeviceId NVARCHAR(50) )
		 --INSERT INTO @MyTable EXEC [dbo].[GetNextAvailableDevice]  @ClientId, @profileType, @DeviceId output, @IsVirtual
		 	 /*
		 SELECT top 1 @DeviceId = d.deviceid
		 from Device d With(nolock) 
		 inner join DeviceProfile dp With(nolock) on d.id=dp.DeviceId 
		 where d.DeviceStatusId=@DeviceStatusIdActive and dp.DeviceProfileId = @ProfileTypeId  
		 and isnull(d.Owner,'0')<>'-1' and d.UserId is null and d.ExtraInfo IS NULL
		 and (ABS(CAST((BINARY_CHECKSUM (d.Id, NEWID())) as int))  % 100) < 10 
		 */

	update device     
   set ExtraInfo =@SourceAddress, StartDate = GETDATE(),  Owner='-1'   ,@DeviceId =DeviceId  
   where id = (    
    select TOP (1) d.Id     
    from [Device] d     
    inner join DeviceProfile dp on d.id = dp.DeviceId     
    where d.UserId is null     
    and d.ExtraInfo is null  and isnull(d.Owner,'0')<>'-1'
    and d.DeviceStatusId = @DeviceStatusIdActive    
    and dp.DeviceProfileId= @ProfileTypeId    
    and (ABS(CAST(    
      (BINARY_CHECKSUM    
      (d.Id, NEWID())) as int))  % 100) < 10    
   );  
		

			IF @DeviceId is not null
			BEGIN
				-- Assign the virtual device to the username
				--Update Device set Owner = '-1', ExtraInfo = @SourceAddress ,StartDate = Getdate() where DeviceId = @DeviceId
				-- Audit assigned device
				EXEC Insert_Audit 'I', 1400012, 1, 'Device', 'ExtraInfo',@DeviceId, @SourceAddress

				SET @message = 'NewUnregistered'
			END
			ELSE
			BEGIN
				-- Audit error for no available device assigned 
				EXEC Insert_Audit 'I', 1400012, 1, 'Device', 'ExtraInfo','Error, no availabe device to assign', @SourceAddress
			END
		END
	END
END

IF ISNULL(@UserId,0) > 0 AND ISNULL(@DeviceId,'') = ''
BEGIN

	SELECT TOP 1 @DeviceId = d.deviceid
	from Device d With(nolock) inner join DeviceProfile dp With(nolock) on d.id=dp.DeviceId 
	where d.UserId = @UserId AND d.DeviceStatusId=@DeviceStatusIdActive and dp.DeviceProfileId=@ProfileTypeId 

--select TOP 1 @DeviceId = d.DeviceId
--from   [Device] d with(nolock)
--where  d.UserId = @UserId AND d.DeviceStatusId = @DeviceStatusIdActive
--       and (exists (select dp.Id from   [DeviceProfile] dp with(nolock) where  d.Id = dp.DeviceId and 
--	   ((SELECT dt.Name from   DeviceProfileTemplateType dt with(nolock) inner join DeviceProfileTemplate t with(nolock) on t.DeviceProfileTemplateTypeId = dt.Id Where  t.Id = dp.DeviceProfileId) in ('Loyalty' /* @p2 */)))
--	   )
--order  by d.DeviceId desc

END

SELECT @UserId AS UserId,@DeviceId AS DeviceId,@message AS Message
	                                                      
END TRY                                                        
BEGIN CATCH       
	
	declare @errormsg nvarchar(3000),@line nvarchar(50);
	--SET @errormsg = ERROR_MESSAGE();
	set @line = ERROR_LINE()  
	SET @errormsg = ERROR_MESSAGE() + @line;
	EXEC Insert_Audit 'I', 1400012, 1, 'Device', 'CheckUser',@errormsg , @SourceAddress
END CATCH       
END
