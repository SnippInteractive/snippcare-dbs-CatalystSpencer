-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Save Report Roles
-- =============================================
CREATE PROCEDURE [dbo].[Report_SaveReportRoles] (
	@RgId int,
	@RoleId int
	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF NOT EXISTS(SELECT 1 FROM ReportRole WHERE RoleId=@RoleId and ReportId=@RgId)
	BEGIN
	insert into  ReportRole values(@RgId,@RoleId);
	END

END
