-- =============================================
-- Author:		Kamil Wozniak
-- Create date: 10/05/2018
-- Description:	Get Member
-- =============================================
CREATE PROCEDURE [dbo].[API_Member_GetMemberByMemberId] (@MemberId int, @ReturnValue varchar(max) output)
AS
BEGIN
	SET NOCOUNT ON;

	declare @UserId int;

	set @UserId = (
		select MemberId1
		from MemberLink ml
		join MemberLinkType mlt on mlt.MemberLinkTypeId = ml.LinkType
		where ml.MemberId2 = @MemberId and mlt.Name = 'Merger'
	)

	set @UserId = isnull(@UserId, @MemberId);

	IF OBJECT_ID('tempdb.dbo.#UserDetails', 'U') IS NOT NULL
		DROP TABLE #UserDetails; 
	select 
		u.UserId MemberId,
	 Username, s.SiteRef, ut.Name MemberType, ust.Name MemberSubType, us.Name MemberStatus,
	  ContactByEmail, ContactByPhone, ContactBySms, ContactByMail,
	ContactStatus, Magazine, ExtReference, LastUpdatedDate, s1.SiteRef LastUpdatedBySiteRef, 

	pd.DateOfBirth 'PersonalDetails.DateOfBirth', 
	pd.Firstname 'PersonalDetails.Firstname', 
	pd.Lastname 'PersonalDetails.Lastname',  
	gt.Name  'PersonalDetails.GenderType', 
	pd.LastUpdated 'PersonalDetails.LastUpdated', 
	pd.Middlename 'PersonalDetails.Middlename', 
	pd.TitleTypeId 'PersonalDetails.TitleTypeId', 
	pd.SalutationId 'PersonalDetails.SalutationId', 

	uld.TurnoverAll 'UserLoyaltyData.TurnoverAll', 
	uld.TurnoverLastYear 'UserLoyaltyData.TurnoverLastYear', 
	uld.TurnoverYTD 'UserLoyaltyData.TurnoverYTD', 
	uld.LastUpdated 'UserLoyaltyData.LastUpdated', 
	u.UserLoyaltyDataId 'UserLoyaltyData.UserLoyaltyDataId',

	upei.Covercard 'UserProfileExtraInfo.Covercard',
	isnull(upei.MpiId,'') 'UserProfileExtraInfo.MpiId',
	s.SiteId

	into #UserDetails
	from [User] u
	join Site s on s.SiteId = u.SiteId
	join UserType ut on ut.UserTypeId = u.UserTypeId
	join UserSubType ust on ust.UserSubTypeId = u.UserSubTypeId
	join UserStatus us on us.UserStatusId = u.UserStatusId
	join PersonalDetails pd on pd.PersonalDetailsId = u.PersonalDetailsId
	left join GenderType gt on gt.GenderTypeId = pd.GenderTypeId
	left join UserLoyaltyData uld on uld.UserLoyaltyDataId = u.UserLoyaltyDataId
	left join Site s1 on s1.SiteId = u.LastUpdatedBySiteId
	left join UserProfileExtraInfo upei on upei.UserId = u.UserId
	where u.UserId = @UserId

	IF OBJECT_ID('tempdb.dbo.#SiteDetails', 'U') IS NOT NULL
		DROP TABLE #SiteDetails; 

	select 
		s.Name 'Site.Name',
		s.SiteId  'Site.SiteId',
		s.ParentId 'Site.ParentId', 
		st.Name 'Site.SiteTypeId',
		ss.Name 'Site.SiteStatusId',
		s.CommunicationName  'Site.CommunicationName',

		cd.ContactDetailsId 'Site.ContactDetails.ContactDetailsId',
		cdt.Name  'Site.ContactDetails.ContactDetailsType',
		cd.Email 'Site.ContactDetails.Email',
		cd.Fax 'Site.ContactDetails.Fax',
		cd.LastUpdated 'Site.ContactDetails.LastUpdated',
		cd.MobilePhone 'Site.ContactDetails.MobilePhone',
		cd.Phone 'Site.ContactDetails.Phone',

		a.AddressId 'Site.Address.AddressId',
		a.AddressLine1 'Site.Address.AddressLine1',
		a.AddressLine2 'Site.Address.AddressLine2',
		as_.Name  'Site.Address.AddressStatus',
		at_.Name  'Site.Address.AddressType',
		avs.Name  'Site.Address.AddressValidStatus',
		a.City 'Site.Address.City',
		c.CountryCode 'Site.Address.CountryCode',
		a.County 'Site.Address.County',
		c.CountryCode 'Site.Address.CountryId',
		a.Zip 'Site.Address.Zip',
		a.Street 'Site.Address.Street',
		a.LastUpdated 'Site.Address.LastUpdated',
		a.Locality 'Site.Address.Locality',
		a.PostBox 'Site.Address.PostBox',
		a.PostBoxNumber 'Site.Address.PostBoxNumber',
		a.HouseNumber 'Site.Address.HouseNumber',
		a.HouseName 'Site.Address.HouseName',
		a.Notes 'Site.Address.Notes',
		usr.Username 'Site.Address.LastUpdatedBy'
	into #SiteDetails
	from Site s
	left join ContactDetails cd on cd.ContactDetailsId = s.ContactDetailsId
	left join Address a on a.AddressId = s.AddressId
	join SiteStatus ss on ss.SiteStatusId = s.SiteStatusId
	join SiteType st on st.SiteTypeId = s.SiteTypeId
	join ContactDetailsType cdt on cdt.ContactDetailsTypeId = cd.ContactDetailsTypeId
	join AddressStatus as_ on as_.AddressStatusId = a.AddressStatusId
	join AddressType at_ on at_.AddressTypeId = a.AddressTypeId
	join AddressValidStatus avs on avs.AddressValidStatusId = a.AddressValidStatusId
	join Country c on c.CountryId = a.CountryId
	join #UserDetails u on u.SiteRef = s.SiteRef
	left join [User] usr on usr.UserId = a.LastUpdatedBy

	IF OBJECT_ID('tempdb.dbo.#DeviceDetails', 'U') IS NOT NULL
		DROP TABLE #DeviceDetails;
	select 
		d.AccountId 'AccountId',
		dpt.Code 'Code',
		d.CreateDate 'CreateDate',
		d.DeviceId 'DeviceId',
		ds.Name 'DeviceStatus',
		case when dptt.Name  = 'Loyalty' then 'Card' else dptt.Name end  'DeviceType',
		d.ExpirationDate 'ExpirationDate',
		d.HomeSiteId 'HomeSiteId',
		d.Reference 'Reference',
		d.StartDate 'StartDate',
		d.UserId  'UserId'
	into #DeviceDetails
	from Device d 
	join DeviceProfile dp on dp.DeviceId = d.Id
	join DeviceProfileTemplate dpt on dpt.Id = dp.DeviceProfileId
	join DeviceProfileTemplateType dptt on dptt.Id = dpt.DeviceProfileTemplateTypeId
	join DeviceStatus ds on ds.DeviceStatusId = d.DeviceStatusId
	where UserId = @UserId

	IF OBJECT_ID('tempdb.dbo.#AccountDetails', 'U') IS NOT NULL
		DROP TABLE #AccountDetails;
	select 
		AccountId ,   
		CreateDate , 
		c.Code CurrencyId, 
		MonetaryBalance , 
		PointsBalance, 
		PointsPending 
	into #AccountDetails
	from Account a
	join Currency c on c.Id = a.CurrencyId
	where a.AccountId in (
		select [AccountId] from #DeviceDetails
	)

	IF OBJECT_ID('tempdb.dbo.#ContactDetails', 'U') IS NOT NULL
		DROP TABLE #ContactDetails;
	select 
		cd.ContactDetailsId 'ContactDetailsId',
		cdt.Name  'ContactDetailsType',
		cd.Email 'Email',
		cd.Fax 'Fax',
		cd.LastUpdated 'LastUpdated',
		cd.MobilePhone 'MobilePhone',
		cd.Phone 'Phone'
	into #ContactDetails
	from UserContactDetails ucd
	join ContactDetails cd on cd.ContactDetailsId = ucd.UserContactDetailsId
	join ContactDetailsType cdt on cdt.ContactDetailsTypeId = cd.ContactDetailsTypeId
	where ucd.UserId = @UserId
	order by cd.LastUpdated desc

	IF OBJECT_ID('tempdb.dbo.#AddressDetails', 'U') IS NOT NULL
		DROP TABLE #AddressDetails;
	select 
		a.AddressId 'AddressId',
		a.AddressLine1 'AddressLine1',
		a.AddressLine2 'AddressLine2',
		as_.Name  'AddressStatus',
		at_.Name  'AddressType',
		avs.Name  'AddressValidStatus',
		a.City 'City',
		c.CountryCode 'CountryCode',
		a.County 'County',
		a.Zip 'Zip',
		a.Street 'Street',
		a.LastUpdated 'LastUpdated',
		a.Locality 'Locality',
		a.PostBox 'PostBox',
		a.PostBoxNumber 'PostBoxNumber',
		a.HouseNumber 'HouseNumber',
		a.HouseName 'HouseName',
		a.Notes 'Notes',
		u.Username 'LastUpdatedBy'
		into #AddressDetails
	from UserAddresses ua
	join Address a on ua.AddressId = a.AddressId
	join AddressStatus as_ on as_.AddressStatusId = a.AddressStatusId
	join AddressType at_ on at_.AddressTypeId = a.AddressTypeId
	join AddressValidStatus avs on avs.AddressValidStatusId = a.AddressValidStatusId
	join Country c on c.CountryId = a.CountryId
	left join [User] u on u.UserId = a.LastUpdatedBy
	where ua.UserId = @UserId and at_.Name = 'Main' and as_.Name = 'Current'
	order by a.LastUpdated

	IF OBJECT_ID('tempdb.dbo.#UserLoyaltyExtensionDataDetails', 'U') IS NOT NULL
		DROP TABLE #UserLoyaltyExtensionDataDetails; 
	select 
		uled.PropertyName 'PropertyName', 
		uled.PropertyValue 'PropertyValue'
	into #UserLoyaltyExtensionDataDetails
	from UserLoyaltyExtensionData uled
	join #UserDetails u on u.[UserLoyaltyData.UserLoyaltyDataId] = uled.UserLoyaltyDataId

	IF OBJECT_ID('tempdb.dbo.#MemberRelationDetails', 'U') IS NOT NULL
		DROP TABLE #MemberRelationDetails; 
	select 
		mlt.Name 'MemberRelationType', 
		u.Username 'MemberName', 
		u.UserId 'MemberId'
	into #MemberRelationDetails
	from MemberLink ml
	join MemberLinkType mlt on mlt.MemberLinkTypeId = ml.LinkType
	join [User] u on u.UserId = ml.MemberId2
	where MemberId1 = @UserId 

	insert into #MemberRelationDetails
	select 
		mlt.Name 'MemberRelationType', 
		u.Username 'MemberName', 
		u.UserId 'MemberId'
	from MemberLink ml
	join MemberLinkType mlt on mlt.MemberLinkTypeId = ml.LinkType
	join [User] u on u.UserId = ml.MemberId1
	where MemberId2 = @UserId 

	set @ReturnValue = (
		select *, (
			select * from #AccountDetails for json auto
		) Account, (
			select * from #DeviceDetails for json auto
		) Device, (
			select * from #UserLoyaltyExtensionDataDetails for json auto
		) ExtensionData, (
			select * from #ContactDetails for json auto
		) ContactDetails, (
			select * from #AddressDetails for json auto
		) Address, (
			select * from #MemberRelationDetails for json auto
		) MemberRelation
		from #UserDetails u
		join #SiteDetails s on s.[Site.SiteId] = u.SiteId
		for json path
	)	
		
	--select @ReturnValue;
END

