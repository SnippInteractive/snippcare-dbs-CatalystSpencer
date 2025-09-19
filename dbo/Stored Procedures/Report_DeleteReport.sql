-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Delete Report
-- =============================================
CREATE PROCEDURE [dbo].[Report_DeleteReport] (
	@ReportId int
	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Delete from Report where ReportId =@ReportId; 
	Delete from ReportGroupClient where ReportId =@ReportId; 
	Delete from ReportRole where ReportId=@ReportId;
END
