-- =============================================
-- Author:		Kamil Wozniak
-- Create date: 22/02/2018
-- Description:	Delete Prospect Users
-- =============================================
CREATE PROCEDURE [dbo].[API_Member_DeleteProspects] (@tableName varchar(30))
AS
BEGIN
	SET NOCOUNT ON;
	begin tran 
		declare @Address table (AddressId int);
		declare @ContactDetails table (ContactDetailsId int);
	
		
		
		select * into #UsersToDelete from _ProspectsToDelete
		--exec ('select * from ' + @tableName)

		CREATE CLUSTERED INDEX IDX_C_Users_UserID ON #UsersToDelete(UserID);

		delete from UserAddresses 
		output DELETED.AddressId into @Address
		where UserId in (select userid from #UsersToDelete);
		
		update Address set LastUpdatedBy = NULL where LastUpdatedBy in (select userid from #UsersToDelete);
		update Address set LastUpdatedBy = NULL where AddressId in (select AddressId from @Address);
		update Address set ContactDetailsId = NULL where AddressId in (select AddressId from @Address);

		delete from Address where AddressId in (select AddressId from @Address);

		delete from UserContactDetails 
		output DELETED.ContactDetailsId into @ContactDetails
		where UserId in (select userid from #UsersToDelete);
		
		delete from ContactDetails where ContactDetailsId in (select ContactDetailsId from @ContactDetails);	
		delete from UserProfileExtraInfo where UserId in (select userid from #UsersToDelete);
		delete from MemberLink where MemberId1 in (select userid from #UsersToDelete);
		delete from MemberLink where MemberId2 in (select userid from #UsersToDelete);
		delete from CalculateLoyaltyInfo where MemberId in (select userid from #UsersToDelete);
		delete from ContactHistory where UserId in (select userid from #UsersToDelete);
		
		delete from audit where userid in (select userid from #UsersToDelete)
		
		declare @UserData table (PersonalDetailsId int, UserLoyaltyDataId int );
		
		
		
		delete from [User] output DELETED.PersonalDetailsId , DELETED.UserLoyaltyDataId into @UserData  where UserId in (select userid from #UsersToDelete);
		delete from PersonalDetails where PersonalDetailsId in (select PersonalDetailsId from @UserData);
		delete from UserLoyaltyExtensionData where UserLoyaltyDataId in (select UserLoyaltyDataId from @UserData);
		delete from UserLoyaltyData where UserLoyaltyDataId in (select UserLoyaltyDataId from @UserData);
		
END

