
-- =============================================
CREATE PROCEDURE [dbo].[GetChildSitesOfAreaGroupBySiteId]  
(	
	-- Add the parameters for the function here
	@siteID int
) 
AS
--AreaGroup,HeadOffice
 DECLARE @ClientId INT;
 DECLARE @CurrentSiteType varchar(50); 
 DECLARE @SiteTypeid INT;
 DECLARE @ParentId INT
 DECLARE @ParentSiteType varchar(50); 
 SET @ClientId=(select clientid from site where siteid= @siteID)
 SET @SiteTypeid=(Select sitetypeid from Sitetype where name='AreaGroup' and clientid=@ClientId)
 SET @CurrentSiteType=( select Name from Sitetype where sitetypeid=(select sitetypeid from site where siteid=@siteID))
 IF(@CurrentSiteType='HeadOffice')
 BEGIN
--call existing function
  select * from [GetChildSitesBySiteId](@siteID)
 END
 ELSE IF(@CurrentSiteType='AreaGroup')
 BEGIN	 
	 SET @ParentId=(select parentid from site where siteid=@siteID)
	 SET @ParentSiteType=( select Name from Sitetype where sitetypeid=(select sitetypeid from site where siteid=@ParentId))
		 IF(@ParentSiteType='AreaGroup')
		 BEGIN
		 SET @ParentId=(select parentid from site where siteid=@ParentId)
		 select * from [GetChildSitesBySiteId](@ParentId)
		 END
		 else IF(@ParentSiteType='HeadOffice')
         BEGIN
         select * from [GetChildSitesBySiteId](@ParentId)
         end
		 ELSE
		 BEGIN
		 select * from [GetChildSitesBySiteId](@siteID)
		 END
 END
 ELSE IF(@CurrentSiteType='Store' OR @CurrentSiteType='OnlineSite')
 BEGIN
	 SET @ParentId=(select parentid from site where siteid=@siteID)
     SET @ParentSiteType=( select Name from Sitetype where sitetypeid=(select sitetypeid from site where siteid=@ParentId))

	 IF(@ParentSiteType='AreaGroup' )
		 BEGIN
		  SET @ParentId=(select parentid from site where siteid=@ParentId)
		  select * from [GetChildSitesBySiteId](@ParentId)
		 END
		 else IF(@ParentSiteType='HeadOffice')
         BEGIN
         select * from [GetChildSitesBySiteId](@ParentId)
         end
		 ELSE
		 BEGIN
		  select * from [GetChildSitesBySiteId](@siteID)
		 END
	 	
 END
 ELSE 
 BEGIN
  select * from [GetChildSitesBySiteId](@siteID)
 END
