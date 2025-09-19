-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <15/04/2017>
-- Description:	<Monthly email match>
-- =============================================
CREATE PROCEDURE [dbo].[MemberMatch] 
	(	
		@tblName varchar(100)
	)
AS
BEGIN
	declare @i int = 1;
	declare @serialString varchar(max)
	declare @data table (gender varchar(50), firstname varchar(256), lastname varchar(256), email varchar(256), city varchar(50))
	
	insert into @data execute ('select Geschlecht, vorname, nachname, [E-Mail-Adresse], Ort from memberEmailMatch' )


	select ROW_NUMBER() over(order by u.UserId) id,
	'update ContactDetails set Email = ''' + dataTable.[E-Mail-Adresse] +''' where ContactDetailsId = ' + convert(varchar(max), cd.ContactDetailsId) + ';' aaa,
	u.UserId, dataTable.[E-Mail-Adresse] newValue, cd.Email oldValue
	into #toUpdateTable
	from [User] u
	join personaldetails pd on u.PersonalDetailsId = pd.PersonalDetailsId
	join GenderType gt on gt.GenderTypeId = pd.GenderTypeId
	join UserContactDetails ucd on ucd.UserId = u.UserId
	join ContactDetails cd on cd.ContactDetailsId = ucd.ContactDetailsId
	join UserAddresses ua on ua.UserId = u.UserId
	join Address a on ua.addressid = a.addressid 
	join memberEmailMatch dataTable on dataTable.ort = a.City and pd.firstname = dataTable.vorname and dataTable.nachname = pd.lastname 
	and 
		case when 
			dataTable.Geschlecht = 'f' and gt.Name = 'Female' then 1
			when 
			dataTable.Geschlecht = 'm' and gt.Name = 'Male' then 1
		else 0 end  = 1

	where a.AddressValidStatusId = 2 and a.addressstatusid = 1 and a.addresstypeid = 1
	and cd.Email is null


	select * from #toUpdateTable;
	
	--while @i < (select count(1) from @toUpdateTable)
	--begin
	--	declare @toUpdate varchar(max);

	--	select @toUpdate = updateCol  from @toUpdateTable where id = @i;

	--	insert into audit values (1, 
	--	(select userId  from @toUpdateTable where id = @i), 'Email',
	--	(select newValue  from @toUpdateTable where id = @i), 
	--	(select oldValue  from @toUpdateTable where id = @i),

	--	getdate(), 1400006, 'Newsletter Monthly Match', null, null , null)

	--	exec (@toUpdate);

	--	print @toUpdate;
	--	print @i;

	--	SET @i = @i + 1;
	--end

	
	--select @serialString = COALESCE( @serialString, '', '')  + serial + ','  from @toUpdateTable
	--select @serialString = LEFT(@serialString , LEN(@serialString ) - 1)

	--execute ('select * from ' + @tblName + ' where serial not in (' + @serialString + ')');
	--execute ('drop table '+ @tblName);

END

