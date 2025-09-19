-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Get Report
-- =============================================
CREATE PROCEDURE [dbo].[Report_GetReport] (
	@ClientID INT,@language CHAR(2),@ReportId int
	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
      	SELECT     rgi.RgId AS ReportGroup, Report.*
FROM         Report INNER JOIN
                      ReportGroupClient ON Report.ReportId = ReportGroupClient.ReportId INNER JOIN
                     ( select Code as Rgid,Description,Language FROM Lookup INNER JOIN LookupI8n ON Lookup.LookupId=LookupI8n.LookupId where  Lookup.ClientId=@ClientID and LookupI8n.Language=@language and LookupType='REPORT_GROUP') rgi
                      ON ReportGroupClient.ReportGroupId = rgi.RgId
	 where ReportGroupClient.ReportId =@ReportId; 
END
