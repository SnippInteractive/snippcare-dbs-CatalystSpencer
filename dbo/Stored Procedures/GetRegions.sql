
CREATE PROCEDURE GetRegions
(
	@ClientId	INT,
	@SiteType	NVARCHAR(100) -- Supposed to be Area Group
)
AS
BEGIN
	SELECT		s.SiteId,s.Name
	FROM		[Site] s
	INNER JOIN	[SiteType] st
	ON			s.SiteTypeId = st.SiteTypeId
	WHERE		st.Name = @SiteType
	AND			s.ClientId = @ClientId
	AND			st.ClientId = @ClientId
END
