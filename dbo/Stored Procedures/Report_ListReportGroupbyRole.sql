
-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	List Report Group by Role
-- =============================================
CREATE PROCEDURE [dbo].[Report_ListReportGroupbyRole](@ClientId INT,
                                                     @RoleId   INT,
                                                     @Language CHAR(2))
AS
  BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      SELECT DISTINCT rg.ReportGroupId AS Id,
						'Reports' AS DESCRIPTION
      FROM   ReportGroup rg
             --INNER JOIN (SELECT Code,
             --                   [Description]
             --            FROM   [dbo].[Getlookup] (@ClientId, 'REPORT_GROUP', @Language)) rpi
             --  ON rpi.Code = rg.ReportGroupId
             INNER JOIN ReportGroupRole rgr
               ON rgr.ReportgroupId = rg.ReportGroupId
             INNER JOIN ROLE r
               ON r.RoleID = rgr.RoleId
      WHERE  rg.ClientId = @ClientId
  -- AND rgr.RoleId = @RoleId
  END
