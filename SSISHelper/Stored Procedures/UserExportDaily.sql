
CREATE Procedure [SSISHelper].[UserExportDaily] as 
/*	--MemberID
    --LoyaltyDeviceID
    --PhoneNumber SpencerIdentifier!!!
    --FirstName
    --SurName
    --MemberType – Registered or Unregistered
    --CreationDate  or Member Since
    --LastUpdateDate
    # of Jewelry Punches
    # of Jewelry Vouchers
    # of T-Shirt Punches
	# of T-Shirt Vouchers
*/
Begin
	
	/*add new filters 
	1. USERS (Registered) that are NEW, or the ones that have an audit entry or have a transaction in the last 2 days
	2. The Devices that are started in the last two days or they had a transaction in the last two days (UNREGISTERED)
	*/
	drop table if exists #UsersChanged 
	drop table if exists #DeviceFilter 

	select userid into #UsersChanged  from (
	/*select distinct dv.userid from trxheader th join Device dv on dv.deviceid = th.deviceid 
	where dv.userid is not null and trxdate > dateadd (day,-2,GETDATE())
	union
	select distinct userid from Audit Au
	where userid is not null and changedate > dateadd (day,-2,GETDATE())
	union */
	select userid from [user] where createdate > dateadd (day,-2,GETDATE())
	)
	x
	select distinct dv.DeviceId into #DeviceFilter from Device dv join trxheader th on dv.DeviceId=th.DeviceId
	where dv.UserId is null and (StartDate >  dateadd(day,-2,GETDATE()) or th.TrxDate > dateadd(day,-2,GETDATE()))
	
	/*Get the lots of the LOYALTY cards only!*/
	Drop table if exists #Lots
	select dldp.devicelotid into #Lots from deviceprofiletemplatetype dptt 
	join deviceprofiletemplate dpt on dpt.deviceprofiletemplatetypeid = dptt.id
	join DeviceLotDeviceProfile dldp on dldp.[DeviceProfileId]=dpt.id
	where dptt.name = 'Loyalty'
	
	/*Clear up the last one*/
	Truncate Table [SSISHelper].[User_Export]

	INSERT INTO [SSISHelper].[User_Export]
	([MemberID],[Firstname],[Lastname],[MemberType],[CreateDate],[LastUpdatedDate]
	,[Email],[MobilePhone],[LoyaltyDeviceID],[ContactByEmail],[ExportDate],[Filename],[ExportStatus])
	/*Get info for the REGISTERED ones*/
	select u.userid MemberID, pd.Firstname, pd.Lastname,'Registered' AS MemberType, u.CreateDate,u.LastUpdatedDate, 
	cd.email, cd.MobilePhone, 
	--case when cd.MobilePhone is null then cd.Email else cd.MobilePhone end  SpencerIdentifier ,
	'' as LoyaltyDeviceID,u.ContactByEmail, GETDATE(), 'Spencer_UserFeed_'+ convert(nvarchar(8),getdate(),112) ,'ToExport'
	from [user] u join  [usertype] ut  on u.usertypeid=ut.usertypeid
	join personaldetails pd on u.personaldetailsid=pd.personaldetailsid
	join UserContactDetails ucd on ucd.UserId=u.UserId
	join ContactDetails cd on cd.ContactDetailsId=ucd.ContactDetailsid
	join #UsersChanged uc on uc.userid = u.userid
	where ut.[Name] in ('LoyaltyMember') 
	union
	/*Get info for the UNREGISTERED ones*/
	select Null as MemberID, '' as FirstName, '' as LastName,'UnRegistered' as MemberType, 
	NULL as CreateDate,NULL as LastUpdatedDate,
	case when ExtraInfo like '%@%' then extrainfo else '' end as email, 
    case when ExtraInfo like '%@%' then '' else extrainfo end as MobilePhone,
	--ExtraInfo as email, ExtraInfo as MobileNumber,
	--ExtraInfo as SpencerIdentifier, 
	dv.DeviceId as LoyaltyDeviceID,NULL as [ContactByEmail] , GETDATE(), 'Spencer_UserFeed_'+ convert(nvarchar(8),getdate(),112) ,'ToExport'
	from device dv join #Lots l on dv.DeviceLotId=l.DeviceLotId 
	join #DeviceFilter df on dv.DeviceId=df.DeviceId
	where ExtraInfo is not null and UserId is null 

	/*Get the loyalty card(s) for the users - do it seperate as there may be more than one!!!*/
	update ss set ss.[LoyaltyDeviceID]=u.[LoyaltyDeviceID] from  [SSISHelper].[User_Export] ss join (
	select u.MemberID, isnull(
	STUFF((SELECT '; ' + dv.deviceid FROM Device dv join #Lots l on dv.DeviceLotId=l.devicelotid
	WHERE dv.userid = u.MemberID FOR XML PATH('')), 1, 1, ''),'') [LoyaltyDeviceID] from [SSISHelper].[User_Export] u
	where u.memberid is not null) u on u.memberid=ss.memberid

	/*Get promotions and their name (with voucher profile) for Stamp cards Quality ONLY!*/
	select p.id, name, voucherprofileid, qualifyingproductQuantity, psc.userid,AfterValue into #Count
	from promotionstampcounter psc join promotion p on p.id =psc.promotionid where enabled = 1 and promotioncategoryid in (
	select id from promotioncategory where name = 'StampCardQuantity')
	Alter table #count add VoucherCount int

	----Set each field to a non NULL value
	update [SSISHelper].[User_Export] set #JewelryPunches =0,#JewelryVouchers =0,#TShirtPunches =0,	#TShirtVouchers =0
	/*How many open vouchers per profile per user*/
	update c set c.vouchercount = vc.vouchers from #Count c join (
	select count(dv.Deviceid) Vouchers,dp.deviceprofileid, UserID 
	from Device dv join deviceprofile dp on dv.id = dp.deviceid where dv.userid is not null /*for registered users only*/
	and devicestatusid in (select devicestatusid from devicestatus where name = 'Active') 
	and dp.deviceprofileid in (select distinct voucherprofileid from #count/*just take the voucher profiles for the stamps promotions*/)
	and dv.ExpirationDate > GETDATE() /*That have not already expired*/
	group by dp.deviceprofileid, UserID) vc on c.UserId=vc.UserId and c.VoucherProfileId=vc.DeviceProfileId
	/*As they are in different profiles, do the t-shirts and then the jewelery*/
	Update ute set #TShirtPunches = c.AfterValue, ute.#TShirtVouchers=isnull(c.vouchercount,0)
	from [SSISHelper].[User_Export] ute join #count c on c.UserId=ute.MemberID and c.name like '%(T-Shirts)%' and userid > 1 
	where MemberID is not null
	Update ute set #JewelryPunches = c.AfterValue, ute.#JewelryVouchers=isnull(c.vouchercount,0)
	from [SSISHelper].[User_Export] ute join #count c on c.UserId=ute.MemberID and c.name like '%(Jewelry)%' and userid > 1 
	where MemberID is not null

	/*Clean Up*/
	Drop table if exists #Lots
	Drop table if exists #count 
	drop table if exists #UsersChanged 
	drop table if exists #DeviceFilter 
	--select * from [SSISHelper].[User_Export]

End
