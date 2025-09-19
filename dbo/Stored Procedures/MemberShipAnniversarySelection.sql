-- =============================================
-- Author:		Bibin Abraham
-- Create date: 29/06/2020
-- Description:	Apply MembershipAnniversary promotion to user on his loyalty anniversary
-- =============================================
Create PROCEDURE [dbo].[MemberShipAnniversarySelection] (@ClientName varchar(25))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		Declare @useractivestatus int,@ClientId int,@loyaltyUserType int,@loyaltyprofileType int,@deviceStatusId int;;
		Select @ClientId= ClientId from Client where Name=@ClientName
		Select @useractivestatus = UserStatusId from UserStatus where Name='Active' and ClientId=@ClientId
		Select @loyaltyUserType = UserTypeId from UserType where Name='LoyaltyMember' and ClientId=@ClientId
		Select @loyaltyprofileType = Id from DeviceProfileTemplateType where Name='Loyalty' and ClientId=@ClientId
		Select @deviceStatusId = DeviceStatusId from DeviceStatus where Name='Active' and ClientId=@ClientId

		Select u.UserId,u.CreateDate,DATEDIFF(Year,u.CreateDate,GetDate()) as anniversary into #tmpanniversary 
		from [User] u		
		
		-- Add the number of years difference between user Create date and the current date 
		where DATEADD(year,DATEDIFF(Year,u.CreateDate,GetDate()),u.CreateDate) 
		-- compare to range "today"
		BETWEEN GetDate()
		-- to 1 days from today
		AND DATEADD(Day,1,GetDate())
		-- duplicate for following year
		OR DATEADD(year,DATEDIFF(Year,u.CreateDate,GetDate())+1,u.CreateDate) 
		BETWEEN GetDate() 
		AND DATEADD(Day,1,GetDate()) 
		AND UserStatusId=@useractivestatus and UserTypeId=@loyaltyUserType -- active loyalty user
		

		DECLARE @userid int,@anniverycount int,@anniversarytype varchar(30);
		DECLARE db_cursor CURSOR FOR  
				SELECT UserId,anniversary from #tmpanniversary 
				-----------------------------------------------------
				OPEN db_cursor  
				FETCH NEXT FROM db_cursor INTO @userid ,@anniverycount 

				WHILE @@FETCH_STATUS = 0  
				BEGIN  
				--the string @anniversarytype set below should match the one on PromotionMemberProfileItemType table
				set @anniversarytype = case @anniverycount when  1 then 'FirstAnniversary' when 2 then 'SecondAnniversary' when 3 then 'ThirdAnniversary' end
				if len(@anniversarytype) > 0 and len(@userId) > 0 
				BEGIN
				print @anniversarytype
				EXEC dbo.ApplyPoints @ClientName,@userid,'MembershipAnniversary',@anniversarytype,0
				END
				FETCH NEXT FROM db_cursor INTO @userid ,@anniverycount 
				END

END
