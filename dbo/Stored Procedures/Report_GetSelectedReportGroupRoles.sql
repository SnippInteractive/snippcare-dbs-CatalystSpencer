
-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Get Selected Report Group Roles
-- =============================================
CREATE PROCEDURE [dbo].[Report_GetSelectedReportGroupRoles](@ClientId INT,
                                                           @RgId     INT)
AS
  BEGIN
      SELECT r.Code AS RoleID,
             r.Description
      FROM   ReportGroupRole
             INNER JOIN Role
               ON ReportGroupRole.RoleId = Role.RoleID
             INNER JOIN (SELECT Code,
                                Description
                         FROM   Lookup
                                INNER JOIN LookupI8n
                                  ON Lookup.LookupId = LookupI8n.LookupId
                         WHERE  Lookup.ClientId = @ClientId
                                AND LookupType = 'ROLE_TYPE'
                                AND Language = 'en') r
               ON Role.RoleID = r.Code
      WHERE  ReportGroupRole.ReportgroupId = @RgId
             AND role.ClientId = @ClientId
  END
