

-- =============================================
-- Author:		Kamil Wozniak 
-- Create date: 15/12/2016
-- Description:	Deduplication
-- Steps: 
--		1. Insert .xlsx file into database
--		2. Add entry to DeduplicationQueue table
--		3. Run this SP - it will produce the following reports: Unique records, duplicates within all unprocessed tables(files) & duplicates in the database
-- =============================================
CREATE PROCEDURE [dbo].[Deduplication_EE] (
		@version varchar(30)
)
AS
BEGIN	
	Declare @i int = 1;
	Declare @toProcess int;
	Declare @select varchar(max)
	Declare @outputTbl table (RowNumber int, Id int, TableName varchar(max), SiteRef varchar(5));
	Declare @reportTable table (ReportLine varchar(max), OldDeviceId varchar(30), SiteRef varchar(5));
	Declare @allDuplicates table (i int, OldDeviceId varchar(30), SiteRef varchar(5), ReportLine varchar(max));
	Declare @allDedupCheck table (Firstname varchar(4), Lastname varchar(4), Address varchar(4), Zip varchar(4), City varchar(4), OldDeviceId varchar(30), SiteRef varchar(5))

	-- gets all tables that needs to be processed, rules - ProPharma, version(depending - recommend date), and unprocessed 
	insert into @outputTbl
	select ROW_NUMBER() over(order by Id) RowNumber, Id, TableName, SiteRef
	from DeduplicationQueue
	where Version = @version 
	and Processed = 0 
	and EposProvider = 'ProPharma';
	-- sets the select query from the table
	set @select = ' select lower(left(nom,4)) firstname, lower(left(prenom,4)) lastname, lower(left(adresse1,4)) address, lower(left(nopostal,4)) zip, lower(left(localite,4)) city, num_cli '

	--loops through all unprocessed tables
	while @i <=  (select count(1) from @outputTbl)
	begin		
		Declare @temp VARCHAR(MAX);
		Declare @siteRef VARCHAR(MAX);

		-- gets the table name
		select @temp = TableName, @siteRef = SiteRef from @outputTbl where RowNumber = @i;

		declare @Result varchar(max) = '; select CONCAT('
		-- Concatenates all columns to produce the report 
		-- Updates decimal and float to ensure the number is correctly converted to varchar 
		-- Formats the date to the same format that the client provides it (via xlsx file)
		select @Result = case when x.DATA_TYPE = 'float' or x.DATA_TYPE ='decimal' then 'alter table ' + @temp + ' alter column ' + x.COLUMN_NAME + ' integer ' else '' end  + 
		@Result + case when x.DATA_TYPE = 'datetime' then 'convert(VARCHAR(10),'+ COLUMN_NAME +', 101)' else COLUMN_NAME end + ','';'','
		from (
			select COLUMN_NAME, DATA_TYPE
			from INFORMATION_SCHEMA.COLUMNS
			where TABLE_NAME = @temp
		)x
		set @Result = LEFT(@Result, LEN(@Result) - 5) + ')'

		-- inserts into temp table the line of the file for the report and OldDeviceId 
		insert into @reportTable
		exec ( @Result + ', num_cli OldDeviceId,' + @siteRef + ' from ' + @temp + ';' )

		--gets the correct information from the table
		insert into @allDedupCheck
		exec (@select + ',' + @siteRef +' from ' + @temp)

		-- updates processed entity 
		update DeduplicationQueue set Processed = 1 where TableName = @temp and processed = 0;

		-- drops the table
		exec ('drop table ' + @temp)

		set @i = @i + 1;
	end

	-- finds all duplicates
	insert into @allDuplicates 
	select convert(int, ROW_NUMBER() over(PARTITION by duplicates.firstname, duplicates.lastname, duplicates.Address, duplicates.zip, duplicates.city order by fm.siteref)) DuplicateOrder,
	rt.OldDeviceId, rt.SiteRef, rt.ReportLine
	from @allDedupCheck fm, @reportTable rt, (
		select  firstname , lastname, Address ,zip,city, count(1) count_
		from @allDedupCheck
		group by firstname , lastname,Address,zip,city
		HAVING count(1) > 1
	) duplicates		
	where duplicates.firstname = fm.firstname
	and duplicates.lastname = fm.lastname
	and duplicates.Address = fm.Address
	and duplicates.zip = fm.zip
	and duplicates.city = fm.city
	and rt.OldDeviceId = fm.OldDeviceId

	-- finds all unique 
	select * from @reportTable 
	where OldDeviceId not in (
		select OldDeviceId 
		from @allDuplicates
	)

	-- all duplicates
	select * 
	from @allDuplicates
	
	-- check againts users in DB 
	select u.UserId, pd.Firstname, pd.Lastname, a.Zip,a.City,a.Street, pd.DateOfBirth, s.SiteRef
	from [User] u
	join PersonalDetails pd on u.PersonalDetailsId = pd.PersonalDetailsId
	join UserAddresses ua on ua.UserId = u.UserId
	join Address a on a.AddressId = ua.AddressId
	join Site s on s.SiteId = u.SiteId
	where exists (
		select 1 from @allDedupCheck fm
		where fm.firstname =  lower(left(pd.Firstname,4))
		and fm.lastname = lower(left(pd.Lastname,4))
		and fm.Address = lower(left(a.Street,4))
		and fm.zip = a.Zip
		and fm.city = lower(left(a.City,4))
	)
END

