-- =============================================



-- =============================================
CREATE PROCEDURE [dbo].[GetRoleModuleActions](@RoleId BIGINT,@ModuleId BIGINT)
AS
  BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;
          
    
                SELECT ModuleActions.ModuleActionsId,ModuleActions.ModuleId,ModuleActions.Name,RoleModuleActions.permissions as Permission,RoleModuleActions.RoleId                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                 
                FROM         RolemoduleActions INNER JOIN
                      ModuleActions ON RolemoduleActions.ModuleActionsId = ModuleActions.ModuleActionsId where RoleModuleActions.RoleId=@RoleId AND ModuleActions.ModuleId=@ModuleId
                     
   
  END
