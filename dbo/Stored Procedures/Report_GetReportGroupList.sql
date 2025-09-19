
-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Get Report Group List
-- =============================================
CREATE PROCEDURE [dbo].[Report_GetReportGroupList] (@ClientId INT,
                                                   @Language CHAR(2))
AS
  BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      SELECT DISTINCT rg.ReportGroupId AS Id,
                      rpi.Description
      FROM   ReportGroup rg
             INNER JOIN (SELECT Code,
                                [Description]
                         FROM   [dbo].[Getlookup] (@ClientId, 'REPORT_GROUP', @Language)) rpi
               ON rpi.Code = rg.ReportGroupId
             LEFT JOIN ReportGroupRole rgr
               ON rgr.ReportgroupId = rg.ReportGroupId
             LEFT JOIN Role r
               ON r.RoleID = rgr.RoleId
      WHERE  rg.ClientId = @ClientId
  END
