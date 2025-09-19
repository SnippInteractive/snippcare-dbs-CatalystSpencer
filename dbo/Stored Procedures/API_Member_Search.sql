
  
CREATE PROCEDURE [dbo].[API_Member_Search]
(
 @memberId int, @firstName nvarchar(50), @surName nvarchar(50), @dob datetime, @email nvarchar(50), @phone varchar(20), @deviceId varchar(50),
 @street nvarchar(50), @city nvarchar(50), @countryId int, @zip varchar(50), @siteRef varchar(10), @includeProspect bit, @onlyProspect bit, @phoneticSearch bit, 
 @potential bit, @pageIndex int, @pageSize int, @sortProperty nvarchar(25),@sortDirection nvarchar(10),
 @coverCard nvarchar(15), @mpiId nvarchar(15), @socialSecurity nvarchar(15), @userName nvarchar(80), @addressLine1 nvarchar(100)
)      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
SET NOCOUNT ON;      
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
 



DECLARE  @clientId int = 1, @strWHERE NVARCHAR(max) = '', @strQuery NVARCHAR(max) = '' ,  @strUpdate nvarchar(1000),  @strContactDetails NVARCHAR(1000) = '', @includeEshop NVARCHAR(1000), @strProfiles NVARCHAR(MAX), @sqlORDER NVARCHAR(200)      
DECLARE @LikeEqual Varchar(5) = '='--, @TempTable VARCHAR(100) = '##temp'--'[staging].dbo.[ms_' + replace(replace(replace(replace(convert(varchar(100), getdate(),121),'-',''),':',''),' ',''),'.','') +']'      
      
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'@userData') AND type in (N'U'))      
DROP TABLE [@userData]      
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'@userDataDistinct') AND type in (N'U'))      
DROP TABLE [@userDataDistinct]      
      
      
declare @userData TABLE(UserId INT, SiteName varchar(100) NULL, SurName nvarchar(50) , FirstName nvarchar(50) , Street nvarchar(50), City nvarchar(100) ,  Zip nvarchar(50) , MemberStatus nvarchar(50) , ActivityStatus nvarchar(50) , RowNumber INT, UserType varchar(50), UserStatusId INT,CountryCode varchar(5), Email varchar(50),Phone varchar(50), MobilePhone varchar(50), DateOfBrith datetime, SiteRef varchar(10))
declare @userDataDistinct TABLE(UserId INT, DeviceId varchar(50), SiteName varchar(100) NULL, SurName nvarchar(50) , FirstName nvarchar(50) , Street nvarchar(50),Hnr nvarchar(50) , City nvarchar(100) ,  Zip nvarchar(50) , MemberStatus nvarchar(50) , ActivityStatus nvarchar(50) ,UserType varchar(50),RowNumber INT,CountryCode varchar(5) , Email varchar(50),Phone varchar(50), MobilePhone varchar(50) , DateOfBrith datetime, SiteRef varchar(10)) 

select @clientId = clientid from client where name = 'baseline';
    

DECLARE @RecCount int = 0, @MaxResult INT = 999   
If @pageIndex =-1      
begin      
set @pageIndex = 0;      
end      
DECLARE @FirstRow INT = 0, @LastRow INT = 0      
set @LastRow = @pageSize*(@pageIndex+1)      
Set @FirstRow = @LastRow + 1 - @pageSize      
      
      
DECLARE @firstNamePhn NVARCHAR(50), @surNamePhn NVARCHAR(50), @strPersonalDetails NVARCHAR(1000)='', @strCount varchar(500)      
       
if isnull(@memberId,0) != 0       
begin       
 Declare @MergedMember int = 0      
 Select top 1 @MergedMember =  memberid1 from memberlink where LinkType = ( select MemberLinkTypeId from MemberLinktype where Name = 'Merger' and clientid = @clientId) and MemberId2 = @memberId      
       
 if @MergedMember != 0      
 begin      
  select @strWHERE = @strWHERE + ' and (u.userid = ' + convert(varchar(20),@memberId) + ' or u.userid  = ' + convert(varchar(20),@MergedMember) + ') '       
 end       
 else       
 begin       
  select @strWHERE = @strWHERE + ' and (u.userid = ' + convert(varchar(20),@memberId) + ') '       
 end       
end       
      
if isnull(@surName,'') !=''       
begin       
 set @surName =  replace(@surName ,'*','%')      
 set @LikeEqual = ' = '      
 if CHARINDEX ('%',@surName,0) !=0      
 begin       
  set @LikeEqual = ' like '      
 end       
 if isnull(@phoneticSearch,0) !=0       
  begin       
   SELECT @surNamePhn = SOUNDEX(@surName)      
   select @strWHERE = @strWHERE + ' and  (pd.PhoneticLastnamePrimaryKey = ''' + @surNamePhn + ''' or pd.PhoneticLastnameAlternativeKey = ''' + @surNamePhn + '''  ) '      
  end       
 else      
  begin      
   select @strWHERE = @strWHERE + ' and pd.Lastname ' + @LikeEqual + ' ''' + @surName + ''''      
  end        
      
end       
      
if isnull(@deviceId,'') !=''       
begin       
 select @strWHERE = @strWHERE + ' and d.deviceid = ''' + convert(varchar(20),@deviceId) + ''' '       
end       
      
if isnull(@firstName,'') !=''       
begin       
 set @firstName =  replace(@firstName ,'*','%')      
 set @LikeEqual = ' = '      
 if CHARINDEX ('%',@firstName,0) !=0      
 begin       
  set @LikeEqual = ' like '      
 end       
       
 if isnull(@phoneticSearch,0) !=0       
  begin       
   SELECT @firstNamePhn = SOUNDEX(@firstName)      
   select @strWHERE = @strWHERE + ' and  (pd.PhoneticFirstnamePrimaryKey = ''' + @firstNamePhn + ''' or pd.PhoneticFirstnameAlternativeKey = ''' + @firstNamePhn + '''  ) '      
  end       
 else      
  begin      
   select @strWHERE = @strWHERE + ' and pd.FirstName ' + @LikeEqual + ' ''' + @firstName + ''''      
  end        
end       
      
if isnull(@street,'') !=''       
begin       
 set @street =  replace(@street ,'*','%')      
 set @LikeEqual = ' = '      
 if CHARINDEX ('%',@street,0) !=0      
 begin       
  set @LikeEqual = ' like '      
 end       
 select @strWHERE = @strWHERE + ' and a.Street ' + @LikeEqual + ' ''' + @street + ''''      
end       
      
if isnull(@city,'') !=''       
begin       
 set @city =  replace(@city ,'*','%')      
 set @LikeEqual = ' = '      
 if CHARINDEX ('%',@city,0) !=0      
 begin       
  set @LikeEqual = ' like '      
 end       
 select @strWHERE = @strWHERE + ' and a.City ' + @LikeEqual + ' ''' + @city + ''''      
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
  

if isnull(@addressLine1,'') !=''       
begin       
 set @addressLine1 =  replace(@addressLine1 ,'*','%')      
 set @LikeEqual = ' = '      
 if CHARINDEX ('%',@addressLine1,0) !=0      
 begin       
  set @LikeEqual = ' like '      
 end       
 select @strWHERE = @strWHERE + ' and AddressLine1 ' + @LikeEqual + ' ''' + @addressLine1 + ''''      
end       


declare @strUserProfileExtraInfo varchar(max);

if ISNULL(@socialSecurity, '') !=  '' or ISNULL(@coverCard, '') !=  '' or ISNULL(@mpiId, '') !=  ''
begin 
	set @strUserProfileExtraInfo = ' inner join UserProfileExtraInfo upei on upei.userid = u.userid '
end

if ISNULL(@socialSecurity, '') !=  '' 
begin 
	select @strWHERE = @strWHERE + ' and upei.SocialSecurity = ''' + @socialSecurity + '''' 
end

if ISNULL(@coverCard, '') !=  '' 
begin 
	select @strWHERE = @strWHERE + ' and upei.CoverCard = ''' + @coverCard + '''' 
end


if ISNULL(@mpiId, '') !=  '' 
begin 
	select @strWHERE = @strWHERE + ' and upei.MpiId = ''' + @mpiId + '''' 
end

set @strContactDetails = ' inner join usercontactdetails ucd on ucd.userid = u.userid inner join contactdetails cd on ucd.contactdetailsid = cd.contactdetailsid '       


if isnull(@phone,'') !=''       
begin       
set @phone =  replace(@phone ,'+','')    
set @phone =  replace(@phone ,' ','')    
 set @LikeEqual = ' = '            
 select @strWHERE = @strWHERE + ' and (REPLACE(REPLACE(ISNULL(cd.MobilePhone,''''),'' '',''''),''+'','''') ' + @LikeEqual + ' ''' + @phone + ''''     
 select @strWHERE = @strWHERE + ' or REPLACE(REPLACE(ISNULL(cd.Phone,''''),'' '',''''),''+'','''') ' + @LikeEqual + ' ''' + @phone + ''')'
end       
 

if isnull(@email,'') !=''
begin       
 set @LikeEqual = ' = '      
 select @strWHERE = @strWHERE + ' and cd.email ' + @LikeEqual + ' ''' + @email + ''''      
end       
      
set @strPersonalDetails = '  inner join [PersonalDetails] pd on u.PersonalDetailsId = pd.PersonalDetailsId '       
      
if isnull(@dob,'1900-01-01') != '1900-01-01'      
begin       
 select @strWHERE = @strWHERE + ' and pd.DateOfBirth = ''' + convert(varchar(10),@dob,120) + ''''      
End      
      
--print @strWHERE      
      
DECLARE @AddressStatusIdCurrent INT, @UserStatusIdActive INT, @UserStatusIdPotential INT, @addressvalidstatusid INT      
DECLARE @AddressTypeIdMain INT 
     
SELECT @AddressStatusIdCurrent = AddressStatusId FROM   [AddressStatus] WHERE Name = 'Current' and ClientId = @clientId       
SELECT @AddressTypeIdMain = AddressTypeId FROM   [AddressType] WHERE  Name = 'Main' and ClientId = @clientId      
SELECT @UserStatusIdActive = UserStatusId  FROM [UserStatus] WHERE ClientId = @clientId and  Name = 'Active'       
SELECT @UserStatusIdPotential = UserStatusId  FROM [UserStatus] WHERE ClientId = @clientId and  Name = 'Potential'       
SELECT @addressvalidstatusid = addressvalidstatusid FROM   [addressvalidstatus] WHERE  Name = 'Valid' and ClientId = @clientId      


if isnull(@potential,0)!=0      
begin      
 select @strWHERE = @strWHERE + ' and u.userstatusid = ' + convert(nvarchar(3),@UserStatusIdPotential) + ' '       
end      
else      
begin      
 select @strWHERE = @strWHERE + ' and u.userstatusid = ' + convert(nvarchar(3),@UserStatusIdActive) + ' '       
end    

if isnull(@siteRef,0)!=0      
begin      
 select @strWHERE = @strWHERE + ' and s.siteRef = ' + @siteRef + ' '       
end     

if isnull(@userName,0)!=0      
begin      
 select @strWHERE = @strWHERE + ' and u.Username = ' + @userName + ' '       
end     

DECLARE @prospectJoin nvarchar(500)      
set @prospectJoin =''      
set @strProfiles = ''      
--set @includeEshop  = ''      
if isnull(@includeProspect,0) = 0      
begin       
 set @prospectJoin = ' inner join device d on d.userid=u.userid      
 inner join DeviceProfile dp on d.id = dp.deviceid       
 inner join DeviceProfileTemplate t on dp.DeviceProfileID = t.id       
 inner join DeviceProfileTemplateType dt on t.DeviceProfileTemplateTypeId = dt.Id '      
 set @strProfiles = ' dt.Name in (''Loyalty'') and '      
 --set @includeEshop = ' , ''eshop'' '      
end       
if isnull(@onlyProspect,0) = 1      
begin       
      
 set @prospectJoin = ' '      
 set @strProfiles = '  not exists (SELECT 1      
                                FROM   [Device] d                                           
                                WHERE  d.UserId =u.userid ) and '      
end        

DECLARE @strQueryMain NVARCHAR(MAX) = ''       

set @strQueryMain = 'SELECT  DISTINCT top '+convert(varchar(10),@MaxResult)+' u.UserId , d.DeviceId, s.Name as SiteName, pd.Lastname SurName, pd.FirstName, isnull(a.Street,'''') Street,  a.City,  a.Zip, ''xxxxxxxxxxxxxx''  MemberStatus,
 ut.Name UserType, u.UserStatusId, us.name ActivityStatus, c.CountryCode , cd.email, cd.phone, cd.mobilephone,  pd.DateOfBirth, s.SiteRef into [@userData] '+
 ' FROM [User] u ' + @strPersonalDetails + '      
 inner join site s on s.siteid = u.siteid      
 inner join [UserAddresses] ua on ua.userid = u.userid 
 inner join Address a on ua.AddressId = a.AddressId 
 inner join Country c on a.CountryId = c.CountryId
 '
 + @prospectJoin
 + ' inner join userstatus us on us.userstatusid = u.userstatusid ' 
 + ' inner join UserType ut on ut.usertypeid = u.usertypeid ' 
 + @strContactDetails
 
 

set @strQuery = @strQueryMain +       
 'where ' + @strProfiles + '      
 AddressTypeId = ' + convert(varchar(3),@AddressTypeIdMain) + '      
 and AddressStatusId = ' + convert(varchar(3),@AddressStatusIdCurrent) 
  
set @sqlORDER = ' ORDER BY ' + @sortProperty + ' ' + @sortDirection      
      
--print @strQuery      
--print 'where clause included'      
set @strQuery = 'Begin '+ @strQuery + @strWhere  +@sqlORDER+ ' END '      
      
--print @strQuery      
set @strUpdate = ' Begin update [@userData] set MemberStatus = ''Active'' END'      
      
set @strQuery = @strQuery + @strUpdate      
      
--print @strQuery      
      
set @strQuery = @strQuery + ' Begin DELETE from [@userData] where Activitystatus not in (''Active'',''Potential'') end '      
      
if @onlyProspect = 1      
begin      
 set @strQuery = @strQuery + ' Begin DELETE from [@userData] where memberstatus !=''PROSPECT'' end '      
end       
print @sqlOrder
exec (@strQuery)     
   
--print 'As far as here!'   
set @strQuery = 'Select UserId, deviceid, SiteName, SurName, FirstName, Street, City, Zip, MemberStatus, ActivityStatus, TotalCount, ROW_NUMBER() OVER(' + @sqlOrder + ' ) as RowNumber ,CountryCode, UserType, email, phone, mobilephone, DateOfBirth, SiteRef into [@userDataDistinct] from ( ' +      
'select distinct UserId,deviceid, SiteName,SurName,FirstName,Street,City,Zip,  MemberStatus,ActivityStatus,0 TotalCount,CountryCode, UserType, email, phone, mobilephone, DateOfBirth, SiteRef from [@userData]  ) x'      
 
exec (@strQuery)    
 
select @RecCount = count(*) from [@userDataDistinct] --'-- + @TempTable + ''--'DECLARE @RecCount INT       
update [@userDataDistinct] SET TotalCount = @RecCount      
      

 set @strQuery = 'select udd.UserId MemberId, udd.DeviceId, SiteName ,SurName Lastname, FirstName Firstname, Street, City, Zip, MemberStatus, ActivityStatus,' + convert(varchar(3),@RecCount) + ' as TotalCount, udd.UserType, email, phone, mobilephone, CONVERT(varchar(10), DateOfBirth, 126) DateOfBirth, SiteRef , CountryCode' 
 + ' from [@userDataDistinct] udd '
 + ' where rownumber  between ' + convert(varchar(3),@FirstRow) + ' and ' + convert(varchar(3),@LastRow)

exec (@strQuery)      
      
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'@userData') AND type in (N'U'))      
DROP TABLE [@userData]      
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'@userDataDistinct') AND type in (N'U'))      
DROP TABLE [@userDataDistinct]      
      
      
END      
