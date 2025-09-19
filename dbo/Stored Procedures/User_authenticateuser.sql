
-- =============================================
-- Author:		<Sajosh Joy>
-- Create date: <20-3-09>
-- Description:	<To Validate the username and password>
-- =============================================
CREATE PROCEDURE [dbo].[User_authenticateuser](@username VARCHAR(100),
                                               @password VARCHAR(100),
                                               @result   INT =null)
AS
  BEGIN
      SET nocount ON;

      DECLARE @countpassword INT;
      DECLARE @countUserName INT;

      SELECT @countUserName = Count(*)
      FROM   [User]
      WHERE  [Username] = @username
             AND ExpirationDate > = Getdate();

      IF ( @countUserName = 1 )
        BEGIN
           -- Password validation moved to front end
                  SELECT top (1) 2 as result,SU.*,S.*,'en' as [Language],C.Name AS ClientName,p.Lastname  + ' ' + p.Firstname  AS LoginUserName
                  FROM   [User] SU
                         INNER JOIN PersonalDetails p
                           ON p.PersonalDetailsId = SU.PersonalDetailsId
                         INNER JOIN Site S
                           ON S.SiteId = SU.SiteId
                         INNER JOIN Client C
                           ON C.ClientId = S.ClientId
                  WHERE  SU.Username = @username
                          AND SU.Username =@username;
                         --AND SU.UserId = 0;
                         
  SELECT     SysuserRole.RoleID
  FROM       SysuserRole
  INNER JOIN [User]
    ON [User].UserID = SysuserRole.SysuserID
  WHERE      [User].Username = @username;
  
        END
      ELSE
        IF ( @countUserName = 0 )
          --Invalid UserName
          BEGIN
              SELECT 0 as result,'' as Password
          END

  END
