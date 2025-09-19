
-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Delete Alterd Report Roles
-- =============================================
CREATE PROCEDURE [dbo].[Report_DeleteAlterdReportRoles] (@RgId INT)
AS
  BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      DELETE FROM ReportRole
      WHERE  ReportRole.RoleId IN (SELECT DISTINCT ReportRole.RoleId
                                   FROM   ReportGroupDetails
                                          INNER JOIN ReportRole
                                            ON ReportGroupDetails.ReportId = ReportRole.ReportId
                                          INNER JOIN ReportGroupRole
                                            ON ReportGroupDetails.ReportGroupId = ReportGroupRole.ReportgroupId
                                   WHERE  ReportRole.RoleId NOT IN (SELECT ReportGroupRole.RoleId
                                                                    FROM   ReportGroupRole
                                                                    WHERE  ReportGroupRole.ReportgroupId = @RgId))
  END
