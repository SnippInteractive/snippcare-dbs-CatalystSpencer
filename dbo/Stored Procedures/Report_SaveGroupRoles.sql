-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Save Group Roles
-- =============================================
CREATE PROCEDURE [dbo].[Report_SaveGroupRoles] (
	@RgId int,
	@RoleId int
	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	insert into  ReportGroupRole values(@RgId,@RoleId);

END
