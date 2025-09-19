-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Get Report Parameters
-- =============================================
CREATE PROCEDURE [dbo].[Report_GetReportParameters] (@ReportId INT,@Language CHAR(2))
AS
  BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      --SELECT * from ReportParameter R
      -- inner join ReportParameterDisplay rp on rp.ReportParameterId=R.RepParameterId 
      -- where R.ReportId  =@ReportId and rp.Language =@Language order by R.ParamIndex; 
      SELECT    *
      FROM      ReportParameter R
      LEFT JOIN ReportParameterDisplay rp
        ON rp.ReportParameterId = R.RepParameterId
      WHERE     R.ReportId = @ReportId
            AND rp.LANGUAGE = @Language
             OR R.ReportId = @ReportId
                AND rp.LANGUAGE IS NULL
      ORDER     BY R.ParamIndex;
  --where R.ReportId  =@ReportId order by R.ParamIndex; 
  END
