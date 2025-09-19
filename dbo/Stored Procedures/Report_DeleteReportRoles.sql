-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Delete Report Roles
-- =============================================
CREATE PROCEDURE [dbo].[Report_DeleteReportRoles] (
	@RgId int
	
	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	delete from ReportRole where ReportId=@RgId;

END
