CREATE VIEW [dbo].[VW_Site]
	AS SELECT     c.ClientId, s.Name AS SiteName, s.SiteRef AS StoreRef, s.SiteStatusId, ss.Name AS SiteStatusName, s.SiteTypeId, st.Name AS SiteTypeName, s.SiteId,s.CountryId
FROM         dbo.Site AS s INNER JOIN
                      dbo.SiteType AS st ON s.SiteTypeId = st.SiteTypeId INNER JOIN
                      dbo.SiteStatus AS ss ON ss.SiteStatusId = s.SiteStatusId INNER JOIN
                      dbo.Client AS c ON c.ClientId = s.ClientId
