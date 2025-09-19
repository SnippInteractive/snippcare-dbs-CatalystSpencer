-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Get Report Parameters
-- =============================================
CREATE PROCEDURE [dbo].[GetReportParameters] (@ReportId INT,
                                             @Language CHAR(2))
AS
  BEGIN
      SET NOCOUNT ON;

      SELECT    *
      FROM      ReportParameter R
      LEFT JOIN ReportParameterDisplay rp
        ON rp.ReportParameterId = R.RepParameterId
      WHERE     R.ReportId = @ReportId
            AND rp.LANGUAGE = @Language
             OR R.ReportId = @ReportId
                AND rp.LANGUAGE IS NULL
      ORDER     BY R.ParamIndex;
  END
