CREATE Procedure [dbo].[RightToBeForgotten](@DeviceID nvarchar(25), @userid int,@clientid int) as
--exec [dbo].[RightToBeForgotten] '',3288148,1




Begin
-- Remove a member from database
Declare @PersonalDetailsID int, @UserLoyaltyDataID int;
if @userid is null
begin
select @userid = userid from device where deviceid = @DeviceID-- '6033231199761932'
end
if @userid is not null
begin
Declare @DeviceStatusId int;
Select @DeviceStatusId =DeviceStatusId from devicestatus where Clientid=@clientid and Name='Inactive'
update account set userid = null where userid = @userid
--set device status to inactive so that this device will never be assigned to another user
update device set userid = null,DeviceStatusId =@DeviceStatusId,EmbossLine5='Anonymised' where userid = @userid



IF OBJECT_ID('tempdb.dbo.#addresses', 'U') IS NOT NULL
begin DROP TABLE #addresses; end
IF OBJECT_ID('tempdb.dbo.#Contactdetails', 'U') IS NOT NULL
begin DROP TABLE #Contactdetails; end
IF OBJECT_ID('tempdb.dbo.#tickets', 'U') IS NOT NULL
begin DROP TABLE #tickets; end



select @PersonalDetailsID = PersonalDetailsID, @UserLoyaltyDataID= UserLoyaltyDataID from [User] where userid = @userid



Update [user] set PersonalDetailsID = NULL, UserLoyaltyDataID= NULL, Username='' where userid = @userid
select addressid into #addresses from UserAddresses where userid = @userid



delete from UserAddresses where addressid in (select addressid from #addresses)
delete from [Address] where addressid in (select addressid from #addresses)



select ContactDetailsID into #Contactdetails from [UserContactDetails] where userid = @userid
delete from UserContactDetails where ContactDetailsId in (select ContactDetailsID from #Contactdetails)
delete from ContactDetails where ContactDetailsId in (select ContactDetailsID from #Contactdetails)




delete from PersonalDetails where PersonalDetailsID = @PersonalDetailsID
delete from UserLoyaltyExtensionData where UserLoyaltyDataID = @UserLoyaltyDataID
delete from UserLoyaltyData where UserLoyaltyDataID = @UserLoyaltyDataID
delete from memberlink where memberid1 = @userid
delete from memberlink where memberid2 = @userid
select ticketid into #Tickets from ticket where userid = @userid
delete from TicketComments where ticketid in (select ticketid from #Tickets)
delete from ticket where userid = @userid
delete from Community where userid = @userid
delete from MemberDocument where userid = @userid
delete from CalculateLoyaltyOffer where CalculateLoyaltyInfoId in (select Id from CalculateLoyaltyInfo where memberid = @userid)
delete from CalculateLoyaltyInfo where memberid = @userid
delete from TierUsers where userid = @userid
delete from SegmentUsers where userid = @userid




delete from audit where userid = @userid
delete from [user] where userid = @userid



IF OBJECT_ID('tempdb.dbo.#addresses', 'U') IS NOT NULL
begin DROP TABLE #addresses; end
IF OBJECT_ID('tempdb.dbo.#tickets', 'U') IS NOT NULL
begin DROP TABLE #tickets; end
IF OBJECT_ID('tempdb.dbo.#Contactdetails', 'U') IS NOT NULL
begin DROP TABLE #Contactdetails; end



end
END
