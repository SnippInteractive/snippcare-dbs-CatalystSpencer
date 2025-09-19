CREATE PROCEDURE GetUserTiers(@userId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

			SELECT ta.Description, 
			   dpt.Name as ProfileName, 
			   tu.Userid, 
			   tu.TierId,
			   tu.Id 
			FROM   tieradmin ta 
				   INNER JOIN tierusers tu 
						   ON tu.tierid = ta.id 
				   INNER JOIN deviceprofiletemplate dpt 
						   ON dpt.id = ta.loyaltyprofileid 
			WHERE  tu.userid = @userId 
END
