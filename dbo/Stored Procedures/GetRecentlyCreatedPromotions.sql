
CREATE PROCEDURE GetRecentlyCreatedPromotions
(
	@clientId INT =1
)
AS
BEGIN
	SELECT		TOP 5 p.Id , ISNULL(p.Name,'') + CASE ISNULL(p.Description,'')WHEN '' THEN '' ELSE '-'+ISNULL(p.Description,'') END Name
	FROM		Promotion p 
	INNER JOIN  [site]s
	ON			p.SiteId = s.SiteId
	WHERE		s.ClientId = @clientId
	AND			p.Enabled =1
	ORDER BY	p.Id DESC
END
