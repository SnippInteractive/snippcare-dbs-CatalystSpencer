
CREATE PROCEDURE [dbo].[User_GetUserByUserId] (@UserId BIGINT)
AS
  BEGIN
      SET nocount ON;
      BEGIN 
                         
                  
          SELECT U.*,S.*,'en' as [Language],
          C.Name AS ClientName,
          p.Lastname  + ' ' + p.Firstname  AS LoginUserName,
          c.DefaultStylesheet
                  FROM   [User] U
                         LEFT JOIN PersonalDetails p
                           ON p.PersonalDetailsId = U.PersonalDetailsId
                         INNER JOIN Site S
                           ON S.SiteId = U.SiteId
                         INNER JOIN Client C
                           ON C.ClientId = S.ClientId
                  WHERE  U.UserId = @UserId 

              
      END
      

  SELECT     SysuserRole.RoleID
  FROM       SysuserRole
  INNER JOIN [User]
    ON [User].UserID = SysuserRole.SysuserID
  WHERE      [User].UserId = @UserId 
END
