 
-- =============================================
CREATE PROCEDURE [dbo].[Role_GetUserRolePermissions]   
( 
@UserId INT,
@RoleId INT
)
AS 
BEGIN

	 IF @RoleId <> -1 
		 BEGIN
			 Select distinct p.PermissionId from Permission P 
			 JOIN RolePermissions RP on RP.PermissionId = P.PermissionId
			 JOIN SysuserRole SR on SR.RoleID = RP.RoleId
			 Where SR.SysuserID = @UserId and SR.RoleID = @RoleId 
			 order by p.PermissionId
		 END
	 ELSE
		 BEGIN
			 Select distinct p.PermissionId, p.Name from Permission P 
			 JOIN RolePermissions RP on RP.PermissionId = P.PermissionId
			 JOIN SysuserRole SR on SR.RoleID = RP.RoleId
			 Where SR.SysuserID = @UserId 
			 order by p.PermissionId
		 END
END
