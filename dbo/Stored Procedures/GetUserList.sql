CREATE PROCEDURE [dbo].[GetUserList] (
	@siteIds as varchar(Max) = ''
) 
AS
BEGIN
	DECLARE @query as nvarchar(Max)
	declare @clientid varchar(2);
	select @clientid = ClientId from site where siteid = @siteIds
	set @query = 'select u.UserId as Id ,P.Firstname + '' ''+ P.Lastname as Description from [User] u inner join Personaldetails P on P.PersonalDetailsId=u.PersonalDetailsId 
												where u.UserTypeid in ( select UserTypeID from UserType where Clientid ='+ @clientid +' and name in (''Admin'',''HelpDesk'') )	
												 and u.SiteId in (select siteid from  [GetChildSitesBySiteId] ('+@siteIds+')) order by P.Firstname asc'
		
   exec SP_EXECUTESQL @query		
END

