


CREATE VIEW [dbo].[UserInformation]
AS
SELECT
	cl.ClientId,
	cl.Name,

	m.UserId AS UserId, 
	m.ContactBySms, 
	m.ContactByEmail,
	m.ContactByMail,
	m.ContactByPhone,
	m.CreateDate CreateDateUser,
	m.Username,
	m.UserSubTypeId,
	m.Magazine,
	m.LastUpdatedBySiteId,
	m.NameIdentifier,
	m.Version,
	m.Password,
	m.SiteId,
	m.FirstLoginDate,
	m.LastLoginDate,
	m.ExtReference,
	m.LanguageId, 
	m.ContactStatus,
	m.LastUpdatedDate,
	m.MemberSegmentTypeId,
	m.Recruiter,
	ml.name as Child,
	ml.MemberLinkTypeId as ChildID,
	mlp.name as Boss,
	mlp.MemberLinkTypeId as BossID,
	ml.MemberId2 as Member2,
	mlp.MemberId1 as Member1,
	
	
	--cast(isnull(([FirstName] + case when len(isnull(MiddleName, ''))=0 then '' else ' ' end + isnull([MiddleName], '') + case when len(LastName)=0 then '' else ' ' end + [LastName]), '') as nvarchar(255)) AS [MemberName], 
	--cast(m.siteid as int) AS SiteId, 
	--cast(s.SiteRef as varchar(10)) AS SiteRef, 
	--cast(s.name as nvarchar(50)) AS SiteName, 
	--cast(s.clientid as int) AS ClientId, 
	--cast(cl.name as varchar(100)) AS ClientName,
	--cast(isnull(p.Firstname, '') as nvarchar(50)) AS Firstname, 
	--cast(isnull(p.Middlename, '') as nvarchar(50)) AS Middlename, 
	--cast(isnull(p.Lastname, '') as nvarchar(70)) AS Lastname, 
	--cast(Email as nvarchar(80)) Email, 
	--cast(Phone as varchar(50)) AS Phone, 
	--cast(MobilePhone as varchar(50)) AS MobilePhone, 
	--cast(isnull(g.[Name], 'Unknown') as nvarchar(50)) AS Gender,
	--cast(p.DateOfBirth as datetime) as DateOfBirth,
	--cast(m.UserStatusId as int) as UserStatusId,
	--cast(isnull(AddressValidStatusId, 0) as int) AS AddressValidStatusId,
	--isnull(ContactBySms, 0) as ContactBySms,
	--isnull(ContactByEMail, 0) as ContactByEMail,
	--isnull(ContactByMail, 0) as ContactByMail,
	--cast(CreateDate as datetime) as CreateDate, 
	--cast(isnull(LastLoginDate, CreateDate) as datetime) AS LastLoginDate,
	----cast(isnull(ml.CommunityId, isnull(mlp.CommunityId, -1)) as int) AS Community,

	--cast(isnull(cmt.[CommunityId], -1) as int) as [CommunityId],

	--cast(isnull(ml.[CreatedDate], isnull(mlp.[CreatedDate], '1900-01-01')) as datetime) CommunityCreateDate,
	--cast(-1 as int) AS CommunityAK,
	--cast('' as nvarchar(255)) AS CommunityName,
	--cast('1900-01-01' as datetime) CommunityCreateDate,
	--cast(-1 as int) ParentMemberAK,
	
	cr.[CountryId],
	cr.[CountryCode],
	cr.[Name] CountryName,
	
	addr.[City],
	addr.[AddressLine1],
	addr.[AddressLine2],
	addr.[Zip],
	addr.[Street],
	addr.[HouseNumber],
	addr.[PostBox],
	addr.[PostBoxNumber],
	addr.[AddressStatusId],
	addr.AddressTypeId,
	addr.[AddressValidStatusId],

	upei.SocialSecurity,
	upei.CoverCard,
	upei.MpiId,

	p.DateOfBirth,
	p.Firstname,
	p.Lastname,
	p.LastUpdated,
	p.PersonalDetailsId,

	c.Email,
	c.ContactDetailsTypeId,
	c.Phone,
	c.Fax,
	c.LastUpdated LastUpdatedContactDetails,

	d.DeviceId,
	d.[DeviceStatusId],
	d.DeviceTypeId,
	d.HomeSiteId,
	d.CreateDate,
	d.AccountId AccountIdDevice,
	d.AssignedBy,
	d.StartDate,
	d.DeviceLotId,
	d.[DeviceNumberPoolId],

	acc.AccountId,
	acc.[UserId] UserIdAccount,
	acc.AccountStatusTypeId,
	acc.PointsPending,
	acc.CreateDate CreateDateAccount,
	acc.MonetaryBalance,
	acc.PointsBalance,
	acc.CurrencyId,

	uld.TurnoverYTD,
	uld.TurnoverLastYear,
	uld.LastUpdated LastUpdatedUserLoyaltyData,
	uld.TurnoverAll,

	uled.PropertyName,
	uled.PropertyValue,
	uled.UserLoyaltyDataId,

	ut.Name NameUserType,
	ut.UserTypeId,

	us.Name NameUserStatus,
	us.UserStatusId
	
	

	--cast(isnull(tt.[TitleTypeId], -1) as int) as TitleId,
	--cast(isnull(case when tt.[Name] = 'NULL' then null else tt.[Name] end, '') as  nvarchar(50)) as TitleName,
	--cast(isnull(st.[SalutationTypeId], -1) as int) as SalutationAK,
	--cast(isnull(st.[Name], '') as  nvarchar(50)) as SalutationName,
	--cast(isnull(ut.[UserTypeId], -1) as int) as UserTypeId,
	--cast(isnull(ut.[Name], '') as  nvarchar(50)) as UserTypeName,
	--cast(isnull(m.[UserSubTypeId], -1) as int) as UserSubTypeId,
	--cast(isnull(p.[GenderTypeId], -1) as int) as GenderTypeId,
	--cast(isnull(m.LanguageID, -1) as int)  as LanguageID,

	--cast(isnull(case when uld.[LoyaltySignupDate] < '1900-01-01' then '1900-01-01' else uld.[LoyaltySignupDate] end, '1900-01-01') as datetime) LoyaltySignupDate,
	--cast(isnull(uld.[LoyaltyApplicationSigned], 0) as int) as LoyaltyApplicationSigned,
	--cast(isnull(uld.Recruiter, '') as  nvarchar(50)) as Recruiter
	
	FROM  dbo.[User] m 
	left join dbo.UserType ut on ut.UserTypeId = m.UserTypeId
	left join dbo.UserStatus us on us.UserStatusId = m.UserStatusId
	left join dbo.PersonalDetails p on m.PersonalDetailsId = p.PersonalDetailsId
	left join dbo.TitleType tt on p.TitleTypeId = tt.TitleTypeId
	left join dbo.SalutationType st on p.[SalutationId] = st.SalutationTypeId
	left join  
	(
		select UserAddressesId,pa.UserId 
		from dbo.UserAddresses pa
		left join dbo.Address addr on pa.AddressId=addr.AddressId
		left join [dbo].[AddressType] at on at.[AddressTypeId] = addr.[AddressTypeId]
		left join [dbo].[AddressStatus] ast on ast.[AddressStatusId] = addr.[AddressStatusId]
		
	) as a  
	on m.UserId=a.UserId
	left join dbo.UserAddresses pa on a.UserAddressesId=pa.UserAddressesId
	left join dbo.Address addr on pa.AddressId=addr.AddressId
	left join dbo.UserProfileExtraInfo upei on upei.UserId = m.UserId 
	left join 
	(
		select max(UserContactDetailsId) as UserContactDetailsId,pc.UserId from dbo.UserContactDetails pc
		left join dbo.ContactDetails c on pc.ContactDetailsId=c.ContactDetailsId
		left join [dbo].[ContactDetailsType] cdt on cdt.[ContactDetailsTypeId] = c.[ContactDetailsTypeId]
		where cdt.[Name] = 'Main'
		group by pc.UserId 
		--Main not billing again - Lots of dupes
	) as b on m.UserId=b.UserId
	left join dbo.UserContactDetails pc on b.UserContactDetailsId=pc.UserContactDetailsId
	left join dbo.ContactDetails c on pc.ContactDetailsId=c.ContactDetailsId
	left join dbo.UserLoyaltyData uld on m.UserLoyaltyDataId=uld.UserLoyaltyDataId
	left join UserLoyaltyExtensionData uled on uled.UserLoyaltyDataId = m.UserLoyaltyDataId
	left join dbo.Site s on s.siteid = m.siteid
	left join dbo.Client cl on cl.clientid = s.clientid
	left join dbo.GenderType g on g.GenderTypeId = p.GenderTypeId
	left join [dbo].[Country] cr on cr.[CountryId] = addr.[CountryId]
	left join dbo.Device d on d.userid = m.userid
	left join dbo.Account acc on acc.AccountId = d.AccountId
	outer apply
	(
		select  CommunityId, MemberId2,mlt.name, mlt.MemberLinkTypeId, CreatedDate from [dbo].[MemberLink] ml
		join [dbo].[MemberLinkType] mlt on mlt.[MemberLinkTypeId] = ml.[LinkType]
		where m.UserId = ml.MemberId2 --and mlt.[Name] = 'Community'
	) ml
	left join [dbo].[Community] cmt on ml.CommunityId = cmt.CommunityId
	outer apply
	(
		select  CommunityId, MemberId1,mlt.name, mlt.MemberLinkTypeId, CreatedDate from [dbo].[MemberLink] ml
		join [dbo].[MemberLinkType] mlt on mlt.[MemberLinkTypeId] = ml.[LinkType]
		where m.UserId = ml.MemberId1 --and mlt.[Name] = 'Community'
	) mlp
	left join [dbo].[Community] cmtp on mlp.CommunityId = cmtp.CommunityId


	

