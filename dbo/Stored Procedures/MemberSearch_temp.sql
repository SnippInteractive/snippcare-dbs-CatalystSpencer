CREATE PROCEDURE [dbo].[MemberSearch_temp]                              
(
		@clientId			INT,
		@memberId			INT,
		@firstName			NVARCHAR(50),
		@surName			NVARCHAR(50),
		@dob				DATETIME ,
		@email				NVARCHAR(50),
		@phone				VARCHAR(20),
		@deviceId			VARCHAR(50),
		@street				NVARCHAR(50),
		@city				NVARCHAR(50), 
		@countryId			INT,
		@zip				VARCHAR(50),
		@siteId				INT,
		@phoneticSearch		BIT,
		@pageIndex			INT,
		@pageSize			INT,
		@sortProperty		NVARCHAR(25),
		@sortDirection		NVARCHAR(10),
		@sortEntity			NVARCHAR(50),
		@accountNo			NVARCHAR(50),
		@hnr				NVARCHAR(50),
		@includeProspect	BIT,
		@onlyProspect		BIT,
		@addressLine1		NVARCHAR(50),
		@postbox			BIT,
		@postboxNo			NVARCHAR(50),
		@mobile				NVARCHAR(20),
		@activityStatus		INT,
		@userSubTypeId		INT,
		@createDate			DATETIME,
		@covercard			VARCHAR(20),
		@mpid				VARCHAR(20),
		@alluserStatus		BIT,
		@externalReference	NVARCHAR(100)='' -- New Modification to include external reference in the search.
)                              
AS                              
BEGIN                              
 -- SET NOCOUNT ON added to prevent extra result sets from                              
 -- interfering with SELECT statements.                              
	SET NOCOUNT ON;                              
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED                              
                          
	DECLARE @strWHERE NVARCHAR(max) = '', 
			@strQuery NVARCHAR(max) = '' ,  
			@strUpdate nvarchar(1000),  
			@strContactDetails NVARCHAR(1000) = '', 
			@includeEshop NVARCHAR(1000), 
			@strProfiles NVARCHAR(1000), 
			@sqlORDER NVARCHAR(200)
			                            
	DECLARE @LikeEqual Varchar(5) = '='                         
                              
                              
	create table #userData                              
	(                              
		UserId			INT, 
		SiteName		varchar(100) NULL, 
		SurName			nvarchar(50) , 
		FirstName		nvarchar(50) , 
		StreetHnr		nvarchar(50) , 
		City			nvarchar(100) ,  
		Zip				nvarchar(50) , 
		MemberStatus	nvarchar(50) , 
		ActivityStatus	nvarchar(50) , 
		AddressLine1	nvarchar(50) , 
		RowNumber		INT,                         
		UserTypeId		INT, 
		UserStatusId	INT                              
	)                              
                              
	create table #userDataDistinct                              
	(                              
		UserId			INT, 
		SiteName		varchar(100) NULL, 
		SurName			nvarchar(50) , 
		FirstName		nvarchar(50) , 
		StreetHnr		nvarchar(50) , 
		City			nvarchar(100) ,  
		Zip				nvarchar(50) , 
		MemberStatus	nvarchar(50) , 
		ActivityStatus	nvarchar(50) , 
		AddressLine1	nvarchar(50) ,
		TotalCount		INT, 
		RowNumber		INT          
                                                                                           
	)                              
                      
	DECLARE @RecCount int = 0,
			@MaxResult INT = 100                              
                              
	SELECT @MaxResult = isnull(SearchCount,0) 
	FROM	Client 
	Where	ClientId = @clientId    
	                           
	IF @MaxResult = 0                              
	BEGIN                              
	SET @MaxResult = 100                              
	END                              
                              
	IF @pageIndex =-1                              
	BEGIN                              
		SET @pageIndex = 0;                              
	END 
		                             
	DECLARE @FirstRow INT = 0, @LastRow INT = 10                              
	set @LastRow = @pageSize*(@pageIndex+1)                              
	Set @FirstRow = @LastRow + 1 - @pageSize                              
                              
                              
		DECLARE @firstNamePhn NVARCHAR(50), 
				@surNamePhn NVARCHAR(50), 
				@strCount varchar(500)  ,
				@strprofileExtraInfo NVARCHAR(500)=''                            
                              
		DECLARE @AddressStatusIdCurrent INT, 
				@UserStatusIdActive INT, 
				@UserStatusIdPotential INT, 
				@addressvalidstatusid INT 
				                             
		DECLARE @AddressTypeIdMain INT, 
				@UserTypeIdLM INT,
				@UserStatusIdMerged INT      
		DECLARE @DeviceProfileActiveStatusId INT                              
                              
		SELECT @AddressStatusIdCurrent = AddressStatusId 
		FROM   [AddressStatus] 
		WHERE	Name = 'Current' 
		AND		ClientId = @clientId 
		                              
		SELECT @AddressTypeIdMain = AddressTypeId 
		FROM   [AddressType] 
		WHERE  Name = 'Main' 
		AND ClientId = @clientId 
				                             
		SELECT @UserTypeIdLM = UserTypeId  
		FROM   [UserType] 
		WHERE  Name = 'LoyaltyMember' 
		AND ClientId = @clientId 
		                              
		SELECT @UserStatusIdActive = UserStatusId  
		FROM [UserStatus] 
		WHERE ClientId = @clientId 
		AND  Name = 'Active'     
		                          
		SELECT @UserStatusIdPotential = UserStatusId  
		FROM [UserStatus] 
		WHERE ClientId = @clientId 
		AND  Name = 'Potential'  
		                            
		SELECT @addressvalidstatusid = addressvalidstatusid 
		FROM   [addressvalidstatus] 
		WHERE  Name = 'Valid' 
		AND ClientId = @clientId   
		                           
		SELECT @UserStatusIdMerged = UserStatusId  
		FROM [UserStatus] 
		WHERE ClientId = @clientId 
		AND  Name = 'Merged'    
		                     
		DECLARE @DeviceStatusIdActive INT                              
		SELECT @DeviceStatusIdActive = DeviceStatusId 
		FROM DeviceStatus 
		WHERE ClientId =  @clientId 
		AND Name = 'Active'    
		                          
		SELECT @DeviceProfileActiveStatusId=DeviceProfileStatusId 
		FROM DeviceProfileStatus 
		WHERE ClientId =  @clientId 
		AND Name = 'Active'      
                              
		IF isnull(@memberId,0) > 0                            
		BEGIN                               
			select @strWHERE = @strWHERE + ' and ( u.userid = ' + convert(varchar(20),@memberId) + ' ) '             
			--select @strWHERE = @strWHERE + ' and  u.userid = ' + convert(varchar(20),@memberId) + ' '                           
		END                               
                           
		IF isnull(@surName,'') !=''                               
		BEGIN                               
			set @surName =  replace(@surName ,'*','%')                              
			set @LikeEqual = ' = '                              
			IF CHARINDEX ('%',@surName,0) !=0                              
			BEGIN                               
				set @LikeEqual = ' like '                              
			END                               
			IF isnull(@phoneticSearch,0) !=0                               
			BEGIN                               
				--SELECT @surNamePhn = PrimaryKey from [ComputeDoubleMetaphoneKeys] (@surName)   
				SELECT @surNamePhn = SOUNDEX(@surName)                              
				--select @strWHERE = @strWHERE + ' and  (pd.PhoneticLastnamePrimaryKey = ''' + @surNamePhn + ''' or pd.PhoneticLastnameAlternativeKey = ''' + @surNamePhn + '''  ) '                              
				SELECT @strWHERE = @strWhere + 'AND SOUNDEX(pd.Lastname) '+@LikeEqual+'''' + SOUNDEX(@surName)+''''
			END                               
			ELSE                              
			BEGIN                              
				select @strWHERE = @strWHERE + ' and pd.Lastname ' + @LikeEqual + ' ''' + @surName + ''''                              
			END                                
                              
		END                                
                              
		IF isnull(@deviceId,'') !=''                               
		BEGIN                               
			select @strWHERE = @strWHERE + ' and d.deviceid = ''' + convert(varchar(20),@deviceId) + ''' '                               
		END                               
                              
		IF isnull(@firstName,'') !=''                               
		BEGIN                               
			set @firstName =  replace(@firstName ,'*','%')                              
			set @LikeEqual = ' = '                              
			IF CHARINDEX ('%',@firstName,0) !=0                              
			BEGIN                  
				set @LikeEqual = ' like '                              
			END                               
                               
			IF isnull(@phoneticSearch,0) !=0                               
			BEGIN       
				--SELECT @firstNamePhn = PrimaryKey from [ComputeDoubleMetaphoneKeys] (@firstName) 
				SELECT @firstNamePhn = SOUNDEX(@firstName)                                
				--select @strWHERE = @strWHERE + ' and  (pd.PhoneticFirstnamePrimaryKey = ''' + @firstNamePhn + ''' or pd.PhoneticFirstnameAlternativeKey = ''' + @firstNamePhn + '''  ) '                              
				SELECT @strWHERE = @strWhere + 'AND SOUNDEX(pd.FirstName) ' +@LikeEqual+''''+ SOUNDEX(@firstName)+''''
			END                               
			ELSE                              
			BEGIN                              
				select @strWHERE = @strWHERE + ' and pd.FirstName ' + @LikeEqual + ' ''' + @firstName + ''''                              
			END                                 
		END  

		IF @externalReference !=''
		BEGIN
			set @externalReference =  replace(@externalReference ,'*','%')                              
			set @LikeEqual = ' = '                              
			IF CHARINDEX ('%',@externalReference,0) !=0                              
			BEGIN                  
				set @LikeEqual = ' like '                              
			END    
			--select @strWHERE = @strWHERE + ' and ( u.ExtReference = ' + @externalReference + ' ) ' 
			select @strWHERE = @strWHERE + ' and  u.ExtReference ' + @LikeEqual + ' ''' + @externalReference + '''' 
		END
		                             
                              
			if isnull(@street,'') !=''               
			begin                               
			 set @street =  replace(@street ,'*','%')                              
			 set @LikeEqual = ' = '                              
			 if CHARINDEX ('%',@street,0) !=0                              
			 begin                               
			  set @LikeEqual = ' like '                              
			 end                 
				if isnull(@phoneticSearch,0) !=0                               
			  begin               
			   declare   @streetPhn varchar(50)                           
			   SELECT @streetPhn = PrimaryKey from [ComputeDoubleMetaphoneKeys] (@street)                              
			   select @strWHERE = @strWHERE + ' and  (a.PhoneticStreetPrimaryKey = ''' + @streetPhn + ''' or a.PhoneticStreetAlternativeKey = ''' + @streetPhn + '''  ) '                              
			  end                               
			 else                              
			  begin                              
			   select @strWHERE = @strWHERE + ' and a.Street ' + @LikeEqual + ' ''' + @street + ''''                          
			  end                                
			end                  
               
               
                          
                            
--end                       
if isnull(@hnr,'') !=''                               
begin                               
 set @hnr =  replace(@hnr ,'*','%')                              
 set @LikeEqual = ' = '                              
 if CHARINDEX ('%',@hnr,0) !=0                              
 begin                               
  set @LikeEqual = ' like '                              
 end                               
 select @strWHERE = @strWHERE + ' and a.HouseNumber ' + @LikeEqual + ' ''' + @hnr + ''''                              
end                            
if isnull(@addressLine1,'') !=''                               
begin                               
 set @addressLine1 =  replace(@addressLine1 ,'*','%')                              
 set @LikeEqual = ' = '                              
 if CHARINDEX ('%',@addressLine1,0) !=0                              
 begin                               
  set @LikeEqual = ' like '                              
 end                               
 select @strWHERE = @strWHERE + ' and a.AddressLine1 ' + @LikeEqual + ' ''' + @addressLine1 + ''''                              
end                       
if isnull(@postbox,0) !=0                               
begin                                         
 select @strWHERE = @strWHERE + ' and a.postbox = ' + convert(varchar(1), @postbox)                     
end                  
if isnull(@postboxNo,'') !=''                               
begin                               
 set @postboxNo =  replace(@postboxNo ,'*','%')                              
 set @LikeEqual = ' = '                              
 if CHARINDEX ('%',@postboxNo,0) !=0                              
 begin                               
  set @LikeEqual = ' like '                              
 end                               
 select @strWHERE = @strWHERE + ' and a.PostBoxNumber ' + @LikeEqual + ' ''' + @postboxNo + ''''                              
end            
                          
if isnull(@city,'') !=''                               
begin                               
 set @city =  replace(@city ,'*','%')                              
 set @LikeEqual = ' = '                              
 if CHARINDEX ('%',@city,0) !=0                              
 begin                               
  set @LikeEqual = ' like '                              
 end                
   if isnull(@phoneticSearch,0) !=0                               
  begin               
   declare   @cityPhn varchar(50)                           
   SELECT @cityPhn = PrimaryKey from [ComputeDoubleMetaphoneKeys] (@city)                              
   select @strWHERE = @strWHERE + ' and  (a.PhoneticCityPrimaryKey = ''' + @cityPhn + ''' or a.PhoneticCityAlternativeKey = ''' + @cityPhn + '''  ) '                              
  end                               
 else                              
  begin                              
    select @strWHERE = @strWHERE + ' and a.City ' + @LikeEqual + ' ''' + @city + ''''               
  end                
                          
end                               
                              
if isnull(@countryId,0)  > 0                              
begin                              
                               
 select @strWHERE = @strWHERE + ' and a.CountryId  = ' + convert(varchar(10),@countryId) + ' '                               
end                              
                              
if isnull(@zip,'') !=''                               
begin                               
 set @zip =  replace(@zip ,'*','%')                              
 set @LikeEqual = ' = '                              
 if CHARINDEX ('%',@zip,0) !=0                              
 begin                               
  set @LikeEqual = ' like '                              
 end                               
 select @strWHERE = @strWHERE + ' and zip ' + @LikeEqual + ' ''' + @zip + ''''                              
end                               
                              
if isnull(@email,'') !='' or  isnull(@phone,'') !='' or  isnull(@mobile,'') !=''                               
begin                               
 set @strContactDetails = '  inner join usercontactdetails ucd WITH (NOLOCK) on ucd.userid = u.userid inner join contactdetails cd on ucd.contactdetailsid = cd.contactdetailsid '                               
end                               
                              
if isnull(@phone,'') !=''                         
begin                               
set @phone =  replace(@phone ,'+','')                      
set @phone =  replace(@phone ,' ','')                      
 set @LikeEqual = ' = '                                       
 select @strWHERE = @strWHERE + ' and REPLACE(REPLACE(ISNULL(cd.Phone,''''),'' '',''''),''+'','''') ' + @LikeEqual + ' ''' + @phone + ''''                           
 --print(@strWHERE)                           
end                               
  if isnull(@mobile,'') !=''                               
begin                               
set @mobile =  replace(@mobile ,'+','')                      
set @mobile =  replace(@mobile ,' ','')           set @LikeEqual = ' = '                              
 select @strWHERE = @strWHERE + ' and REPLACE(REPLACE(ISNULL(cd.MobilePhone,''''),'' '',''''),''+'','''') ' + @LikeEqual + ' ''' + @mobile + ''''                                     
 --print(@strWHERE)                           
end                               
                                 
if isnull(@email,'') !=''                               
begin   
 set @email =  replace(@email ,'*','%')                              
 set @LikeEqual = ' = '
 if CHARINDEX ('%',@email,0) !=0                              
 begin                               
  set @LikeEqual = ' like '                              
 end                              
 select @strWHERE = @strWHERE + ' and cd.email ' + @LikeEqual + ' ''' + @email + ''''                              
end                             
                              
if isnull(@dob,'1900-01-01') != '1900-01-01'                              
begin                               
 select @strWHERE = @strWHERE + ' and pd.DateOfBirth = ''' + convert(varchar(10),@dob,120) + ''''                              
End                              
                              
                              
IF ISNULL(@siteId,0)> 0                  
begin                  
   select @strWHERE = @strWHERE + ' and u.SiteId = ' + convert(varchar(20),@siteId)                  
end                              
                               
if isnull(@activityStatus,0)> 0         
begin                  
 select @strWHERE = @strWHERE + ' and u.UserStatusId = ' + convert(varchar(5),@activityStatus)                  
end    
else if isnull(@activityStatus,0) = -1    and  isnull(@alluserStatus,0) = 0   
 begin
 select @strWHERE = @strWHERE + ' and u.UserStatusId = ' + convert(varchar(5),@UserStatusIdActive)
 end 
 
              
if isnull(@userSubTypeId,0)>0                  
begin                  
 select @strWHERE = @strWHERE + ' and u.UserSubTypeId = ' + convert(varchar(5),@userSubTypeId)                  
end                  
                  
if isnull(@createDate,'1900-01-01') != '1900-01-01'                              
begin                               
 select @strWHERE = @strWHERE + ' and convert(varchar(10),u.CreateDate,120) = ''' + convert(varchar(10),@createDate,120) + ''''                              
End                   
if (len(@covercard) > 0 or  len(@mpid) > 0  )              
begin                  
 set @strprofileExtraInfo =  '  inner join [dbo].[UserProfileExtraInfo] ac WITH (NOLOCK) on u.UserId = ac.UserId '                   
	if isnull(@covercard,'')!=''  
	 begin
	select @strWHERE = @strWHERE + ' and ac.Covercard = ''' + convert(varchar(20),@covercard) + ''' '  
	end
	 if isnull(@mpid,'')!=''  
	 begin
	select @strWHERE = @strWHERE + ' and ac.MpiId = ''' + convert(varchar(20),@mpid) + ''' '   
	end            
end                  
                  
--if isnull(@voucherNumber,'') !=''                               
--begin                               
-- set @voucherNumber =  replace(@voucherNumber ,'*','%')                              
-- set @LikeEqual = ' = '                              
-- if CHARINDEX ('%',@voucherNumber,0) !=0                              
-- begin                               
--  set @LikeEqual = ' like '                              
-- end                               
-- select @strWHERE = @strWHERE + ' and d.deviceid ' + @LikeEqual + ' ''' + @voucherNumber + ''''                   
                   
-- --select @strWHERE = @strWHERE + ' and dt.Name =''Voucher'''                         
--end                  
                    
if isnull(@accountNo,'')!=''                  
begin                  
 set @accountNo =  replace(@accountNo ,'*','%')                              
 set @LikeEqual = ' = '                              
 if CHARINDEX ('%',@accountNo,0) !=0                              
 begin                               
  set @LikeEqual = ' like '                
 end                               
 select @strWHERE = @strWHERE + ' and u.externalmemberid ' + @LikeEqual + ' ''' + @accountNo + ''''                   
end                  
-- bibin comment ,this devicejoin is created for  prospect member with out device ,so onlyprospect search should not have joins to device related tables
Declare @strDeviceJoins nvarchar(1000);
set @strDeviceJoins = 'inner join device d  WITH (NOLOCK) on d.userid=u.userid                              
						inner join DeviceProfile dp  WITH (NOLOCK) on d.id = dp.deviceid                               
						inner join DeviceProfileTemplate t  WITH (NOLOCK) on dp.DeviceProfileID = t.id                               
						inner join DeviceProfileTemplateType dt on t.DeviceProfileTemplateTypeId = dt.Id '
	   
   
if isnull(@includeProspect,0) != 0                               
begin          
	                 
	select @strWHERE = @strWHERE + '  and u.UserTypeId in ( select UserTypeId from UserType where clientid='+ convert(varchar(5),@clientId) +' and Name in (''Prospect'',''LoyaltyMember''))'  
	set @strDeviceJoins = '';                            
end
      
if isnull(@onlyProspect,0) != 0                               
begin          
	declare @prospecttypeId int ;
	select  @prospecttypeId = UserTypeId from UserType where ClientId=@clientId and Name='Prospect'                   
	 select @strWHERE = @strWHERE + '  and u.UserTypeId = ' + convert(varchar(3),@prospecttypeId)  
	 set @strDeviceJoins = '';                            
end                

                                   
DECLARE @strQueryMain NVARCHAR(MAX) = ''  

                             
SET @strQueryMain = 'INSERT INTO #userData(UserId, SiteName, SurName,FirstName,StreetHnr,City,Zip,MemberStatus, UserTypeId, UserStatusId,ActivityStatus,AddressLine1)  SELECT  DISTINCT top '+convert(varchar(5),@MaxResult)+' u.UserId ,          
 s.name as SiteName,             
 pd.Lastname SurName, pd.FirstName, isnull(a.Street,'''')  StreetHnr, a.City,  a.Zip, ''xxxxxxxxxxxxxx''  MemberStatus, u.UserTypeId, u.UserStatusId, '                              
 + 'us.name ActivityStatus, isnull(a.AddressLine1,'''')  AddressLine1  FROM   [User] u WITH (NOLOCK)                    
 inner join [PersonalDetails] pd WITH (NOLOCK) on u.PersonalDetailsId = pd.PersonalDetailsId                             
 inner join [Site] s WITH (NOLOCK) on s.siteid = u.siteid                  
 inner join  [UserAddresses] ua  WITH (NOLOCK) on ua.userid = u.userid                              
 inner join Address a  WITH (NOLOCK) on ua.AddressId = a.AddressId                               
  '+ @strDeviceJoins+' ' +  @strprofileExtraInfo + '                            
 inner join userstatus us on us.userstatusid = u.userstatusid ' + @strContactDetails                              
                  
set @strQuery = @strQueryMain +  'where  AddressTypeId = ' + convert(varchar(3),@AddressTypeIdMain) + ' and AddressStatusId = ' + convert(varchar(3),@AddressStatusIdCurrent)       
--  + ' and AddressValidStatusId = ' + convert(varchar(3),@addressvalidstatusid)        
                     
if upper(@sortEntity) = 'USERSTATUS'                              
begin                              
 set @sortProperty = 'ActivityStatus'                              
end                              
if upper(@sortProperty) = 'LASTNAME'                              
begin                               
 set @sortProperty = 'SurName'                              
end                               
set @sqlORDER = ' ORDER BY ' + @sortProperty + ' ' + @sortDirection                              
                              
--print @strQuery                              
--print 'where clause included'                              
set @strQuery = ' '+ @strQuery + @strWhere  +@sqlORDER+ '  '                              
      
  print @strQuery                             
                              
print @strQuery                              
exec (@strQuery)                              
                              
                              
--print @strQuery                              
 update #userData set MemberStatus = dbo.GetMemberStatus(UserId, @clientId )          
--DELETE from #userData where Activitystatus not in ('Active','Potential')                                
                              
                              
--print 'As far as here!'                              
                              
set @strQuery = 'INSERT INTO #userDataDistinct (UserId,SiteName,SurName, FirstName , StreetHnr,City,Zip,MemberStatus,ActivityStatus,AddressLine1,TotalCount,RowNumber)  Select UserId,SiteName,SurName,FirstName,StreetHnr,City,Zip,                      
  
MemberStatus,ActivityStatus,AddressLine1,TotalCount ,ROW_NUMBER() OVER(' + @sqlOrder + ' ) as RowNumber  from ( ' +                              
'select distinct UserId,SiteName,SurName,FirstName,StreetHnr,City,Zip,  MemberStatus,ActivityStatus,AddressLine1,0 TotalCount from [#userData]  ) x'                   
--print @strQuery                              
exec (@strQuery)                           
                   
--select * from [#userDataDistinct]                               
select @RecCount = count(*) from #userDataDistinct --'-- + @TempTable + ''--'DECLARE @RecCount INT                               
--select @RecCount                              
update #userDataDistinct SET TotalCount = @RecCount                              
                              
--PRINT 'ABC'                              
                              
----------This can be called from the member service where there is more information needed from the Address table                              
--if isnull(@ExtendedAddress,0) =0                              
--begin                              
 DECLARE @nullReturnAddition NVARCHAR(MAX)= ''                              
 set @strQuery = 'select UserId,SiteName,SurName,FirstName,StreetHnr,City,Zip,  MemberStatus,ActivityStatus, AddressLine1, dbo.GetActiveLoyaltyDeviceId(UserId) as ''ActiveLoyaltyDeviceId'', ' + convert(varchar(3),@RecCount) + ' as TotalCount '+@nullReturnAddition+' from [#userDataDistinct] where rownumber  between  '   
     
     
        
           
 + convert(varchar(3),@FirstRow) + ' and ' + convert(varchar(3),@LastRow) --+ ' ' + @sqlOrder                              
 exec (@strQuery)                                             
  print(@strQuery)                            
DROP TABLE [#userData]                 
DROP TABLE [#userDataDistinct]                              
                              
                              
--exec MemberSearch                  
--  8 /* @p0 */,                  
--  0 /* @p1 */,                  
--  '' /* @p2 */,                  
--  '' /* @p3 */,                  
--  '1900-01-01T00:00:00' /* @p4 */,                  
--  '' /* @p5 */,                  
--  '' /* @p6 */,                  
--  '' /* @p7 */,                  
--  '' /* @p8 */,                  
--  '' /* @p9 */,                  
--  NULL /* @p10 */,                  
--  '' /* @p11 */,                  
--  -1 /* @p12 */,                  
--  0 /* @p13 */,                  
--  0 /* @p14 */,                  
--  40 /* @p15 */,               
--  'UserId' /* @p16 */,                  
--  'asc' /* @p17 */,                  
--  NULL /* @p18 */,                  
--  '' /* @p19 */,                  
--  '' /* @p20 */,                  
--  1 /* @p21 */,                  
--  0 /* @p22 */,                  
--  '' /* @p23 */,                  
--  0 /* @p24 */,                  
--  '' /* @p25 */,                  
--  '' /* @p26 */,                  
--  -1 /* @p27 */,                  
--  -1 /* @p28 */,                  
--  '1900-01-01T00:00:00' /* @p29 */,                  
--  '' /* @p30 */,                  
--  '' /* @p31 */                                      
                              
END 
