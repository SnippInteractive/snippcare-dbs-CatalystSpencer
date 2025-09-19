CREATE PROCEDURE [dbo].GetUserGoals(@UserId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

			SELECT * 
			FROM   UserGoals 
			WHERE  userid = @UserId 
END
