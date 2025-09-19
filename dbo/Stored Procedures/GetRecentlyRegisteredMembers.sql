
CREATE PROCEDURE GetRecentlyRegisteredMembers
AS
BEGIN
	SELECT		TOP 5 
				u.UserId UserId, 				
				ISNULL(pd.FirstName,'')FirstName,
				ISNULL(pd.Lastname,'')SurName
					
	FROM		[user]u (nolock)
	INNER JOIN	PersonalDetails pd (nolock)
	ON			u.PersonalDetailsId = pd.PersonalDetailsId
	ORDER BY	CreateDate DESC
	END
