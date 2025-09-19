-- =============================================
-- Author:		Bibin
-- Create date: 02/07/2020
-- Description:	Apply Bonus points for Pets & Members Birthday
-- =============================================
Create PROCEDURE [dbo].[MemberBirthdayPromotion](@birthdayType varchar(30),@clientName varchar(30))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	Declare @birthdayPromoValue int=50;
	Declare @birthdayCode varchar(50),@birthdayDescription varchar (100);
	Declare @tempbirthdayTable TABLE (UserId int,SiteId int ,DateOfBirth datetime,DeviceId varchar(25));
	Set @birthdayCode = case @birthdayType when 'MEMBER' then 'MemberBirthday' when 'PET' then 'PetBirthday' ELSE '' end

		Declare @useractivestatus int,@ClientId int,@loyaltyUserType int,@loyaltyprofileType int,@deviceStatusId int;
		Select @ClientId= ClientId from Client where Name=@clientName
		Select @useractivestatus = UserStatusId from UserStatus where Name='Active' and ClientId=@ClientId
		Select @loyaltyUserType = UserTypeId from UserType where Name='LoyaltyMember' and ClientId=@ClientId
		Select @loyaltyprofileType = Id from DeviceProfileTemplateType where Name='Loyalty' and ClientId=@ClientId
		Select @deviceStatusId = DeviceStatusId from DeviceStatus where Name='Active' and ClientId=@ClientId
		-- MembershipAnniversary promotion need to be set for MemberBirthday & PetBirthday first 	
		IF @birthdayType ='MEMBER'
		BEGIN
		--Select Users birthday based on dateofbirth field on personaldetails table
		insert into @tempbirthdayTable
		SELECT DISTINCT u.UserId,u.SiteId,pd.DateOfBirth,d.DeviceId --into #tempBirthday
		FROM [User] u inner join PersonalDetails pd on pd.PersonalDetailsId=u.PersonalDetailsId
		inner join Device d on d.UserId=u.UserId 
		inner join DeviceProfile dp on dp.DeviceId=d.Id 
		inner join DeviceProfileTemplate dpt on dpt.Id=dp.DeviceProfileId
		WHERE DATEPART(d, pd.DateOfBirth) = DATEPART(d, GETDATE())
				AND DATEPART(m, DateOfBirth) = DATEPART(m, GETDATE())
				AND u.UserStatusId= @useractivestatus AND UserTypeId=@loyaltyUserType --active loyaltymember 
				AND dpt.DeviceProfileTemplateTypeId = @loyaltyprofileType--loyalty profile
				AND d.DeviceStatusId=@deviceStatusId--active 
		END
		ELSE
		BEGIN
		--Select Pets birthday based on petsDob Key on extensiondata table
		insert into @tempbirthdayTable
		SELECT DISTINCT u.UserId,u.SiteId,ued.PropertyValue as DateOfBirth,d.DeviceId --into #temppetBirthday
		FROM [User] u inner join PersonalDetails pd on pd.PersonalDetailsId=u.PersonalDetailsId
		inner join Device d on d.UserId=u.UserId 
		inner join DeviceProfile dp on dp.DeviceId=d.Id 
		inner join DeviceProfileTemplate dpt on dpt.Id=dp.DeviceProfileId
		inner join UserLoyaltyExtensionData ued on u.UserLoyaltyDataId=ued.UserLoyaltyDataId
		WHERE DATEPART(d, Convert(datetime,ued.PropertyValue,103)) = DATEPART(d, GETDATE())
				AND DATEPART(m,  Convert(datetime,ued.PropertyValue,103)) = DATEPART(m, GETDATE())
				AND u.UserStatusId= @useractivestatus AND UserTypeId=@loyaltyUserType --active loyaltymember 
				AND dpt.DeviceProfileTemplateTypeId = @loyaltyprofileType--loyalty profile
				AND d.DeviceStatusId=@deviceStatusId--active 
				AND ued.PropertyName like '%DOB%' -- petDOB
		END
		Declare @userid int,@deviceId varchar(25),@userSiteId int;
		DECLARE db_cursor CURSOR FOR  
				SELECT UserId,DeviceId,SiteId from @tempbirthdayTable 
				
				-----------------------------------------------------
				OPEN db_cursor  
				FETCH NEXT FROM db_cursor INTO @userid ,@deviceId ,@userSiteId

				WHILE @@FETCH_STATUS = 0  
				BEGIN  
				if len(@userid) > 0  and len(@deviceId) > 0
				BEGIN
					--Set Promo points on userid account
					print 'call from SP'
					print @birthdayCode
					EXEC dbo.ApplyPoints @clientName,@userid,'MembershipAnniversary',@birthdayCode,0
					
				END
				FETCH NEXT FROM db_cursor INTO @userid ,@deviceId,@userSiteId
				END
				
END
