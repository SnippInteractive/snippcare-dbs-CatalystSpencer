
-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Delete Report Group
-- =============================================
CREATE PROCEDURE [dbo].[Report_DeleteReportGroup] (@ReportGroupId      INT,
                                                  @checkreportGroupID INT OUTPUT)
AS
  BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      IF EXISTS(SELECT 1
                FROM   ReportGroupDetails
                WHERE  ReportGroupId = @ReportGroupId)
        BEGIN
            SET @checkreportGroupID=1
        END
      ELSE
        BEGIN
            DELETE FROM ReportGroup
            WHERE  ReportGroupId = @ReportGroupId;

            DELETE FROM LookupI8n
            WHERE  LookupId = (SELECT LookupId
                               FROM   Lookup
                               WHERE  Code = @ReportGroupId
                                      AND LookupType = 'REPORT_GROUP')

            DELETE FROM Lookup
            WHERE  Code = @ReportGroupId
                   AND LookupType = 'REPORT_GROUP'

            DELETE FROM ReportGroupRole
            WHERE  ReportgroupId = @ReportGroupId;

            SET @checkreportGroupID=0
        END
  END
