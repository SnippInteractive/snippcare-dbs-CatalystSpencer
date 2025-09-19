-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[API_Member_CreateMember] (@json nvarchar(max) = null)
AS
BEGIN
	SET NOCOUNT ON;


	IF OBJECT_ID('tempdb..#JsonTemp') IS NOT NULL 
	DROP TABLE #JsonTemp

	IF OBJECT_ID('tempdb..#ReturnTable') IS NOT NULL 
	DROP TABLE #ReturnTable

	IF OBJECT_ID('tempdb..#Compare') IS NOT NULL 
	DROP TABLE #Compare

	create table #JsonTemp( Id INT identity);
	create table #ReturnTable( Id INT identity);

	declare @MemberId int, @ReturnValue Nvarchar(max), @execNew varchar(max) = '', @JsonTemp varchar(max) = '',
	 @execCurrent varchar(max) = '', @JsonCurrent varchar(max) = '', @setNull varchar(max), @setNullTemp varchar(max);
   -- DECLARE @json varchar(max)
    Declare @Member varchar(max),@PersonalDetails varchar(max), @UserLoyaltyData varchar(max), @UserProfileExtraInfo varchar(max), @ExtensionData varchar(max), @ContactDetails varchar(max), @Address varchar(max)


	set @json  = '{"MemberId":1400009,"Username":"Peter1","SiteRef":"1107","MemberType":"LoyaltyMember","MemberSubType":"Normal","MemberStatus":"Active","ContactByEmail":0,"ContactByPhone":0,"ContactBySms":0,"ContactByMail":0,"Magazine":1,"LastUpdatedDate":"2018-02-14T14:21:19.333","LastUpdatedBySiteRef":"1107",
		"PersonalDetails":{"DateOfBirth":"1939-01-01T00:00:00","Firstname":"Peter","Lastname":"Durlacher","GenderType":"Male","TitleTypeId":1,"SalutationId":1},
		"UserLoyaltyData":{"TurnoverAll":0.0000,"TurnoverLastYear":0.0000,"TurnoverYTD":0.0000,"UserLoyaltyDataId":14978},
		"UserProfileExtraInfo":{"Covercard":"80756015620123419440","MpiId":""},		
		"ExtensionData":[{"PropertyName":"TPHC","PropertyValue":"False"},{"PropertyName":"IsRatgeber","PropertyValue":"True"}],
		"ContactDetails":[{"ContactDetailsId":2,"ContactDetailsType":"Main","Email":"","Fax":"+41 61 416 90 99","Phone":"+41 61 416 90 90"}],
		"Address":[{"AddressId":1781966,"AddressStatus":"Current","AddressLine1": "Cork", "AddressType":"Main","AddressValidStatus":"Valid","CountryCode":"CH","PostBox":0,"PostBoxNumber":"0","LastUpdatedBy":"helpdesksupervisor"}]}'

	select @Member = STUFF((SELECT ',' + QUOTENAME([key]) + ' nvarchar(max)' from (
					     select [key], [value]					
					     from openjson(json_query(@json,'$')) a) a
						group by [key], [value]
						order by [key]
				  FOR XML PATH(''), TYPE
				  ).value('.', 'NVARCHAR(MAX)'),1,1,'')
 
	select @PersonalDetails = STUFF((SELECT ',' + QUOTENAME([key]) + ' varchar(max)' from (
					     select [key], [value]				 
					     from openjson(json_query(@json,'$.PersonalDetails')) a) a
						group by [key], [value]
						order by [value]
				  FOR XML PATH(''), TYPE
				  ).value('.', 'NVARCHAR(MAX)'),1,1,'')

	select @UserLoyaltyData = STUFF((SELECT ',' + QUOTENAME([key]) + ' varchar(max)' from (
					      select [key], [value]		
					     from openjson(json_query(@json,'$.UserLoyaltyData')) b) b
						group by [key], [value]
						order by [value]
				  FOR XML PATH(''), TYPE
			  ).value('.', 'NVARCHAR(MAX)'),1,1,'')

    select @UserProfileExtraInfo = STUFF((SELECT ',' + QUOTENAME([key]) + ' varchar(max)' from (
					     select [key], [value]
					     from openjson(json_query(@json,'$.UserProfileExtraInfo')) c) c
						group by [key], [value]
						order by [value]
				  FOR XML PATH(''), TYPE
			  ).value('.', 'NVARCHAR(MAX)'),1,1,'')

	select @ExtensionData = STUFF((SELECT ',' + QUOTENAME([key]) + ' varchar(max)' from (
					     select [key], [value]
					     from openjson(json_query(@json,'$.ExtensionData[0]')) d) d
						group by [key], [value] order by [value]
				  FOR XML PATH(''), TYPE
			  ).value('.', 'NVARCHAR(MAX)'),1,1,'')

	select @ContactDetails = STUFF((SELECT ',' + QUOTENAME([key]) + ' varchar(max)' from (
					     select [key], [value]		
					     from openjson(json_query(@json,'$.ContactDetails[0]')) b) b
						group by [key], [value] order by [value]
				  FOR XML PATH(''), TYPE
			  ).value('.', 'NVARCHAR(MAX)'),1,1,'')

	select @Address = STUFF((SELECT ',' + QUOTENAME([key]) + ' varchar(max)' from (
					     select [key], [value]		
					     from openjson(json_query(@json,'$.Address[0]')) b) b
						group by [key], [value] order by [value]
				  FOR XML PATH(''), TYPE
			  ).value('.', 'NVARCHAR(MAX)'),1,1,'')

	SET @MemberId = JSON_VALUE(@json,'$.MemberId')

	exec [dbo].[API_Member_GetMemberByMemberId] 1400021, @ReturnValue output;

	set @JsonTemp = 'Alter table #JsonTemp add ' + @Member+', ' + @PersonalDetails + ', ' + @UserLoyaltyData + ', '
	 + @UserProfileExtraInfo +',' + @ContactDetails+',' + @Address;

	set @JsonCurrent = 'Alter table #ReturnTable add ' + @Member+', ' + @PersonalDetails + ', ' + @UserLoyaltyData + ', '
	 + @UserProfileExtraInfo  +',' + @ContactDetails+',' + @Address;

    set @execNew = '
				insert into #JsonTemp	
				select a.*,  b.*,c.*,
				d.*, f.*,g.*
				from openjson ('''+@json+''')
				with
				(
					[Address] nvarchar(max) as JSON,
					[ContactByEmail] varchar(max),
					[ContactByMail] varchar(max),
					[ContactByPhone] varchar(max),
					[ContactBySms] varchar(max),
					[ContactDetails] nvarchar(max) as JSON,
					[ExtensionData] nvarchar(max) as JSON,
					[LastUpdatedBySiteRef] varchar(max),
					[LastUpdatedDate] varchar(max),
					[Magazine] varchar(max),
					[MemberId] varchar(max),
					[MemberStatus] varchar(max),
					[MemberSubType] varchar(max),
					[MemberType] varchar(max),
					[PersonalDetails] nvarchar(max) as JSON,
					[SiteRef] varchar(max),
					[UserLoyaltyData] nvarchar(max) as JSON,
					[UserProfileExtraInfo] nvarchar(max) as JSON,
					[Username] varchar(max)
				) as a  
				CROSS APPLY OPENJSON (PersonalDetails) WITH (' + @PersonalDetails + ') b 
				CROSS APPLY OPENJSON (UserLoyaltyData) WITH (' + @UserLoyaltyData + ') c
				CROSS APPLY OPENJSON (UserProfileExtraInfo) WITH (' + @UserProfileExtraInfo + ') d
				CROSS APPLY OPENJSON (ContactDetails) WITH (' + @ContactDetails + ') f
				CROSS APPLY OPENJSON (Address) WITH (' + @Address + ') g'
				
	
	 set @execCurrent = '
				insert into  #ReturnTable	
				select a.*,  b.*,c.*,
				d.*,f.*,g.*
				from   openjson ('''+@ReturnValue+''')
				with
				(
					[Address] nvarchar(max) as JSON,
					[ContactByEmail] varchar(max),
					[ContactByMail] varchar(max),
					[ContactByPhone] varchar(max),
					[ContactBySms] varchar(max),
					[ContactDetails] nvarchar(max) as JSON,
					[ExtensionData] nvarchar(max) as JSON,
					[LastUpdatedBySiteRef] varchar(max),
					[LastUpdatedDate] varchar(max),
					[Magazine] varchar(max),
					[MemberId] varchar(max),
					[MemberStatus] varchar(max),
					[MemberSubType] varchar(max),
					[MemberType] varchar(max),
					[PersonalDetails] nvarchar(max) as JSON,
					[SiteRef] varchar(max),
					[UserLoyaltyData] nvarchar(max) as JSON,
					[UserProfileExtraInfo] nvarchar(max) as JSON,
					[Username] varchar(max)
				) as a 
				CROSS APPLY OPENJSON (PersonalDetails) WITH (' + @PersonalDetails + ') b 
				CROSS APPLY OPENJSON (UserLoyaltyData) WITH (' + @UserLoyaltyData + ') c
				CROSS APPLY OPENJSON (UserProfileExtraInfo) WITH (' + @UserProfileExtraInfo + ') d
				CROSS APPLY OPENJSON (ContactDetails) WITH (' + @ContactDetails + ') f
				CROSS APPLY OPENJSON (Address) WITH (' + @Address + ') g'

	set @setNull = 'update #ReturnTable set [Address] = null, [ContactDetails] = null, [ExtensionData] = null, [PersonalDetails] = null,  [UserLoyaltyData] = null,  [UserProfileExtraInfo] = null'
	set @setNullTemp = 'update #JsonTemp set [Address] = null, [ContactDetails] = null, [ExtensionData] = null, [PersonalDetails] = null,  [UserLoyaltyData] = null,  [UserProfileExtraInfo] = null'
	

	print @execCurrent


	execute(@JsonTemp)
    execute(@execNew)
	execute(@JsonCurrent)
    execute(@execCurrent)
	execute(@setNull)
	execute(@setNullTemp)

	select * into #Compare
	from #ReturnTable 
	union 
	select *
	from #JsonTemp 

	declare @cols varchar(max), @val varchar(max);

	select @cols = STUFF((
		SELECT ', case when a.' + QUOTENAME(name) + ' <> b.' + QUOTENAME(name)
		+ ' then convert(varchar(max), a.' + QUOTENAME(name)
		+ ') + ''-'' + convert(varchar(max), b.' + QUOTENAME(name) + ') end as ''' + name + ''''
		FROM   tempdb.sys.columns
		WHERE  object_id = Object_id('tempdb..#Compare')
		group by name
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'')
	
	select @val = STUFF((
		SELECT ' b.' +QUOTENAME(name) + ' is not null and '
		FROM   tempdb.sys.columns
		WHERE  object_id = Object_id('tempdb..#Compare')
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'')

	declare @x varchar(max);
	set @val = substring(@val, 1, (len(@val) - 3))
	print @val


	

	set @x = 'select distinct' + @cols + '

		      from #ReturnTable a

			  left join #JsonTemp b on a.id = b.id' 
			  
			  print @x
	execute(@x)

END


--[dbo].[API_Member_CreateMember] 