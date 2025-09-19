CREATE PROCEDURE [dbo].[GetParentSiteList]
(
@siteId INT,
@ClientId INT
)
AS

  SET NOCOUNT ON;

  BEGIN

        SELECT s.SiteId AS SiteId,
               s.Name     AS Name
				 FROM   [Site] s
               INNER JOIN SiteType st on s.SiteTypeId=st.SiteTypeId and st.Clientid=@ClientId
			   inner join SiteStatus ss on ss.SiteStatusId=s.SiteStatusId and ss.Name='Active' and st.Clientid=@ClientId
        WHERE s.ClientId = @ClientId order by s.Name asc
               
  END

