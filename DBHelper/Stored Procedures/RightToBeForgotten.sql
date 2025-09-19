
CREATE Procedure [DBHelper].[RightToBeForgotten](@DeviceID nvarchar(25), @userid int, @EmailAddress nvarchar(50)) as 

/*
Changed by Niall  / Niamh 2019-05-08 to add the Email address also for Kieran to automate tests
exec [DBHelper].[RightToBeForgotten] '',1404757,''

*/
Begin

Declare @PersonalDetailsID int, @UserLoyaltyDataID int, @NameIdentifier varchar(36)

if @userid is null 
begin
select @userid = userid from device where deviceid = @DeviceID-- '6033231199761932'
end 
if @userid is null 
begin
select @userid =  ucd.userid from contactdetails cd join usercontactdetails ucd on cd.contactdetailsid=ucd.contactdetailsid
where email = @EmailAddress
end 





if @userid is not null
begin
	
	DECLARE @ClientId INT= (SELECT C.ClientId FROM Client C INNER JOIN [Site] S ON C.ClientId = S.ClientId INNER JOIN [User] U ON U.SiteId = S.SiteId WHERE UserId=@UserId)
	DECLARE @AccountStatusTypeId INT = (SELECT AccountStatusId FROM AccountStatus WHERE [Name]='Disable' AND ClientId=@ClientId),
	@DeviceStatusId INT =  (SELECT DeviceStatusId FROM DeviceStatus WHERE [Name]='Blocked' AND ClientId=@ClientId),
	@UserStatusId INT = (SELECT UserStatusId FROM UserStatus WHERE [Name]='InActive' AND ClientId=@ClientId)
    ---also block the device
	update account set userid = null, AccountStatusTypeId=@AccountStatusTypeId where userid = @userid
	update device set userid = null, DeviceStatusId=@DeviceStatusId, ExtraInfo=NULL where userid = @userid

	IF OBJECT_ID('tempdb.dbo.#addresses', 'U') IS NOT NULL
	begin  DROP TABLE #addresses;  end
	IF OBJECT_ID('tempdb.dbo.#Contactdetails', 'U') IS NOT NULL
	begin  DROP TABLE #Contactdetails;  end

	select @PersonalDetailsID = PersonalDetailsID, @UserLoyaltyDataID= UserLoyaltyDataID, @NameIdentifier=isnull([NameIdentifier],'NoID') from [User] where userid = @userid
	--delete from [AuthServerUAT].[AspNetUsers] where id = @NameIdentifier

	Update [user] set PersonalDetailsID = NULL, UserLoyaltyDataID= NULL, Username='', LegacyNumber=null, UserStatusId=@UserStatusId  where userid = @userid
	
	select addressid into #addresses from UserAddresses where userid = @userid

	delete from [UserAddresses] where addressid in (select addressid from #addresses)
	delete from [Address] where addressid in (select addressid from #addresses)

	select ContactDetailsID into #Contactdetails from [UserContactDetails] where userid = @userid
	delete   from UserContactDetails where ContactDetailsId in (select ContactDetailsID from #Contactdetails)
	delete   from ContactDetails where ContactDetailsId in (select ContactDetailsID from #Contactdetails)


	delete from PersonalDetails where PersonalDetailsID = @PersonalDetailsID
	delete from UserLoyaltyExtensionData where UserLoyaltyDataID = @UserLoyaltyDataID
	delete from UserLoyaltyData where UserLoyaltyDataID = @UserLoyaltyDataID

	delete from [audit] where userid = @userid
	
	IF OBJECT_ID('tempdb.dbo.#addresses', 'U') IS NOT NULL
	begin  DROP TABLE #addresses;  end
	IF OBJECT_ID('tempdb.dbo.#Contactdetails', 'U') IS NOT NULL
	begin  DROP TABLE #Contactdetails;  end

	end
END
