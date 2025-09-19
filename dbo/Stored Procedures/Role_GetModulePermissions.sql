CREATE PROCEDURE [dbo].[Role_GetModulePermissions](@ClientId BIGINT, @Sysuid BIGINT)
AS
  BEGIN
    DECLARE @RolId INT
     
    SET @RolId=(SELECT TOP(1) SysuserRole.RoleID
    FROM   SysuserRole
     join Role r on r.RoleID = SysuserRole.RoleID where r.ClientId = @clientid
            AND SysuserRole.SysuserID = @Sysuid)
    IF (@RolId is not null)
    BEGIN
    INSERT INTO RoleModule
    select @RolId,ModuleId,'111' as permission from Module where ModuleId NOT IN (select ModuleId from RoleModule INNER JOIN SysuserRole 
    ON SysuserRole.RoleID = RoleModule.RoleId where  SysuserRole.SysuserID = @Sysuid )
    
    END
     
      SELECT     RoleModule.ModuleId,MAX(RoleModule.permissions) AS permissions
      FROM       SysuserRole
      INNER JOIN RoleModule
        ON SysuserRole.RoleID = RoleModule.RoleId
      INNER JOIN [Role]
        ON SysuserRole.RoleID = [Role].RoleID
      WHERE      SysuserRole.SysuserID = @Sysuid 
      GROUP      BY RoleModule.ModuleId
      ORDER      BY RoleModule.ModuleId;
  END
