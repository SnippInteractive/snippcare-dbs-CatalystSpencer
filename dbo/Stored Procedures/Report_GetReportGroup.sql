
-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Get Report Group
-- =============================================
CREATE PROCEDURE [dbo].[Report_GetReportGroup] (@ClientID      INT,
                                               @language      CHAR(2),
                                               @ReportGroupId INT)
AS
  BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      SELECT *
      FROM   ReportGroup rg
             INNER JOIN (SELECT Code AS Rgid,
                                Description,
                                Language
                         FROM   Lookup
                                INNER JOIN LookupI8n
                                  ON Lookup.LookupId = LookupI8n.LookupId
                         WHERE  Lookup.ClientId = @ClientID
                                AND LookupI8n.Language = @language
                                AND LookupType = 'REPORT_GROUP') rgi
               ON rgi.Rgid = rg.ReportGroupId
      WHERE  rg.ReportGroupId = @ReportGroupId
  END
