-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <21/11/2017>
-- Description:	<Bulk user import>
-- =============================================
CREATE PROCEDURE [dbo].[API_Member_Migration_Import]
(
	@DataSource nvarchar(126),
	@ClientName nvarchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	---------------------------------------------------
	-- review the import date logic
	---------------------------------------------------


	-- ADD THE CHILDREN LOGIC 
	-- CHECK DOB 
	-- IF < 18 THEN 'CHILDREN' ELSE 'NORMAL'

	declare @currentDate datetime;
	declare @cols AS nvarchar(max)
	declare @adminUserId int;
	declare @clientId int;
	declare @homeSiteId int;

	
	select top 1 @clientId = ClientId from Client where Name = @ClientName;
	select top 1 @homeSiteId = SiteId from Site where SiteTypeId in (select SiteTypeId from SiteType where Name = 'HeadOffice' and ClientId = @clientId);

	exec ('update ' +  @datasource + ' set DoB = CONVERT(datetime, DOB)')

	select @cols 
		= stuff((select ',' + C.name
           from sys.columns c
           where c.object_id = OBJECT_ID('dbo.' + @DataSource) 
           for xml path('')), 1, 1, '')

		   print @cols

	exec ('insert into [dbo].[MemberImport] (' + @cols + ' )
	select * from '+@DataSource+'')

	set @currentDate = getdate();

	update MemberImport
		set ImportTableName = @DataSource, 
		Actioned = 'ReadyForImport', 
		ImportDate = @currentDate
	where actioned is null;


	update MemberImport
		set DoB = '1900-01-01 00:00:00'
	where DoB is null
	and Actioned = 'ReadyForImport'
	and ImportDate = @currentDate
	and ImportTableName = @DataSource


	update MemberImport
		set UserSubType= 'Children'
	where  datediff (year, convert (datetime, DOB), getdate()) < 18
	and Actioned = 'ReadyForImport'
	and ImportDate = @currentDate
	and ImportTableName = @DataSource

	

	IF OBJECT_ID('tempdb..#devices') IS NOT NULL
	BEGIN
		DROP TABLE #devices
	END

	update MemberImport 
		set Actioned = 'Invalid',
		ErrorCode = '1004',
		ErrorNotes = 'Invalid DOB'
	where ISDATE(dob) <> 1 
	and ImportTableName = @DataSource
	and ImportDate >= @currentDate
	and ErrorCode is null
	and Actioned = 'ReadyForImport';

	update mi
	set Actioned = 'Invalid',
		ErrorCode = '1007',
		ErrorNotes = 'Invalid SiteRef'
	from MemberImport mi
	left join Site s on s.SiteRef = mi.SiteRef
	where s.SiteId is null
	and ImportTableName = @DataSource
	and ImportDate >= @currentDate
	and ErrorCode is null
	and Actioned = 'ReadyForImport';


	select DeviceId, AccountId, OldMemberId -- 3s
	into #devices
	from (
		select distinct d.DeviceId , d.AccountId, row_number() over(order by d.deviceid) rn
		from DeviceProfile dp
		join DeviceProfileTemplate dpt on dp.DeviceProfileId = dpt.id
		join DeviceProfileTemplateType dptt on dpt.DeviceProfileTemplateTypeId = dptt.Id
		join Device d on dp.DeviceId = d.Id
		join DeviceStatus ds on d.DeviceStatusId = ds.DeviceStatusId
		where dptt.Name = 'Loyalty'
		and dptt.ClientId = @clientId
		and d.HomeSiteId = 1
		and d.UserId is null
		and ExpirationDate > GETDATE()
		and ds.Name = 'Active'
	) d
	join (
	
		select oldmemberid , row_number() over(order by oldmemberid) id
		from MemberImport
		where ImportTableName = @DataSource
		and ImportDate >= @currentDate
		and ErrorCode is null
		and Actioned = 'ReadyForImport'
	) mi
	on mi.id = d.rn

	
	select top 1 @adminUserId = UserId from [user] where username = 'helpdesksupervisor';
	
	-- update device status to reserved ......... ????????????????
	update d
	set userid = @adminUserId
	from device d
	join #devices t on t.deviceid = d.deviceid

	update a
	set userid = @adminUserId, pointsbalance = 0
	from account a
	join #devices t on t.accountid = a.accountid

	update mi
	set deviceid = t.deviceid, accountid = t.AccountId
	from MemberImport mi
	join #devices t on t.OldMemberId = mi.OldMemberId
	where ImportTableName = @DataSource
	and ImportDate >= @currentDate
	and ErrorCode is null
	and Actioned = 'ReadyForImport'


	IF OBJECT_ID('tempdb..#devices') IS NOT NULL
	BEGIN
		DROP TABLE #devices
	END

END

