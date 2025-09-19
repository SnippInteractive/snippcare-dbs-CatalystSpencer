
CREATE PROCEDURE [dbo].[Role_GetRoleModuleListLM2] (@RoleId INT, @Language CHAR(2),@ClientId BIGINT)
AS
  BEGIN
       
    SELECT 
    (SELECT Name from [Role] where RoleId = @RoleId) as [Description], (select enabled from [Role] where RoleId = @RoleId) as Enabled,
    m.ModuleId, t.Value as ModuleName, m.ModuleGroup, m.ModuleOrder, m.AssignPermissionId, m.EditPermissionId, m.ViewPermissionId, m.RootElement,
    m.Href,m.InternalName as ModuleValue,m.Controller,m.Area,m.Action
    FROM Module m
    --INNER join ModuleTranslations mt on mt.ModuleId = m.ModuleId
    INNER join Translations t on m.InternalName = t.TranslationGroupKey
    WHERE m.ClientId = @ClientId and T.LanguageCode = @Language and T.TranslationGroup = 'Module' and t.ClientId = @ClientId
     
 
  END
