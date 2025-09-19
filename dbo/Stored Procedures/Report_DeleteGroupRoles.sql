
-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Delete Group Roles
-- =============================================
CREATE PROCEDURE [dbo].[Report_DeleteGroupRoles] (@RgId INT)
AS
  BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      DELETE FROM ReportGroupRole
      WHERE  ReportgroupId = @RgId;
  END
